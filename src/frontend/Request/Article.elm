module Request.Article
    exposing
        ( FeedConfig
        , ListConfig
        , create
        , defaultFeedConfig
        , defaultListConfig
        , delete
        , feed
        , get
        , list
        , tags
        , toggleFavorite
        , update
        )

import Data.Article as Article exposing (Article, Body, Tag, slugToString)
import Data.Article.Author exposing (Author)
import Data.Article.Feed as Feed exposing (Feed)
import Data.AuthToken as AuthToken exposing (AuthToken)
import Data.User as User exposing (Username)
import Date
import Http
import PostgRest as PG exposing ((&))
import Request.Article.Author
import Request.Schema as Schema


-- SINGLE --


get : Maybe AuthToken -> Article.Slug -> Http.Request (Article Body)
get maybeToken slug =
    PG.readOne Schema.article
        { select = selection (PG.field .body)
        , where_ = PG.eq slug .slug
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = maybeToken
            , timeout = Nothing
            }


-- LIST --


type alias ListConfig =
    { tag : Maybe Tag
    , author : Maybe Username
    , favorited : Maybe Username
    , size : Int
    , page : Int
    }


defaultListConfig : ListConfig
defaultListConfig =
    { tag = Nothing
    , author = Nothing
    , favorited = Nothing
    , size = 20
    , page = 1
    }


list : ListConfig -> Maybe AuthToken -> Http.Request { data: List (Article ()), count: Int }
list config maybeToken =
    let
        authorCondition =
            case config.author of
                Nothing -> PG.true
                Just username -> PG.eq username .authorName

        favoritedByCondition =
            case config.favorited of
                Nothing -> PG.true
                Just username -> PG.cs [ username ] .favoritedBy

        tagCondition =
            case config.tag of
                Nothing -> PG.true
                Just tag -> PG.cs [ tag ] .tags
    in
    PG.readPage Schema.article
        { select = selection (PG.succeed ())
        , where_ = PG.all [ authorCondition, favoritedByCondition, tagCondition ]
        , page = config.page
        , size = config.size
        , order = (PG.asc .createdAt, [])
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = maybeToken
            , timeout = Nothing
            }


-- FEED --


type alias FeedConfig =
    { size : Int
    , page : Int
    }


defaultFeedConfig : FeedConfig
defaultFeedConfig =
    { size = 10
    , page = 1
    }


feed : FeedConfig -> Username -> AuthToken -> Http.Request { data: List (Article ()), count: Int }
feed config username token =
    PG.readPage Schema.article
        { select = selection (PG.succeed ())
        , where_ = PG.cs [ username ] .followedBy
        , page = config.page
        , size = config.size
        , order = (PG.asc .createdAt, [])
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }



-- TAGS --


tags : Http.Request (List Tag)
tags =
    PG.readMany Schema.tag
        { select = PG.field .name
        , where_ = PG.true
        , offset = Nothing
        , limit = Nothing
        , order = []
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Nothing
            , timeout = Nothing
            }



-- FAVORITE --


toggleFavorite : Article a -> AuthToken -> Http.Request (Article ())
toggleFavorite article authToken =
    if article.favorited then
        unfavorite article.slug authToken
    else
        favorite article.slug authToken


favorite : Article.Slug -> AuthToken -> Http.Request (Article ())
favorite slug token =
    PG.createOne Schema.favorite
        { change = PG.change .articleSlug slug
        , select = PG.embedOne .article Schema.article (selection (PG.succeed ()))
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }


unfavorite : Article.Slug -> AuthToken -> Http.Request (Article ())
unfavorite slug token =
    PG.deleteOne Schema.favorite
        { where_ = PG.eq slug .articleSlug
        , select = PG.embedOne .article Schema.article (selection (PG.succeed ()))
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }

-- CREATE --


type alias CreateConfig record =
    { record
        | title : String
        , description : String
        , body : String
        , tags : List String
    }


type alias EditConfig record =
    { record
        | title : String
        , description : String
        , body : String
    }


create : CreateConfig record -> AuthToken -> Http.Request (Article Body)
create config token =
    PG.createOne Schema.article
        { change = PG.batch
            [ PG.change .title config.title
            , PG.change .description config.description
            , PG.change .stringBody config.body
            , PG.change .tagStrings config.tags
            ]
        , select = selection (PG.field .body)
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }


update : Article.Slug -> EditConfig record -> AuthToken -> Http.Request (Article Body)
update slug config token =
    PG.updateOne Schema.article
        { change = PG.batch
            [ PG.change .title config.title
            , PG.change .description config.description
            , PG.change .stringBody config.body
            ]
        , where_ = PG.eq slug .slug
        , select = selection (PG.field .body)
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }



-- DELETE --


delete : Article.Slug -> AuthToken -> Http.Request ()
delete slug token =
    PG.deleteOne Schema.article
        { where_ = PG.eq slug .slug
        , select = PG.succeed ()
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }

type alias Attributes other =
    { other
        | author : PG.Relationship PG.HasOne Schema.Profile
        , createdAt : PG.Attribute Date.Date
        , description : PG.Attribute String
        , favorited : PG.Attribute Bool
        , favoritesCount : PG.Attribute Int
        , slug : PG.Attribute Article.Slug
        , tagStrings : PG.Attribute (List String)
        , title : PG.Attribute String
        , updatedAt : PG.Attribute Date.Date
    }

selection : PG.Selection (Attributes other) body -> PG.Selection (Attributes other) (Article body)
selection body =
    PG.succeed Article
        & PG.field .description
        & PG.field .slug
        & PG.field .title
        & PG.field .tagStrings
        & PG.field .createdAt
        & PG.field .updatedAt
        & PG.field .favorited
        & PG.field .favoritesCount
        & PG.embedOne .author Schema.profile Request.Article.Author.selection
        & body
