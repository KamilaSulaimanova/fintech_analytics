import random
import csv
from datetime import datetime, timedelta

random.seed(42)  # fixed seed = reproducible data every time you run this

OUT = "seeds"

# ---------- customers ----------
first_names = ["James","Maria","Robert","Linda","Michael","Elena","David","Sofia","John","Aisha",
               "William","Grace","Daniel","Chen","Ahmed","Olivia","Lucas","Fatima","Noah","Yuki"]
last_names = ["Smith","Garcia","Johnson","Chen","Brown","Kim","Davis","Ali","Wilson","Nakamura"]
countries = ["US","US","US","GB","DE","FR","CA","AU","SG","NL"]
segments = ["retail","retail","retail","premium","business"]

customers = []
for i in range(1, 201):
    fn, ln = random.choice(first_names), random.choice(last_names)
    signup = datetime(2021,1,1) + timedelta(days=random.randint(0, 1400))
    customers.append({
        "customer_id": f"CUST{i:05d}",
        "first_name": fn,
        "last_name": ln,
        "email": f"{fn.lower()}.{ln.lower()}{i}@example.com",
        "country": random.choice(countries),
        "customer_segment": random.choice(segments),
        "signup_date": signup.strftime("%Y-%m-%d"),
        "date_of_birth": (datetime(1955,1,1)+timedelta(days=random.randint(0, 18000))).strftime("%Y-%m-%d"),
    })

with open(f"{OUT}/raw_customers.csv","w",newline="") as f:
    w = csv.DictWriter(f, fieldnames=customers[0].keys())
    w.writeheader(); w.writerows(customers)

print(f"customers={len(customers)}")


# ---------- accounts ----------
account_types = ["checking","checking","savings","savings","credit_card"]
statuses = ["active","active","active","active","closed","frozen"]
currencies = ["USD","USD","USD","EUR","GBP"]

accounts = []
acct_id = 1
for c in customers:
    n_accounts = random.choices([1,2,3],[0.5,0.35,0.15])[0]
    signup_dt = datetime.strptime(c["signup_date"], "%Y-%m-%d")
    for _ in range(n_accounts):
        opened = signup_dt + timedelta(days=random.randint(0,60))
        status = random.choice(statuses)
        closed_date = ""
        if status == "closed":
            closed_dt = opened + timedelta(days=random.randint(60,900))
            if closed_dt < datetime(2024,12,31):
                closed_date = closed_dt.strftime("%Y-%m-%d")
            else:
                status = "active"  # would close in the future — just keep it open instead
        accounts.append({
            "account_id": f"ACCT{acct_id:06d}",
            "customer_id": c["customer_id"],
            "account_type": random.choice(account_types),
            "currency": random.choice(currencies),
            "opened_date": opened.strftime("%Y-%m-%d"),
            "closed_date": closed_date,
            "status": status,
        })
        acct_id += 1

with open(f"{OUT}/raw_accounts.csv","w",newline="") as f:
    w = csv.DictWriter(f, fieldnames=accounts[0].keys())
    w.writeheader(); w.writerows(accounts)

print(f"accounts={len(accounts)}")


# ---------- transactions ----------
txn_types = ["purchase","purchase","purchase","deposit","withdrawal","transfer","fee","refund"]
txn_status = ["posted","posted","posted","posted","pending","failed"]

merchant_ids = ["MERCH0001","MERCH0002","MERCH0003","MERCH0004","MERCH0005",
                "MERCH0006","MERCH0007","MERCH0008","MERCH0009","MERCH0010"]

transactions = []
txn_id = 1
window_start = datetime(2024,1,1)
window_end = datetime(2024,12,31)

for a in accounts:
    opened = datetime.strptime(a["opened_date"], "%Y-%m-%d")
    closed = datetime.strptime(a["closed_date"], "%Y-%m-%d") if a["closed_date"] else window_end
    lo = max(opened, window_start)
    hi = min(closed, window_end)
    if lo >= hi:
        continue  # account wasn't open at all during our 2024 window — skip it
    span_days = (hi - lo).days
    n_txns = random.randint(5, 35)
    for _ in range(n_txns):
        d = lo + timedelta(days=random.randint(0, span_days))
        ttype = random.choice(txn_types)
        merchant = random.choice(merchant_ids) if ttype in ("purchase","refund") else ""

        if ttype == "purchase":
            amount = -round(random.uniform(3, 450), 2)
        elif ttype == "refund":
            amount = round(random.uniform(3, 200), 2)
        elif ttype == "deposit":
            amount = round(random.uniform(50, 5000), 2)
        elif ttype == "withdrawal":
            amount = -round(random.uniform(20, 800), 2)
        elif ttype == "transfer":
            amount = round(random.choice([-1,1]) * random.uniform(20, 2000), 2)
        else:  # fee
            amount = -round(random.uniform(1, 35), 2)

        transactions.append({
            "transaction_id": f"TXN{txn_id:08d}",
            "account_id": a["account_id"],
            "transaction_date": d.strftime("%Y-%m-%d"),
            "transaction_type": ttype,
            "amount": amount,
            "currency": a["currency"],
            "merchant_id": merchant,
            "status": random.choice(txn_status),
        })
        txn_id += 1

transactions.sort(key=lambda r: r["transaction_date"])
with open(f"{OUT}/raw_transactions.csv","w",newline="") as f:
    w = csv.DictWriter(f, fieldnames=transactions[0].keys())
    w.writeheader(); w.writerows(transactions)

print(f"transactions={len(transactions)}")


