use diesel::Queryable;

#[derive(Queryable, Debug)]
pub struct Pet {
    pub id: i32,
    pub name: String,
}
