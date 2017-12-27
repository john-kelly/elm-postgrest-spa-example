select settings.set('auth.api-schema', current_schema);
create type users as (name text, email text, role text, bio text, image text);
