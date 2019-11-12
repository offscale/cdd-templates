# CDD Rust Server

## Installation

```bash
# install diesel
apt-get install libsqlite3-dev
cargo install diesel_cli --no-default-features --features sqlite
diesel print-schema --database-url=database.sql > src/schema.rs
```
