module Data.Profile exposing (Profile)

import Data.User as User exposing (Username)
import Data.UserPhoto as UserPhoto exposing (UserPhoto)


type alias Profile =
    { username : Username
    , bio : Maybe String
    , image : UserPhoto
    , following : Bool
    }
