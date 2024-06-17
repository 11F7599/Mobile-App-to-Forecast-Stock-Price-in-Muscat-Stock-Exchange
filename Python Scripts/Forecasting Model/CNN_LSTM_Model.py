import sqlite3
import pandas as pd
import numpy as np
import os
# Disable oneDNN optimizations for consistency across different platforms
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, LSTM, Conv1D, MaxPooling1D, Dropout, Input
from sklearn.model_selection import train_test_split
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
import tensorflow as tf
import firebase_admin
from firebase_admin import credentials, firestore


firestoreAdminSDKkey = r"C:\Users\tryho\OneDrive\Desktop\MSX Plus Project\Python Scripts\msx-plus-firebase-adminsdk-ez5aq-1991bf8f2b.json"
cred = credentials.Certificate(firestoreAdminSDKkey)
firebase_admin.initialize_app(cred)
# Initialize Firestore
db = firestore.client()
# Firestore collection reference
collection_ref = db.collection('stocks')


sequence_length = 20  # The number of days in each sequence
batch_size = 32  # Batch size for training
epochs = 50  # Number of epochs for training
# Database path
DB_Path = r"C:\Users\tryho\OneDrive\Desktop\MSX Plus Project\StockData\StockHistoricalData.db"

# Connect to the SQLite database
conn = sqlite3.connect(DB_Path)
print("Connected to database successfully.")

tables = pd.read_sql("SELECT name FROM sqlite_master WHERE type='table';", conn)
tables = tables['name'].tolist()

for table in tables:
    print(f"Processing table: {table}")
    query = f"SELECT date, openPrice, highPrice, lowPrice, volume, closePrice FROM {table}"
    df = pd.read_sql(query, conn, parse_dates=['date'], index_col='date')

    if len(df) < sequence_length:
        print(f"Not enough data to process for {table}. Needed: {sequence_length}, found: {len(df)}")
        continue

    # Preparing the scaler and scaling the closePrice for inverse transform later
    close_price_scaler = MinMaxScaler()
    df['closePrice_scaled'] = close_price_scaler.fit_transform(df[['closePrice']])

    # Other features scaling
    scaler = MinMaxScaler(feature_range=(0, 1))
    scaled_features = scaler.fit_transform(df[['openPrice', 'highPrice', 'lowPrice', 'volume', 'closePrice_scaled']])

    # Function to create sequences
    def create_sequences(data, seq_length):
        xs, ys = [], []
        for i in range(len(data) - seq_length):
            x_part = data[i:(i + seq_length)]
            y_part = data[i + seq_length, -1]  # last column is closePrice_scaled
            xs.append(x_part)
            ys.append(y_part)
        return np.array(xs), np.array(ys)

    X, y = create_sequences(scaled_features, sequence_length)
    
    if len(X) < 2 or len(y) < 2:  # Ensure there are at least 2 samples for splitting
        print(f"Not enough data after sequence creation for {table}.")
        continue

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    if len(X_train) == 0 or len(X_test) == 0 or len(y_train) == 0 or len(y_test) == 0:
        print(f"Not enough data to split into training and testing sets for {table}.")
        continue

    # Building the model
    model = Sequential([
        Input(shape=(sequence_length, 5)),
        Conv1D(64, 2, activation='relu'),
        MaxPooling1D(2),
        Dropout(0.1),
        LSTM(50, return_sequences=True),
        Dropout(0.1),
        LSTM(50),
        Dense(1)
    ])
    model.compile(optimizer='adam', loss='mse')
    es = EarlyStopping(monitor='val_loss', mode='min', patience=10)
    mc = ModelCheckpoint('best_model.keras', monitor='val_loss', mode='min', save_best_only=True)

    model.fit(X_train, y_train, epochs=epochs, batch_size=batch_size, validation_data=(X_test, y_test), callbacks=[es, mc])

    # Load the best model
    best_model = tf.keras.models.load_model('best_model.keras')
    
    # Predict using the last sequence from X_test
    last_sequence = X_test[-1].reshape(1, sequence_length, 5)
    predicted_scaled_price = best_model.predict(last_sequence)
    predicted_price = close_price_scaler.inverse_transform(predicted_scaled_price)

    print(f"Predicted next day price for {table}: {predicted_price[0][0]}")

    doc_ref = collection_ref.document(table)
    if doc_ref.get().exists:
        doc_ref.update({
            "predictedClosePrice": str(round(predicted_price[0][0], 3)),
        })

# Close the database connection
conn.close()
print("Database connection closed.")
