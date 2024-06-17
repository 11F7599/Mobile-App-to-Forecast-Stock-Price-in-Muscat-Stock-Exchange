import firebase_admin
from firebase_admin import credentials, firestore, messaging

# Initialize Firebase Admin SDK
cred = credentials.Certificate(r"C:\Users\tryho\OneDrive\Desktop\MSX Plus Project\Python Scripts\msx-plus-firebase-adminsdk-ez5aq-1991bf8f2b.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

def send_notification(token, title, body):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        token=token,
    )
    response = messaging.send(message)
    print('Successfully sent message:', response)

def check_and_notify():
    users_ref = db.collection('users')
    users = users_ref.stream()

    for user in users:
        user_data = user.to_dict()
        watchlist_ref = user.reference.collection('watchlist')
        watchlist = watchlist_ref.stream()

        for stock in watchlist:
            stock_data = stock.to_dict()
            stock_id = stock.id

            # Fetch the current price from the 'stocks' collection
            stock_ref = db.collection('stocks').document(stock_id)
            stock_snapshot = stock_ref.get()
            stock_info = stock_snapshot.to_dict()

            # Check if the stock_data has 'onPrice' and stock_info has 'price'
            if 'onPrice' in stock_data and stock_info and 'price' in stock_info:
                if stock_data['onDirection'] == "up":
                    if stock_info['price'] >= stock_data['onPrice']:
                        title = 'Stock Price Alert'
                        body = (f'The stock {stock_id} has reached your target price of '
                                f'{stock_data["onPrice"]}. Current price: {stock_info["price"]}')
                        if 'token' in user_data:
                            send_notification(user_data['token'], title, body)
                        # Set alert to false after sending notification
                        stock.reference.set({'alert': False})
                if stock_data['onDirection'] == "down":
                    if stock_info['price'] <= stock_data['onPrice']:
                        title = 'Stock Price Alert'
                        body = (f'The stock {stock_id} has reached your target price of '
                                f'{stock_data["onPrice"]}. Current price: {stock_info["price"]}')
                        if 'token' in user_data:
                            send_notification(user_data['token'], title, body)
                        # Set alert to false after sending notification
                        stock.reference.set({'alert': False})

if __name__ == "__main__":
    check_and_notify()
