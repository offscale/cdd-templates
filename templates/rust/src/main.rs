use actix_web::{web, App};
use diesel::sqlite::*;

mod routes;
mod models;
mod schema;

pub fn establish_connection() -> SqliteConnection {
    use diesel::prelude::*;
    SqliteConnection::establish("localhost")
        .expect(&format!("Error connecting to database."))
}

fn main() -> Result<(), std::io::Error> {
    let connection = establish_connection();
    connection.pet;

    let port: u16 = std::env::var("PORT")
        .unwrap_or("8000".to_string())
        .parse::<u16>()
        .unwrap_or(8000);

    actix_web::HttpServer::new(|| {
        App::new()
            .configure(routes::configure)
            .route("/", web::get().to(routes::root))
    })
    .bind(format!("127.0.0.1:{}", port))
    .expect(&*format!("Can not bind to port {}", port))
    .run()
}
