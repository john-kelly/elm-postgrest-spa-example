create or replace view follows as
select
    follower_name,
    followed_name
from data.follow;
alter view follows owner to api;
