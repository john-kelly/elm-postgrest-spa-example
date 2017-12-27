create table comment (
    id serial primary key,
    body text not null,
    author_name text references users(name) on delete cascade default request.user_name(),
    article_slug text references article(slug) on delete cascade not null,

    -- TODO: this field should be read only
    created_at date not null default now(),

    -- TODO: need to update in trigger
    -- TODO: this field should be read only
    updated_at date not null default now()
);
