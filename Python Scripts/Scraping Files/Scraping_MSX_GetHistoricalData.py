from datetime import datetime
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException
import sqlite3
import time
import os
import firebase_admin
from firebase_admin import credentials, firestore
import psutil



firestoreAdminSDKkey = r"C:\Users\tryho\OneDrive\Desktop\MSX Plus Project\Python Scripts\msx-plus-firebase-adminsdk-ez5aq-1991bf8f2b.json"

chrome_executable_path = r"C:\WebDrivers\chrome-win64\chrome.exe"
chromedriver_path = r"C:\WebDrivers\chromedriver.exe"
db_directory = r'C:\Users\tryho\OneDrive\Desktop\MSX Plus Project\StockData'
db_path = os.path.join(db_directory, 'StockHistoricalData.db')



def kill_process_by_name(name):
    """ Kills all processes matching 'name'. """
    # Iterate over all running processes
    for proc in psutil.process_iter(['name', 'pid']):
        # Check if process name matches the given name
        if proc.info['name'] == name:
            print(name)
            try:
                # Terminate the process
                process = psutil.Process(proc.info['pid'])
                process.terminate()  # or process.kill() if terminate does not work
                print(f"Process {name} (PID: {proc.info['pid']}) has been terminated.")
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                # Handle exceptions if the process is already terminated or access is denied
                print(f"Failed to terminate {name} (PID: {proc.info['pid']}).")




def setup_browser(chromedriver_path, chrome_executable_path):
    service = Service(executable_path=chromedriver_path)
    options = webdriver.ChromeOptions()
    options.binary_location = chrome_executable_path
    options.add_argument('--no-sandbox')
    options.add_argument("--disable-third-party-cookies")
    options.add_argument("--enable-chrome-browser-cloud-management")
    # options.add_argument('--disable-images')
    # options.add_argument('--disable-javascript')
    return service, options

def create_connection(db_path):
    try:
        conn = sqlite3.connect(db_path)
        return conn
    except sqlite3.Error as e:
        print(e)
        return None

def create_table(conn, table_name):
    create_table_sql = f''' CREATE TABLE IF NOT EXISTS {table_name} (
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
                            ); '''
    try:
        cursor = conn.cursor()
        cursor.execute(create_table_sql)
        conn.commit()
    except sqlite3.Error as e:
        print(e)

def insert_data(conn, data, table_name):
    insert_sql = f'''INSERT INTO {table_name} VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);'''
    try:
        cursor = conn.cursor()
        cursor.execute(insert_sql, data)
        conn.commit()
    except sqlite3.Error as e:
        print(e)

def getDataFromRows(cells):
    row_data = [cells[i].text for i in [0, 1, 2, 3, 4, 5, 6, 9, 10, 11]]
    try:
        if float(row_data[1]) == 0.0:  # Check if the Open Price is 0.0
            return None  # Skip this row
        converted_data = (
            datetime.strptime(row_data[0], '%b %d, %Y').date(),  # Date
            float(row_data[1]),  # Open price
            float(row_data[2]),  # High price
            float(row_data[3]),  # Low price
            int(row_data[4].replace(',', '')),  # Trades
            int(row_data[5].replace(',', '')),  # Volume
            int(row_data[6].replace(',', '')),  # Turnover
            float(row_data[7]),  # Close price
            float(row_data[8]),  # Net Change
            float(row_data[9].replace('%', '')), # Percentage Change
            None, # closePredictedPrice
            None # predictionAccuracy
        )
    except ValueError as e:
        print(f"Data conversion error: {e}")
        return
    return converted_data


def launchBrowser(chromedriver_path, chrome_executable_path, db_path, docs):
    service, options = setup_browser(chromedriver_path, chrome_executable_path)
    conn = create_connection(db_path)
    if conn is None:
        print("Failed to establish a database connection.")
        return

    try:
        for doc in docs:
            table_name = doc.id  # Assuming docs is a list of dictionaries with an 'id' key
            print(f"Processing table: {table_name}")
            create_table(conn, table_name)

            with webdriver.Chrome(service=service, options=options) as driver:
                scrape_data(driver, table_name, conn)
            #driver.close()
            #driver.quit()

            # Replace 'WOCKF' with the exact process name you wish to terminate
            kill_process_by_name('chrome.exe')
            time.sleep(10)
    finally:
        if conn:
            conn.close()

def scrape_data(driver, table_name, conn):
    driver.get(f"https://www.msx.om/summary-report.aspx?s={table_name}")
    try:
        time.sleep(10)
        fromDateInput = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.ID, "ctl00_ContentPlaceHolder1_FromDateTextBox"))
        )
        fromDateInput.clear()
        fromDateInput.send_keys("01 Jan 2024")

        toDateInput = WebDriverWait(driver, 10).until(
            EC.element_to_be_clickable((By.ID, "ctl00_ContentPlaceHolder1_ToDateTextBox"))
        )
        toDateInput.clear()
        toDateInput.send_keys("6 Jun 2024")

        showButton = WebDriverWait(driver, 20).until(
            EC.element_to_be_clickable((By.ID, "ShowButton"))
        )
        showButton.click()
        time.sleep(10)
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, 'tbody[role="rowgroup"]'))
        )
        rows = driver.find_elements(By.CSS_SELECTOR, 'tbody[role="rowgroup"] > tr')
        for row in rows:
            cells = row.find_elements(By.TAG_NAME, 'td')
            data = getDataFromRows(cells)
            if data:
                insert_data(conn, data, table_name)

        # Example of pagination handling
        while True:
            try:
                next_page_button = driver.find_element(By.XPATH, '//a[@aria-label="Go to the next page"]')
                if "k-state-disabled" in next_page_button.get_attribute("class"):
                    break
                next_page_button.click()
                WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, 'tbody[role="rowgroup"]'))
                )
                rows = driver.find_elements(By.CSS_SELECTOR, 'tbody[role="rowgroup"] > tr')
                for row in rows:
                    cells = row.find_elements(By.TAG_NAME, 'td')
                    data = getDataFromRows(cells)
                    if data:
                        insert_data(conn, data, table_name)
            except TimeoutException:
                print("Failed to load next page.")
                break

    except TimeoutException:
        print("An element wasn't available.")
    except NoSuchElementException as e:
        print(f"Error: {e}")



cred = credentials.Certificate(firestoreAdminSDKkey)
firebase_admin.initialize_app(cred)
# Initialize Firestore
db = firestore.client()
# Firestore collection reference
collection_ref = db.collection('stocks')
docs = collection_ref.get()  # This will return a generator of documents
# valid_docs = []
# skip_needed = True
# for doc in docs:
#     if skip_needed and not doc.id.startswith('GB4'):
#             continue
#     else:
#         skip_needed = False
#         valid_docs.append(doc)
launchBrowser(chromedriver_path, chrome_executable_path, db_path, docs)
