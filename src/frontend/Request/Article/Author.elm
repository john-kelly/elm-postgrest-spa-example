module Request.Article.Author exposing (selection)

import Data.Article.Author exposing (Author)
import Data.User
import Data.UserPhoto
import PostgRest as PG exposing (Selection, (&))

selection : Selection
    { attribute
        | bio : PG.Attribute (Maybe String)
        , following : PG.Attribute Bool
        , image : PG.Attribute Data.UserPhoto.UserPhoto
        , name : PG.Attribute Data.User.Username
    }
    Author
selection = PG.succeed Author
    & PG.select .name
    & PG.select .bio
    & PG.select .image
    & PG.select .following
