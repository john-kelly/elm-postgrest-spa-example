module Data.Article.Feed exposing (Feed)

import Data.Article as Article exposing (Article)

type alias Feed =
    { articles : List (Article ())
    , articlesCount : Int
    }
