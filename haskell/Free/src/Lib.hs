{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}

module Lib where

import Prelude hiding (readFile, writeFile)
import qualified Prelude as P

import Control.Applicative
import Control.Applicative.Free
import Data.Monoid
import System.Environment

someFunc :: IO ()
someFunc = putStrLn "someFunc"

----

class FreeMonoid m where
  define :: (forall b. Monoid b => (a -> b) -> b) -> m a
  interpret :: (Monoid b) => (a -> b) -> m a -> b

instance FreeMonoid [] where
  define def = def return
  interpret = foldMap

prog :: a -> a -> [a]
prog this that = define $ \lift ->
  lift this <> lift that <> lift that <> mempty

prog' :: a -> a -> (Monoid b => (a -> b) -> b)
prog' this that = \lift ->
  lift this <> lift that <> lift that <> mempty

prog'' :: a -> a -> [a]
prog'' this that = define $ prog' this that

iso :: (FreeMonoid m, FreeMonoid n) => m a -> n a
iso ma = define $ flip interpret ma


expr :: Bool -> Bool -> (Monoid b => (Bool -> b) -> b)
expr this that = \lift ->
  lift this <> lift that <> mempty

program :: Bool -> Bool -> [Bool]
program this that = define $ expr this that

newtype And = And Bool
newtype Or = Or Bool

instance Monoid And where
  mempty = And True
  mappend (And a) (And b) = And $ a && b

instance Monoid Or where
  mempty = Or False
  mappend (Or a) (Or b) = Or $ a || b

both :: And
both = interpret And $ program True False

either :: Or
either = interpret Or $ program True False


--class Free (c :: k -> Constraint) (m :: k) where
  --typeclass :: c m






data WithResource a where
  ReadFile :: FilePath -> WithResource String
  ReadEnv :: String -> WithResource String

loadFile = liftAp . ReadFile
loadEnv = liftAp . ReadEnv

-- Ap is the Free Applicative Functor
type Resource a = Ap WithResource a


data Foo = Foo Int Int Int

resource :: Resource Foo
resource = Foo
            <$> (read <$> loadFile "first.txt")
            <*> (read <$> loadFile "second.txt")
            <*> (read <$> loadEnv "VAR_THIRD")

files :: Resource a -> [FilePath]
files prg = getConst $ runAp inputFiles prg
  where
    inputFiles :: WithResource a -> Const [FilePath] a
    inputFiles (ReadFile file) = Const [file]
    inputFiles _ = Const []

vars :: Resource a -> [String]
vars prg = getConst $ runAp envVars prg
  where
    envVars :: WithResource a -> Const [String] a
    envVars (ReadEnv var) = Const [var]
    envVars _ = Const []

run :: Resource a -> IO a
run = runAp exec
  where
    exec :: WithResource a -> IO a
    exec (ReadFile f) = P.readFile f
    exec (ReadEnv f) = getEnv f
