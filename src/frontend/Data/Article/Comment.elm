module Data.Article.Comment exposing (Comment, CommentId, commentIdAttribute)

import Data.Article.Author as Author exposing (Author)
import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import PostgRest as PG


type alias Comment =
    { id : CommentId
    , body : String
    , createdAt : Date
    , updatedAt : Date
    , author : Author
    }


-- IDENTIFIERS --


type CommentId
    = CommentId Int


commentIdAttribute : String -> PG.Attribute CommentId
commentIdAttribute name =
    let
        idToString (CommentId id) =
            toString id
    in
    PG.attribute
        { decoder = Decode.map CommentId Decode.int
        , encoder = idToString >> Encode.string
        , urlEncoder = idToString
        }
        name
