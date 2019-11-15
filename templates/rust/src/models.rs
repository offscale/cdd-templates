use diesel::Queryable;

#[derive(Queryable)]
pub struct Pet {
    pub id: i32,
    pub name: String,
}
