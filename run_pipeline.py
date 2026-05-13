import duckdb
conn = duckdb.connect("ecompulse.duckdb")

print("Ecompulse Pipeline")
print("=" * 40)

print("\n[1/4] Loading raw tables...")
conn.execute(open("sql/01_create_tables.sql").read())

print("\n[2/4] Creating staging views...")
conn.execute(open("sql/02_staging.sql").read())

print("\n[3/4] Creating analytics views...")
conn.execute(open("sql/03_analytics.sql").read())

print("\n[4/4] Exporting outputs tables...")
conn.execute(open("sql/04_outputs.sql").read())

conn.close()
print("Pipeline complete.")
