use actix_web::{web, HttpRequest, HttpResponse, Responder};
use crate::schema::pet::dsl::*;
use crate::models::*;
use crate::diesel::*;

pub(crate) fn root(_req: HttpRequest) -> impl Responder {
    format!("/")
}

pub(crate) fn configure(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::resource("/pets")
            .route(web::get().to(list_pets))
            .route(web::head().to(|| HttpResponse::MethodNotAllowed())),
    );
}

fn list_pets(req: HttpRequest) -> impl Responder {
    let connection = crate::establish_connection();
    let p = pet.load::<Pet>(&connection).unwrap();
    let limit = req.match_info().get("limit");
    format!("list_pets with limit={:?}", p)
}
