create table article (
    slug text primary key,

    title text not null,
    description text not null,
    body text not null,

    -- TODO: this field should be read only
    created_at date not null default now(),

    -- TODO: need to update in trigger
    -- TODO: this field should be read only
    updated_at date not null default now(),

    author_name text references users(name) on delete cascade default request.user_name(),

    -- FIXME: trigger for unique
    tags text[] not null default '{}'
);

create or replace function slugify_article_title () returns trigger as $$
begin
    new.slug = data.slugify(new.title);
    return new;
end
$$ security definer language plpgsql;

create trigger article_slugify_title_trigger
before insert on article
for each row
execute procedure slugify_article_title();
