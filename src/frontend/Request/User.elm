module Request.User exposing (edit, login, register, storeSession)

import Data.AuthToken as AuthToken exposing (AuthToken)
import Data.User as User exposing (User)
import Http
import Json.Encode as Encode
import Ports
import PostgRest as PG
import Request.Schema as Schema
import Util exposing ((=>))


storeSession : User -> Cmd msg
storeSession user =
    User.encode user
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession


login : { r | email : String, password : String } -> Http.Request User
login { email, password } =
    let
        user =
            Encode.object
                [ "email" => Encode.string email
                , "password" => Encode.string password
                ]

        body =
            Http.jsonBody user
    in
        Http.request
            { method = "POST"
            , headers = [ Http.header "Accept" "application/vnd.pgrst.object+json" ]
            , url = "http://localhost:3000/rpc/login"
            , body = body
            , expect = Http.expectJson User.loginUserDecoder
            , timeout = Nothing
            , withCredentials = False
            }


register : { r | username : String, email : String, password : String } -> Http.Request User
register { username, email, password } =
    let
        user =
            Encode.object
                [ "email" => Encode.string email
                , "password" => Encode.string password
                , "name" => Encode.string username
                ]

        body =
            Http.jsonBody user
    in
        Http.request
            { method = "POST"
            , headers = [ Http.header "Accept" "application/vnd.pgrst.object+json" ]
            , url = "http://localhost:3000/rpc/signup"
            , body = body
            , expect = Http.expectJson User.loginUserDecoder
            , timeout = Nothing
            , withCredentials = False
            }


edit :
    { r
        | username : String
        , email : String
        , bio : String
        , password : Maybe String
        , image : Maybe String
    }
    -- NOTE: had to add username b/c row level security is not working as expected
    -> User.Username
    -- NOTE: changed from Maybe Token b/c the profiles endpoint does not return a new token
    -- we needed the token for the returned User type
    -> AuthToken
    -> Http.Request User
edit { username, email, bio, password, image } originalUsername token =
    PG.updateOne Schema.profile
        { change = PG.batch
            [ PG.change .email email
            , PG.change .bio (Just bio)
            -- FIXME: updating password and username are not working
            -- , PG.change .nameString username
            -- , case password of
            --     Just pass -> PG.change .password pass
            --     Nothing -> PG.batch []
            , PG.change .imageMaybeString image
            ]
        , where_ = PG.eq originalUsername .name
        , select = PG.map5 User
            (PG.field .email)
            (PG.succeed token)
            (PG.field .name)
            (PG.field .bio)
            (PG.field .image)
        }
        |> AuthToken.toAuthorizedHttpRequest
            { url = "http://localhost:3000"
            , token = Just token
            , timeout = Nothing
            }
