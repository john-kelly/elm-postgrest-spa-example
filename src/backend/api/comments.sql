create or replace view comments as
select
    id,
    body,
    article_slug,
    author_name,
    created_at,
    updated_at
from data.comment;
alter view comments owner to api;
