module Request.Schema
    exposing
        ( article, Article
        , profile, Profile
        , comment, Comment
        , follow, Follow
        , favorite, Favorite
        , tag, Tag
        )

import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Extra
import Date
import Data.Article as Article
import Data.Article.Comment as Comment
import Data.User as User
import Data.UserPhoto as UserPhoto

import PostgRest as PG


date : String -> PG.Attribute Date.Date
date =
    PG.attribute
        { decoder = Json.Decode.Extra.date
        -- FIXME: totally wrong but fine for now.
        , encoder = toString >> Encode.string
        , urlEncoder = toString
        }

type Article = Article

article =
    PG.schema Article "articles"
        { description = PG.string "description"
        , slug = Article.slugAttribute "slug"
        , title = PG.string "title"
        , createdAt = date "created_at"
        , updatedAt = date "updated_at"
        , favorited = PG.bool "favorited"
        , favoritesCount = PG.int "favorites_count"
        , authorName = User.usernameAttribute "author_name"
        , body = Article.bodyAttribute "body"
        , tagStrings = PG.list (PG.string "tags")
        , tags = PG.list (Article.tagAttribute "tags")
        , favoritedBy = PG.list (User.usernameAttribute "favorited_by")
        , followedBy = PG.list (User.usernameAttribute "followed_by")
        , stringBody = Article.stringBodyAttribute "body"
        , author = PG.hasOne_ "author_name" Profile
        }


type Profile = Profile


profile =
    PG.schema Profile "profiles"
        { name = User.usernameAttribute "name"
        , nameString = PG.string "name"
        , email = PG.string "email"
        , bio = PG.nullable (PG.string "bio")
        , image = UserPhoto.attribute "image"
        , imageMaybeString = PG.nullable (PG.string "image")
        , following = PG.bool "following"
        , password = PG.string "password"
        }


type Comment = Comment

comment =
    PG.schema Comment "comments"
        { id = Comment.commentIdAttribute "id"
        , body = PG.string "body"
        , createdAt = date "created_at"
        , updatedAt = date "updated_at"
        , authorName = PG.string "author_name"
        , author = PG.hasOne_ "author_name" Profile
        , articleSlug = Article.slugAttribute "article_slug"
        , article = PG.hasOne_ "article_slug" Article
        }

type Follow = Follow

follow =
    PG.schema Follow "follows"
        { followerName = User.usernameAttribute "follower_name"
        , follower = PG.hasOne_ "follower_name" Profile
        , followedName = User.usernameAttribute "followed_name"
        , followed = PG.hasOne_ "followed_name" Profile
        }

type Favorite = Favorite

favorite =
    PG.schema Favorite "favorites"
        { userName = User.usernameAttribute "user_name"
        , user = PG.hasOne_ "user_name" Profile
        , articleSlug = Article.slugAttribute "article_slug"
        , article = PG.hasOne_ "article_slug" Article
        }

type Tag = Tag

tag =
    PG.schema Tag "tags"
        { name = Article.tagAttribute "name"
        }
