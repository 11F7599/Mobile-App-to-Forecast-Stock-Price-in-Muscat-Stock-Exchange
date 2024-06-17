import os
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
import sqlite3
import uvicorn
from datetime import datetime

db_directory = r'C:\Users\tryho\OneDrive\Desktop\MSX Plus Project\StockData'
db_path = os.path.join(db_directory, 'StockHistoricalData.db')

app = FastAPI()

# Define a Pydantic model for the stock data
class StockData(BaseModel):
    date: str
    open_price: float
    high_price: float
    low_price: float
    trades: int
    volume: int
    turnover: int
    close_price: float
    net_change: float
    percentage_change: float

# Function to connect to the SQLite database
def connect_db():
    return sqlite3.connect(db_path)

# Function to fetch all stock data from the appropriate table
def get_all_stock_data(symbol: str):
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM {symbol}")
    data = cursor.fetchall()
    conn.close()
    return data

# Function to fetch stock data from the appropriate table with optional date range filtering
def get_stock_data(symbol: str, start_date: str = None, end_date: str = None):
    conn = connect_db()
    cursor = conn.cursor()
    query = f"SELECT * FROM {symbol}"
    if start_date and end_date:
        query += f" WHERE date BETWEEN '{start_date}' AND '{end_date}'"
    elif start_date:
        query += f" WHERE date >= '{start_date}'"
    elif end_date:
        query += f" WHERE date <= '{end_date}'"
    cursor.execute(query)
    data = cursor.fetchall()
    conn.close()
    return data

# Route to get all stock data for a specific symbol
@app.get("/stock/{symbol}/all", response_model=list[StockData])
async def read_all_stock_data(symbol: str):
    data = get_all_stock_data(symbol)
    if not data:
        raise HTTPException(status_code=404, detail=f"No data found for symbol {symbol}")
    return [
        {
            "date": row[0],
            "open_price": row[1],
            "high_price": row[2],
            "low_price": row[3],
            "trades": row[4],
            "volume": row[5],
            "turnover": row[6],
            "close_price": row[7],
            "net_change": row[8],
            "percentage_change": row[9]
        }
        for row in data
    ]

# Route to get stock data for a specific symbol with optional date range filtering
@app.get("/stock/{symbol}/filtered", response_model=list[StockData])
async def read_stock_data(
    symbol: str,
    start_date: str = Query(None, description="Start date to filter data", regex=r"\d{4}-\d{2}-\d{2}"),
    end_date: str = Query(None, description="End date to filter data", regex=r"\d{4}-\d{2}-\d{2}")
):
    data = get_stock_data(symbol, start_date, end_date)
    if not data:
        raise HTTPException(status_code=404, detail=f"No data found for symbol {symbol} within the specified date range")
    return [
        {
            "date": row[0],
            "open_price": row[1],
            "high_price": row[2],
            "low_price": row[3],
            "trades": row[4],
            "volume": row[5],
            "turnover": row[6],
            "close_price": row[7],
            "net_change": row[8],
            "percentage_change": row[9]
        }
        for row in data
    ]



# # Function to fetch the newest stock data record for a specific symbol
# def get_newest_stock_data(symbol: str):
#     with connect_db() as conn:
#         cursor = conn.cursor()
#         # Order by date descending to get the newest record first
#         query = f"SELECT * FROM {symbol} ORDER BY date DESC LIMIT 1"
#         cursor.execute(query)
#         data = cursor.fetchone()  # Use fetchone() as we only expect one record
#         if not data:
#             raise HTTPException(status_code=404, detail=f"No data found for symbol {symbol}")
#         return data

# # Route to get the newest stock data for a specific symbol
# @app.get("/stock/{symbol}/newest", response_model=StockData)
# async def read_newest_stock_data(symbol: str):
#     data = get_newest_stock_data(symbol)
#     return {
#         "date": data[0],
#         "open_price": data[1],
#         "high_price": data[2],
#         "low_price": data[3],
#         "trades": data[4],
#         "volume": data[5],
#         "turnover": data[6],
#         "close_price": data[7],
#         "net_change": data[8],
#         "percentage_change": data[9]
#     }




if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9000)
