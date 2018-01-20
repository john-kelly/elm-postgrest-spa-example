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

article :
    PG.Schema Article
        { description : PG.Attribute String
        , slug : PG.Attribute Article.Slug
        , title : PG.Attribute String
        , createdAt : PG.Attribute Date.Date
        , updatedAt : PG.Attribute Date.Date
        , favorited : PG.Attribute Bool
        , favoritesCount : PG.Attribute Int
        , authorName : PG.Attribute User.Username
        , body : PG.Attribute Article.Body
        , tagStrings : PG.Attribute (List String)
        , tags : PG.Attribute (List Article.Tag)
        , favoritedBy : PG.Attribute (List User.Username)
        , followedBy : PG.Attribute (List User.Username)
        , stringBody : PG.Attribute String
        , author : PG.Relationship PG.HasOne Profile
        }
article =
    PG.schema "articles"
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
        , author = PG.hasOne "author_name"
        }


type Profile = Profile


profile :
    PG.Schema Profile
        { name : PG.Attribute User.Username
        , nameString : PG.Attribute String
        , email : PG.Attribute String
        , bio : PG.Attribute (Maybe String)
        , image : PG.Attribute UserPhoto.UserPhoto
        , imageMaybeString : PG.Attribute (Maybe String)
        , following : PG.Attribute Bool
        , password : PG.Attribute String
        }
profile =
    PG.schema "profiles"
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

comment :
    PG.Schema Comment
        { id : PG.Attribute Comment.CommentId
        , body : PG.Attribute String
        , createdAt : PG.Attribute Date.Date
        , updatedAt : PG.Attribute Date.Date
        , authorName : PG.Attribute String
        , author : PG.Relationship PG.HasOne Profile
        , articleSlug : PG.Attribute Article.Slug
        , article : PG.Relationship PG.HasOne Article
        }
comment =
    PG.schema "comments"
        { id = Comment.commentIdAttribute "id"
        , body = PG.string "body"
        , createdAt = date "created_at"
        , updatedAt = date "updated_at"
        , authorName = PG.string "author_name"
        , author = PG.hasOne "author_name"
        , articleSlug = Article.slugAttribute "article_slug"
        , article = PG.hasOne "article_slug"
        }

type Follow = Follow

follow :
    PG.Schema Follow
        { followerName : PG.Attribute User.Username
        , follower : PG.Relationship PG.HasOne Profile
        , followedName : PG.Attribute User.Username
        , followed : PG.Relationship PG.HasOne Profile
        }
follow =
    PG.schema "follows"
        { followerName = User.usernameAttribute "follower_name"
        , follower = PG.hasOne "follower_name"
        , followedName = User.usernameAttribute "followed_name"
        , followed = PG.hasOne "followed_name"
        }

type Favorite = Favorite

favorite :
    PG.Schema Favorite
        { userName : PG.Attribute User.Username
        , user : PG.Relationship PG.HasOne Profile
        , articleSlug : PG.Attribute Article.Slug
        , article : PG.Relationship PG.HasOne Article
        }
favorite =
    PG.schema "favorites"
        { userName = User.usernameAttribute "user_name"
        , user = PG.hasOne "user_name"
        , articleSlug = Article.slugAttribute "article_slug"
        , article = PG.hasOne "article_slug"
        }

type Tag = Tag

tag :
    PG.Schema Tag
        { name : PG.Attribute Article.Tag
        }
tag =
    PG.schema "tags"
        { name = Article.tagAttribute "name"
        }
