create or replace view favorites as
select
    user_name,
    article_slug
from data.favorite;
alter view favorites owner to api;
