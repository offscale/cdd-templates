table! {
    error (code) {
        code -> Nullable<Integer>,
        message -> Nullable<Integer>,
    }
}

table! {
    pet (id) {
        id -> Nullable<Integer>,
        name -> Nullable<Text>,
    }
}

allow_tables_to_appear_in_same_query!(
    error,
    pet,
);
