-- NOTE: generated automatically via pgdump.
-- 2 changes were made:
-- 1.) adding public to search path. this was necessary for encrypt_pass
-- 2.) changing passwords to be raw instead of hashed. (ex. (before) asdf7asdfasdfashdfla -> (after) pass)


--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = data, public, pg_catalog;

--
-- Data for Name: users; Type: TABLE DATA; Schema: data; Owner: john-kelly
--

COPY users (name, email, image, bio, password, role) FROM stdin;
john	john@email.com	\N	this is my bio	pass	webuser
\.


--
-- Data for Name: article; Type: TABLE DATA; Schema: data; Owner: john-kelly
--

COPY article (slug, title, description, body, created_at, updated_at, author_name, tags) FROM stdin;
test-world	test world	hello 	nice	2017-12-21	2017-12-21	john	{}
\.


--
-- Data for Name: comment; Type: TABLE DATA; Schema: data; Owner: john-kelly
--

COPY comment (id, body, author_name, article_slug, created_at, updated_at) FROM stdin;
1	hello world.	john	test-world	2017-12-21	2017-12-21
2	just another one.	john	test-world	2017-12-21	2017-12-21
3	and just one more.	john	test-world	2017-12-21	2017-12-21
\.


--
-- Data for Name: follow; Type: TABLE DATA; Schema: data; Owner: john-kelly
--

COPY follow (follower_name, followed_name) FROM stdin;
\.


--
-- Name: comment_id_seq; Type: SEQUENCE SET; Schema: data; Owner: john-kelly
--

SELECT pg_catalog.setval('comment_id_seq', 3, true);


--
-- PostgreSQL database dump complete
--
