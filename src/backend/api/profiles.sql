create or replace view profiles as
select
    name,
    email,
    image,
    bio,
    data.is_following(request.user_name(), name) as following
from data.users;

alter view profiles owner to api;
