module Data.AuthToken exposing (AuthToken, decoder, encode, withAuthorization, toAuthorizedHttpRequest)

import Http
import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import PostgRest as PG
import Time


type AuthToken
    = AuthToken String


encode : AuthToken -> Value
encode (AuthToken token) =
    Encode.string token


decoder : Decoder AuthToken
decoder =
    Decode.string
        |> Decode.map AuthToken


withAuthorization : Maybe AuthToken -> RequestBuilder a -> RequestBuilder a
withAuthorization maybeToken builder =
    case maybeToken of
        Just (AuthToken token) ->
            builder
                |> withHeader "authorization" ("Token " ++ token)

        Nothing ->
            builder


toAuthorizedHttpRequest : { timeout : Maybe Time.Time, token : Maybe AuthToken, url : String } -> PG.Request a -> Http.Request a
toAuthorizedHttpRequest { timeout, token, url } request =
    PG.toHttpRequest
        { timeout = timeout
        , token = Maybe.map (\(AuthToken str) -> str) token
        , url = url
        }
        request
