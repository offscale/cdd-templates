use actix_web::{http::Method, server, App, HttpRequest, Path, Responder};

fn index(_req: HttpRequest) -> impl Responder {
    "Hello from the index page"
}

fn hello(path: Path<String>) -> impl Responder {
    format!("Hello {}!", *path)
}

fn main() {
    let port: u16 = std::env::var("PORT")
        .unwrap_or("8000".to_string())
        .parse::<u16>()
        .unwrap_or(8000);

    server::new(|| {
        vec![App::new()
            .resource("/", |r| r.method(Method::GET).with(index))
            .resource("/hello/{name}", |r| r.method(Method::GET).with(hello))]
    })
    .bind(format!("127.0.0.1:{}", port))
    .expect(&*format!("Can not bind to port {}", port))
    .run();
}
