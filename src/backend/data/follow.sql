create table follow (
    follower_name text references users(name) on delete cascade default request.user_name(),
    followed_name text references users(name) on delete cascade not null,
    primary key (follower_name, followed_name),
    check (follower_name != followed_name)
);
