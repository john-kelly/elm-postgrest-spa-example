\echo # Loading roles privilege

-- this file contains the privileges of all aplications roles to each database entity
-- if it gets too long, you can split it one file per entity

-- set default privileges to all the entities created by the auth lib
select auth.set_auth_endpoints_privileges('api', :'anonymous', enum_range(null::data.user_role)::text[]);

-- specify which application roles can access this api (you'll probably list them all)
-- remember to list all the values of user_role type here
grant usage on schema api to anonymous, webuser;

-- enable RLS on the table holding the data
-------------------------------------------------------------------------------
-- article privileges
alter table data.article enable row level security;
create policy article_access_policy on data.article to api
using (
	true
)
with check (
	(request.user_role() = 'webuser' and request.user_name() = author_name)
);
grant select, insert, update, delete on data.article to api;
grant select, insert, update, delete on api.articles to webuser;
grant select on api.articles to anonymous;
grant select on api.tags to webuser, anonymous;
-------------------------------------------------------------------------------
-- user privileges
alter table data.users enable row level security;
create policy user_access_policy on data.users to api
using (
	true
)
with check (
	(request.user_role() = 'webuser' and request.user_name() = name)
);
grant select, insert, update, delete on data.users to api;
grant select, insert, update, delete on api.profiles to webuser;
grant select on api.profiles to anonymous;
-------------------------------------------------------------------------------
-- follow privileges
alter table data.follow enable row level security;
create policy follow_access_policy on data.follow to api
using (
    -- FIXME: not sure why this is required to get rls for DELETE working.
    (request.user_role() = 'webuser' and request.user_name() = follower_name)
)
with check (
    -- only the follower can edit their follow
    (request.user_role() = 'webuser' and request.user_name() = follower_name)
);
grant select, insert, update, delete on data.follow to api;
grant select, insert, update, delete on api.follows to webuser;
grant select on api.follows to anonymous;
-------------------------------------------------------------------------------
-- comment privileges
alter table data.comment enable row level security;
create policy comment_access_policy on data.comment to api
using (
	true
)
with check (
    -- only the commenter can edit their comment
    (request.user_role() = 'webuser' and request.user_name() = author_name)
);
grant select, insert, update, delete on data.comment to api;
grant usage on data.comment_id_seq to webuser;
grant select, insert, update, delete on api.comments to webuser;
grant select on api.comments to anonymous;
-------------------------------------------------------------------------------
-- favorite privileges
alter table data.favorite enable row level security;
create policy favorite_access_policy on data.favorite to api, webuser
using (
    -- FIXME: not sure why this is required to get rls for DELETE working.
    (request.user_role() = 'webuser' and request.user_name() = user_name)
)
with check (
    -- only the favoriter can edit their favorite
    (request.user_role() = 'webuser' and request.user_name() = user_name)
);
grant select, insert, update, delete on data.favorite to api;
grant select, insert, update, delete on api.favorites to webuser;
grant select on api.favorites to anonymous;
-------------------------------------------------------------------------------
