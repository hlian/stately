module Main where

import Prelude
import Control.Coroutine (Consumer, Producer, consumer, producer, runProcess, ($$))
import Control.Coroutine.Aff (produceAff)
import Control.Monad.Aff (Aff, forkAff, runAff)
import Control.Monad.Aff.AVar (AVAR, makeVar, putVar, takeVar)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.State.Trans (StateT(..), runStateT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Fetch (Init(..), fetch)
import Performance (now)

type Stately eff r = Aff (avar :: AVAR | eff)

ping :: forall eff. Aff eff Number
ping = do
  t0 <- liftEff now
  fetch "/" (Init {method:"options"})
  tf <- liftEff now
  pure (tf - t0)

pings :: forall eff. Producer String (Stately eff Int) Void
pings =
  produceAff loop
  where
    loop emit = do
      t <- ping
      emit (Left (show t))
      loop emit

c :: forall eff. Consumer String (Stately (console :: CONSOLE | eff) Int) Void
c = consumer \s -> liftEff (log s) $> Nothing

main :: forall e. Eff (err :: EXCEPTION, console :: CONSOLE, avar :: AVAR | e) Unit
main =
  void $ runAff logShow logShow $ runProcess (pings $$ c)
