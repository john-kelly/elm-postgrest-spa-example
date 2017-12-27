Generated via pgdump: `pg_dump --schema=data --data-only app > dump.sql`


2 changes were made:
1. adding public to search path. this was necessary for encrypt_pass
2. changing passwords to be raw instead of hashed. (ex. (before) asdf7asdfasdfashdfla -> (after) pass)
