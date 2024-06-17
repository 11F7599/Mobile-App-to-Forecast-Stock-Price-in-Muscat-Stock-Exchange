import logging
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
import time
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from concurrent.futures import ThreadPoolExecutor
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import firebase_admin
from firebase_admin import credentials, firestore

# Suppress font decoding warnings
logging.getLogger('weasyprint').setLevel(logging.ERROR)
logging.getLogger('urllib3').setLevel(logging.ERROR)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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

# Create a custom HTTPAdapter with a larger connection pool size
# retry_policy = Retry(total=10, backoff_factor=1, status_forcelist=[500, 502, 503, 504])
# http_adapter = HTTPAdapter(pool_connections=200, pool_maxsize=200, max_retries=retry_policy)

def scrape_stock_info(li):
    try:
        parent_ul = li.find_element(By.XPATH, '..')
        price_li = parent_ul.find_element(By.CLASS_NAME, "column2")

        companyName_element = li.find_element(By.TAG_NAME, "a")
        tickerSymbol_i = companyName_element.find_element(By.TAG_NAME, "i").text
        tickerSymbol = tickerSymbol_i[1:-1].strip()

        split_text = price_li.text.split('\n')
        price = split_text[0] if len(split_text) > 0 else "N/A"
        change = split_text[1] if len(split_text) > 1 else "N/A"

        em_element = price_li.find_element(By.TAG_NAME, "em").get_attribute("class")
        if "green-r" in em_element:
            direction = UP
        elif "red-r" in em_element:
            direction = DOWN
        else:
            direction = NO_CHANGE

        doc_ref = collection_ref.document(tickerSymbol)
        if doc_ref.get().exists:
            doc_ref.update({
                "closePrice": price.strip(),
                "change": change.strip(),
                "direction": direction,
            })
            logger.info(f"Document {tickerSymbol} updated.")
        else:
            logger.warning(f"Document {tickerSymbol} not exist.")
            uniqueID = li.find_element(By.TAG_NAME, "span").get_attribute("data-rel").strip()
            companyName_element2 = companyName_element.text
            companyName = companyName_element2.replace(tickerSymbol_i, '').strip()
            dataMarket = li.find_element(By.XPATH, "../..").get_attribute("id").strip()
            category = li.find_element(By.XPATH, "../..").find_element(By.XPATH, "preceding-sibling::*[1]").find_element(By.TAG_NAME, "h2").text.strip()
            doc_ref.set({
                "uniqueID": uniqueID,
                "companyName": companyName,
                "category": category,
                "closePrice": price.strip(),
                "change": change.strip(),
                "direction": direction,
                "containerID": dataMarket
            })
            logger.info(f"Document {tickerSymbol} added.")

    except NoSuchElementException as e:
        logger.error(f"Span element not found in the li element: {e}")
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")

def launchBrowser():
    service = Service(executable_path=chromedriver_path)
    options = webdriver.ChromeOptions()
    options.binary_location = chrome_executable_path
    options.add_argument('--enable-chrome-browser-cloud-management')
    options.add_argument('--no-sandbox')

    with webdriver.Chrome(service=service, options=options) as driver:
        try:
            driver.get("https://www.msx.om/market-watch-custom.aspx")
            WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "market-1"))
            )

            while True:
                start_time = time.time()
                try:
                    # # Refresh the page for updated data
                    # driver.refresh()
                    # WebDriverWait(driver, 10).until(
                    #     EC.presence_of_element_located((By.ID, "market-1"))
                    # )

                    # Find all li elements with class 'pos-re' (column1)
                    li_elements = driver.find_elements(By.CSS_SELECTOR, "li.pos-re")

                    # Use ThreadPoolExecutor for parallel execution
                    with ThreadPoolExecutor(max_workers=1) as executor:
                        # Submit tasks to the ThreadPoolExecutor
                        for li in li_elements:
                            executor.submit(scrape_stock_info, li)

                except TimeoutException:
                    logger.error("Timed out waiting for the element to become visible.")
                    driver.save_screenshot("timeout_exception.png")

                except Exception as e:
                    logger.error(f"An unexpected error occurred during scraping: {e}")
                finally:
                    end_time = time.time()
                    elapsed_time = end_time - start_time
                    logger.info("Data has been successfully updated")
                    logger.info(f"Time taken: {elapsed_time} seconds")

                    # Sleep for a specific duration before the next iteration
                    time.sleep(10)  # Adjust this as needed

        except Exception as e:
            logger.error(f"An unexpected error occurred in the main loop: {e}")
        finally:
            # Any necessary cleanup can be performed here
            logger.info("Browser automation session has ended.")

# Run the script
if __name__ == "__main__":
    launchBrowser()