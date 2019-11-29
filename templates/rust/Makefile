generate_schema:
	diesel print-schema --database-url database.sql > src/schema.rs

import_schema:
	cat ../schema.sql | sqlite3 database.sql