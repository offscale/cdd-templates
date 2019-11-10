use actix_web::{web, HttpRequest, HttpResponse, Responder};

pub(crate) fn root(_req: HttpRequest) -> impl Responder {
    format!("hello")
}

pub(crate) fn configure(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::resource("/pets")
            .route(web::get().to(list_pets))
            .route(web::head().to(|| HttpResponse::MethodNotAllowed())),
    );
}

fn list_pets(req: HttpRequest) -> impl Responder {
    let limit = req.match_info().get("limit");
    format!("list_pets with limit={:?}", limit)
}
