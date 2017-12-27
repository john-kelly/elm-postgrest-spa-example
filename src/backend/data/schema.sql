drop schema if exists data cascade;
create schema data;
set search_path = data, public;

-- import the type specifying the types of users we have (this is an enum).
-- you most certainly will have to redefine this type for your application
\ir ../libs/auth/data/user_role_type.sql

-- import the default table definition for the user model used by the auth lib
-- you can choose to define the users table yourself if you need additional columns
\ir ../libs/auth/data/user.sql

-- sluggify function
-- NOTE: had to add "with schema public" -- not exaclty sure why.
create extension if not exists unaccent with schema public;
create or replace function slugify(title text) returns text as $$
    select trim(both '-' from regexp_replace(lower(unaccent(title)), '[^a-z0-9]+', '-', 'g'));
$$ language sql;

-- import our application models
\ir article.sql
\ir follow.sql
\ir comment.sql
\ir favorite.sql

-- helper functions
-- NOTE: these appear to NOT be stable? if we add stable, returning the result after
-- create and delete (and probably update) returns the state BEFORE the modification
create or replace function data.get_favorites_count(article_slug text) returns bigint as $$
    select count(*)
    from data.favorite favorite
    where favorite.article_slug = get_favorites_count.article_slug;
$$ security definer language sql;

create or replace function data.is_favorited(article_slug text, user_name text) returns boolean as $$
    select count(*) = 1
    from data.favorite favorite
    where
        favorite.article_slug = is_favorited.article_slug and
        favorite.user_name = is_favorited.user_name;
$$ security definer language sql;

create or replace function data.get_favorited_by(article_slug text) returns text[] as $$
    select coalesce(array_agg(favorite.user_name), '{}')
    from data.favorite favorite
    where favorite.article_slug = get_favorited_by.article_slug;
$$ security definer language sql;

create or replace function data.get_followed_by(user_name text) returns text[] as $$
    select coalesce(array_agg(follow.follower_name), '{}')
    from data.follow follow
    where follow.followed_name = get_followed_by.user_name;
$$ security definer language sql;

create or replace function data.is_following(follower_name text, followed_name text) returns boolean as $$
    select count(*) = 1
    from data.follow follow
    where
        follow.follower_name = is_following.follower_name and
        follow.followed_name = is_following.followed_name;
$$ security definer language sql;
