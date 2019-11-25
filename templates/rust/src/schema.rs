table! {
    error (code) {
        code -> Nullable<Integer>,
        message -> Nullable<Integer>,
    }
}

table! {
    pet {
        id -> Integer,
        name -> Text,
    }
}

allow_tables_to_appear_in_same_query!(
    error,
    pet,
);
