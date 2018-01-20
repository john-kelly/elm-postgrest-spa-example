module Request.Article.Author exposing (selection)

import Data.Article.Author exposing (Author)
import Data.User
import Data.UserPhoto
import PostgRest as PG

selection : PG.Selection
    { attribute
        | bio : PG.Attribute (Maybe String)
        , following : PG.Attribute Bool
        , image : PG.Attribute Data.UserPhoto.UserPhoto
        , name : PG.Attribute Data.User.Username
    }
    Author
selection = PG.map4 Author
    (PG.field .name)
    (PG.field .bio)
    (PG.field .image)
    (PG.field .following)
