import_schema:
	diesel print-schema --database-url database.sql > src/schema.rs

setup_database:
	cat ../schema.sql | sqlite3 database.sql