select settings.set('auth.data-schema', current_schema);

create table users (
    name text primary key,
    email text not null unique,
    image text,
    bio text,
    "password" text not null,
    "role" user_role not null default settings.get('auth.default-role')::user_role,
    check (length(name) > 2),
    check (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

create trigger user_encrypt_pass_trigger
-- removed "or update" b/c on user update pass was double encrypting
before insert on users
for each row
execute procedure auth.encrypt_pass();
