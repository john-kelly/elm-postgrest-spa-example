module Request.Article.Comments exposing (delete, list, post)

import Data.Article as Article exposing (Article, Tag, slugToString)
import Data.Article.Author exposing (Author)
import Data.Article.Comment as Comment exposing (Comment, CommentId)
import Data.AuthToken as AuthToken exposing (AuthToken)
import Date
import Http
import HttpBuilder exposing (RequestBuilder, withExpect, withQueryParams)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import PostgRest as PG
import Request.Article.Author
import Request.Schema as Schema
import Util exposing ((=>))


-- LIST --


list : Maybe AuthToken -> Article.Slug -> Http.Request (List Comment)
list maybeToken slug =
    PG.readMany Schema.comment
        { select = selection
        , where_ = PG.eq slug .articleSlug
        , limit = Nothing
        , offset = Nothing
        , order = [ PG.asc .createdAt ]
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = maybeToken
            , timeout = Nothing
            }


-- POST --


post : Article.Slug -> String -> AuthToken -> Http.Request Comment
post slug body token =
    PG.createOne Schema.comment
        { change = PG.batch
            [ PG.change .body body
            , PG.change .articleSlug slug
            ]
        , select = selection
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }


selection : PG.Selection
    { attributes
        | author : PG.Relationship PG.HasOne Schema.Profile
        , body : PG.Attribute String
        , createdAt : PG.Attribute Date.Date
        , id : PG.Attribute CommentId
        , updatedAt : PG.Attribute Date.Date
    }
    Comment
selection =
    PG.map5 Comment
        (PG.field .id)
        (PG.field .body)
        (PG.field .createdAt)
        (PG.field .updatedAt)
        (PG.embedOne .author Schema.profile Request.Article.Author.selection)


-- DELETE --


delete : Article.Slug -> CommentId -> AuthToken -> Http.Request ()
delete slug commentId token =
    PG.deleteOne Schema.comment
        { select = PG.succeed ()
        , where_ = PG.all
            [ PG.eq slug .articleSlug
            , PG.eq commentId .id
            ]
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }
