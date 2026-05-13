import pandas as pd
import random
from datetime import date, timedelta

random.seed(42)

CITIES = [
    ("Paris", "France"),
    ("Lyon", "France"),
    ("Marseille", "France"),
    ("Berlin", "Germany"),
    ("Madrid", "Spain"),
    ("Barcelona", "Spain"),
    ("Rome", "Italy"),
    ("Amsterdam", "Netherlands"),
    ("Brussels", "Belgium"),
    ("London", "UK"),
]

SEGMENTS = ["B2C", "B2B"]

def generate_customers (n=200):
    rows = []
    for i in range(1, n+1):
        city, country = random.choice(CITIES)
        rows.append({
            "customer_id": i,
            "city": city,
            "country": country,
            "segment": random.choice(SEGMENTS),
            "signup_date": date(2022, 1, 1) + timedelta(days=random.randint(0, 365*3))
        })
    return pd.DataFrame(rows)

CATEGORIES = [
    "Electronics",
    "Clothing",
    "Home & Kitchen",
    "Sports",
    "Books",
]

def generate_products(n=50):
    rows = []
    for i in range(1, n + 1):
        category = random.choice(CATEGORIES)
        cost_price = round(random.uniform(5, 200), 2)
        unit_price = round(cost_price * random.uniform(1.3, 2.5), 2)
        rows.append({
            "product_id": i,
            "product_name": f"Product_{i}",
            "category": category,
            "unit_price": unit_price,
            "cost_price": cost_price,
        })
    return pd.DataFrame(rows)

STATUSES = ["completed", "returned", "cancelled"]

def generate_orders(n=2000, n_customers=200):
    rows = []
    for i in range(1, n+1):
        customer_id = random.randint(1, n_customers)
        if customer_id in [1, 2, 3]:
            weights = [30, 60, 10]
        else:
            weights = [70, 20, 10]
        
        rows.append({
            "order_id": i,
            "customer_id": customer_id,
            "order_date": date(2023, 1, 1) + timedelta(days=random.randint(0, 364)),
            "status": random.choices(STATUSES, weights=weights, k=1)[0],
        })
    return pd.DataFrame(rows)

def generate_order_items(df_orders, df_products):
    rows = []
    for _,order in df_orders.iterrows():
        if order["status"] == "cancelled":
            continue
        n_items = random.randint(1,4)
        products = df_products.sample (n=n_items)
        for _, product in products.iterrows():
            rows.append({
                "order_id": order["order_id"],
                "product_id": product["product_id"],
                "quantity": random.randint(1, 5),
                "unit_price": product["unit_price"],
            })
    return pd.DataFrame(rows)

df_customers = generate_customers()
df_customers.to_csv("data/customers.csv", index=False)
print(f"customers.csv saved — {df_customers.shape}")

df_products = generate_products()
df_products.to_csv("data/products.csv", index=False)
print(f"products.csv saved — {df_products.shape}")

df_orders = generate_orders()
df_orders.to_csv("data/orders.csv", index=False)
print(f"orders.csv saved - {df_orders.shape}")

df_order_items = generate_order_items(df_orders, df_products)
df_order_items.to_csv("data/order_items.csv", index=False)
print(f"order_items.csv saved — {df_order_items.shape}")



