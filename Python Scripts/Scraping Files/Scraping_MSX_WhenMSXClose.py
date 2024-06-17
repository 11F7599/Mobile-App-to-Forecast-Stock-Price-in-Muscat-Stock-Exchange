import logging
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
import time
import datetime
import sqlite3
import os
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from concurrent.futures import ThreadPoolExecutor
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import firebase_admin
from firebase_admin import credentials, firestore
import re



# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

db_directory = r'C:\Users\tryho\OneDrive\Desktop\MSX Plus Project\StockData'
db_path = os.path.join(db_directory, 'StockHistoricalData.db')

# Constants
UP = "up"
DOWN = "down"
NO_CHANGE = "noChange"

chrome_executable_path = r"C:\WebDrivers\chrome-win64\chrome.exe"
chromedriver_path = r"C:\WebDrivers\chromedriver.exe"
firestoreAdminSDKkey = r"C:\Users\tryho\OneDrive\Desktop\MSX Plus Project\Python Scripts\msx-plus-firebase-adminsdk-ez5aq-1991bf8f2b.json"

cred = credentials.Certificate(firestoreAdminSDKkey)
firebase_admin.initialize_app(cred)

# Initialize Firestore
db = firestore.client()

# Firestore collection reference
collection_ref = db.collection('stocks')

    
def scrape_stock_info(li):
    try:
        # Connect to SQLite DB
        conn = sqlite3.connect(db_path)

        uniqueID = li.find_element(By.TAG_NAME, "span").get_attribute("data-rel")

        companyName_element = li.find_element(By.TAG_NAME, "a")
        tickerSymbol_element = companyName_element.find_element(By.TAG_NAME, "i").text
        tickerSymbol = tickerSymbol_element[1:-1].strip()
        
        parent_ul = li.find_element(By.XPATH, '..')
        close_li = parent_ul.find_element(By.CLASS_NAME, "column2")

        # Split the text and check the length
        split_text = close_li.text.split('\n')
        closePrice = split_text[0] if len(split_text) > 0 else "N/A"
        change = split_text[1] if len(split_text) > 1 else "N/A"

        percentageChange = float((re.search(r'(\d+(\.\d+)?)(?=%)', change)).group())

        # Extract direction based on the em class
        em_element = close_li.find_element(By.TAG_NAME, "em").get_attribute("class")

        if "green-r" in em_element:
            direction = UP
        elif "red-r" in em_element:
            direction = DOWN
            percentageChange = -percentageChange
        else:
            direction = NO_CHANGE

        dateToday = datetime.datetime.now().date() 

        trades = int(parent_ul.find_element(By.CLASS_NAME, "column8").text.replace(',', '')) 
        volume = int(parent_ul.find_element(By.CLASS_NAME, "column9").text.replace(',', ''))
        turnover_ele = parent_ul.find_element(By.CLASS_NAME, "column10").text.replace(',', '')
        parts = turnover_ele.split(".")
        turnover = parts[0]
        if len(parts) > 1 and any(digit != '0' for digit in parts[1]):
            # Convert to integer and add 1
            turnover = int(turnover) + 1

        openPrice = float(parent_ul.find_element(By.CLASS_NAME, "column11").text)
        closePrice_Yesterday = float(parent_ul.find_element(By.CLASS_NAME, "column12").text)
        highPrice = float(parent_ul.find_element(By.CLASS_NAME, "column13").text)
        lowPrice = float(parent_ul.find_element(By.CLASS_NAME, "column14").text)
        closePrice = float(closePrice)
        netChange = round(float(closePrice - closePrice_Yesterday), 3)

        print(f"openPrice:{openPrice} highPrice:{highPrice} lowPrice:{lowPrice} trades:{trades} volume:{volume} turnover:{turnover} closePrice:{closePrice} netChange:{netChange} percentageChange:{percentageChange}")

        #predictedClosePrice = None
        # Use tickerSymbol as the document ID
        doc_ref = collection_ref.document(tickerSymbol)
        if doc_ref.get().exists:
            #predictedClosePrice = doc_ref.get('predictedClosePrice')
            # Update the document data
            doc_ref.update({
                "closePrice": str(closePrice),
                "change": change,
                "direction": direction,

                "openPrice": str(openPrice),
                "highPrice": str(highPrice),
                "lowPrice": str(lowPrice),
                "trades": str(trades),
                "volume": str(volume),
                "turnover": str(turnover),
                "netChange": str(netChange),
                "percentageChange": str(percentageChange),
                "date": str(dateToday.strftime("%Y-%m-%d")),
            })
            logger.info(f"Document {tickerSymbol} updated.")
        else:
            # Document does not exist, so create it
            companyName_element2 = companyName_element.text
            companyName = companyName_element2.replace(tickerSymbol_element, '').strip()
            dataMarket = li.find_element(By.XPATH, "../..").get_attribute("id")
            category = li.find_element(By.XPATH, "../..").find_element(By.XPATH, "preceding-sibling::*[1]").find_element(By.TAG_NAME, "h2").text
            doc_ref.set({
                "category": category.strip(),
                "companyName": companyName.strip(),
                "containerID": dataMarket.strip(),
                "uniqueID": uniqueID.strip(),

                "direction": direction,
                "closePrice": str(closePrice),
                "change": change.strip(),
                
                "openPrice": str(openPrice),
                "highPrice": str(highPrice),
                "lowPrice": str(lowPrice),
                "trades": str(trades),
                "volume": str(volume),
                "turnover": str(turnover),
                "netChange": str(netChange),
                "percentageChange": str(percentageChange),
                "date": str(dateToday.strftime("%Y-%m-%d")),
            })
            logger.warning(f"Document {tickerSymbol} does not exist --> created successfully")

        # SQLite operations
        table_name = f"{tickerSymbol}"
        c = conn.cursor()
        c.execute(f'''CREATE TABLE IF NOT EXISTS {table_name} (
                    date DATE UNIQUE,
                    openPrice REAL,
                    highPrice REAL,
                    lowPrice REAL,
                    trades INTEGER,
                    volume INTEGER,
                    turnover INTEGER,
                    closePrice REAL,
                    netChange REAL,
                    percentageChange REAL,
                    closePredictedPrice REAL,
                    predictionAccuracy REAL
                    )''')  # Make date a unique field
        
        #check its not weekend day before update sqlite
        date_today = datetime.date.today().weekday()
        if date_today != 4 or date_today != 5:
                # Insert or update on conflict with the date
            c.execute(f'''INSERT INTO {table_name} (date, openPrice, highPrice, lowPrice, trades, volume, turnover, closePrice, netChange, percentageChange)
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                            ON CONFLICT(date) DO UPDATE SET
                            openPrice = excluded.openPrice,
                            highPrice = excluded.highPrice,
                            lowPrice = excluded.lowPrice,
                            trades = excluded.trades,
                            volume = excluded.volume,
                            turnover = excluded.turnover,
                            closePrice = excluded.closePrice,
                            netChange = excluded.netChange,
                            percentageChange = excluded.percentageChange,
                            closePredictedPrice = excluded.closePredictedPrice,
                            predictionAccuracy = excluded.predictionAccuracy
                            ''',
                        (dateToday.strftime("%Y-%m-%d"), openPrice, highPrice, lowPrice, trades, volume, turnover, closePrice, netChange, percentageChange, None, None))
        conn.commit()
        conn.close()

    except NoSuchElementException as e:
        logger.error(f"Span element not found in the li element: {e}")
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")

def launchBrowser():
    start_time = 0
    try:
        service = Service(executable_path=chromedriver_path)
        options = webdriver.ChromeOptions()

        # Set the path to the Chrome executable
        options.binary_location = chrome_executable_path

        options.add_argument('--enable-chrome-browser-cloud-management')
        options.add_argument('--no-sandbox')
        options.add_argument("--disable-third-party-cookies")

        # Enable headless mode
        options.add_argument('--headless')
        # Disable images
        prefs = {"profile.managed_default_content_settings.images": 2}
        options.add_experimental_option("prefs", prefs)

        with webdriver.Chrome(service=service, options=options) as driver:
            driver.get("https://www.msx.om/market-watch-custom.aspx")

            try:
                WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.ID, "market-1"))
                )
            except TimeoutException:
                logger.error("Timed out waiting for page to load")
                return

            start_time = time.time()

            # Find all li elements with class 'pos-re' (column1)
            li_elements = driver.find_elements(By.CSS_SELECTOR, "li.pos-re")

            # Use ThreadPoolExecutor for parallel execution
            with ThreadPoolExecutor(max_workers=1) as executor:
                executor.map(scrape_stock_info, li_elements)

    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")
    finally:
        end_time = time.time()
        elapsed_time = end_time - start_time

        logger.info("Data has been successfully updated")
        logger.info(f"Time taken: {elapsed_time} seconds")

# Run the script
launchBrowser()
