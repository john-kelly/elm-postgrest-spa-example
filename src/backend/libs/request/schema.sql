drop schema if exists request cascade;
create schema request;
grant usage on schema request to public;

create or replace function request.env_var(v text) returns text as $$
    select current_setting(v, true);
$$ stable language sql;

create or replace function request.jwt_claim(c text) returns text as $$
    select request.env_var('request.jwt.claim.' || c);
$$ stable language sql;

create or replace function request.cookie(c text) returns text as $$
    select request.env_var('request.cookie.' || c);
$$ stable language sql;

create or replace function request.header(h text) returns text as $$
    select request.env_var('request.header.' || h);
$$ stable language sql;

create or replace function request.user_name() returns text as $$
    select
    case request.jwt_claim('user_name')
    when '' then '' -- NOTE: changed this from 0 to '' when changed from int to text. not sure if 0 implementation detail mattered anywhere.
    else request.jwt_claim('user_name')::text
	end
$$ stable language sql;

create or replace function request.user_role() returns text as $$
    select request.jwt_claim('role')::text;
$$ stable language sql;
