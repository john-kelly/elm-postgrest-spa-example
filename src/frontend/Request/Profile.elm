module Request.Profile exposing (get, toggleFollow)

import Data.AuthToken as AuthToken exposing (AuthToken)
import Data.Profile as Profile exposing (Profile)
import Data.User as User exposing (Username)
import Data.UserPhoto
import Http
import PostgRest as PG
import Request.Schema as Schema


-- GET --


get : Username -> Maybe AuthToken -> Http.Request Profile
get username maybeToken =
    PG.readOne Schema.profile
        { select = selection
        , where_ = PG.eq username .name
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = maybeToken
            , timeout = Nothing
            }



-- FOLLOWING --


toggleFollow : Username -> Bool -> AuthToken -> Http.Request Profile
toggleFollow username following authToken =
    if following then
        unfollow username authToken
    else
        follow username authToken


follow : Username -> AuthToken -> Http.Request Profile
follow username token =
    PG.createOne Schema.follow
        { change = PG.change .followedName username
        , select = PG.embedOne .followed Schema.profile selection
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }


unfollow : Username -> AuthToken -> Http.Request Profile
unfollow username token =
    PG.deleteOne Schema.follow
        { select = PG.embedOne .followed Schema.profile selection
        , where_ = PG.eq username .followedName
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }


selection : PG.Selection
    { attributes
        | bio : PG.Attribute (Maybe String)
        , following : PG.Attribute Bool
        , image : PG.Attribute Data.UserPhoto.UserPhoto
        , name : PG.Attribute Username
    }
    Profile
selection = PG.map4 Profile
    (PG.field .name)
    (PG.field .bio)
    (PG.field .image)
    (PG.field .following)
