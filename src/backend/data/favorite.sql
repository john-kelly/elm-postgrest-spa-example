create table favorite (
    user_name text references users(name)  on delete cascade default request.user_name(),
    article_slug text references article(slug) on delete cascade not null,
    primary key (user_name, article_slug)
);
