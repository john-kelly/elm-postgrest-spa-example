-- define the view which is just selecting everything from the underlying table
-- although it looks like a user would see all the rows by looking just at this definition,
-- the RLS policy defined on the underlying table attached to the view owner (api)
-- will make sure only the appropriate roles will be reviled.
-- also, while our table name is "article", singular, meant to symbolize a data type/model,
-- the view is named "articles", plural, to match the rest conventions.
create or replace view articles as
select
    slug,
    title,
    description,
    body,
    created_at,
    updated_at,
    author_name,
    tags,
    (author_name = request.user_name()) as mine,
    data.get_favorites_count(slug) as favorites_count,
    data.is_favorited(slug, request.user_name()) as favorited,
    data.get_favorited_by(slug) as favorited_by,
    data.get_followed_by(author_name) as followed_by
from data.article;

-- it is important to set the correct owner to the RLS policy kicks in
alter view articles owner to api;

create or replace view tags as
select distinct unnest(tags) as name
from data.article;
alter view tags owner to api;
