module Fetch where

import Control.Monad.Aff (Aff)

newtype Init = Init { method :: String }

newtype Response = Response { ok :: Boolean }

foreign import fetch :: forall e. String -> Init -> Aff (| e) Response
