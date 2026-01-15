import pandas as pd
from sqlalchemy import create_engine, text
import hashlib
import logging
from datetime import datetime
import os
from dotenv import load_dotenv
import os

load_dotenv("config/.env")

DB_URI = os.getenv("DB_URI")
# ==============================
# CONFIG
# ==============================

DB_URI = "postgresql+psycopg2://postgres:newpassword@127.0.0.1:5432/capstone2"
CSV_FOLDER = "bronze_inputs/"
LOG_FILE = "logs/bronze_load.log"

tables = {
    "riders": "riders.csv",
    "drivers": "drivers.csv",
    "rides": "rides.csv",
    "payments": "payments.csv",
    "driver_shifts": "driver_shifts.csv"
}

# ==============================
# LOGGING SETUP
# ==============================

os.makedirs("logs", exist_ok=True)

logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)

# ==============================
# DB CONNECTION
# ==============================

engine = create_engine(DB_URI)

# ==============================
# BRONZE LOAD
# ==============================

for table, csv_file in tables.items():
    start_time = datetime.now()

    try:
        df = pd.read_csv(os.path.join(CSV_FOLDER, csv_file))
        rows = len(df)

        # Row-level checksum (stable & reproducible)
        checksum = hashlib.md5(
            pd.util.hash_pandas_object(df, index=True).values
        ).hexdigest()

        # Load into bronze schema
        df.to_sql(
            table,
            engine,
            schema="bronze",
            if_exists="replace",
            index=False,
            method="multi"
        )

        # Log to DB audit table
        with engine.begin() as conn:
            conn.execute(
                text("""
                    INSERT INTO audit.bronze_load_log
                    (table_name, file_name, row_count, checksum)
                    VALUES (:table, :file, :rows, :checksum)
                """),
                {
                    "table": table,
                    "file": csv_file,
                    "rows": rows,
                    "checksum": checksum
                }
            )

        elapsed = datetime.now() - start_time

        logging.info(
            f"TABLE={table} | ROWS={rows} | CHECKSUM={checksum} | STATUS=SUCCESS | TIME={elapsed}"
        )

        print(f"✅ Loaded bronze.{table}: {rows} rows")

    except Exception as e:
        logging.error(
            f"TABLE={table} | STATUS=FAILED | ERROR={str(e)}"
        )
        print(f"❌ Failed loading {table}: {e}")
