---
title: Free and Libre Monads
author: Nick Pollard
---

## Welcome

* Nick Pollard 
* Principal Engineer @ nstack
* nick@nstack.com
* @Nick_enGB

----

### Objects

* Really an Algebra:
  * A set of operations (functions) and laws
  * over a set (type)
* In Haskell this could be a record of functions
* Or more commonly a type class

----

```haskell
data Monoid a = Monoid {
  mappend :: a -> a -> a,
  mzero :: a
}

class Monoid a where
  mappend :: a -> a -> a
  mzero :: a
```

----

### Free as in Beer

* Get one 'for free'?

----

### Free as in Speech

* Without constraints, not without costs
* An object free of relations
* The most generic instance of an algebra
* Does exactly what the definition says and no more

----

### Free Monoids

We need to satisfy the Monoid class, and be able to lift our underlying type
```haskell
data M a
lift :: a -> M a

instance Monoid (M a) where
  mempty :: M a
  mappend :: M a -> M a -> M a

```

----

```haskell
data M a = Empty
         | Append (M a) (M a)
         | Lift a

class Monoid (M a) where
  mempty = Empty
  mappend a b = Append a b
```

----

> - 
>   ```haskell
>   data Tree a = Empty
>               | Node (Tree a) (Tree a)
>               | Leaf a
>   ```
> -
>   ```haskell
>   data M a = Nil
>            | Cons a (M a)
>   ```

----

```haskell
class FreeMonoid m where
  define :: (forall b. Monoid b => (a -> b) -> b) -> m a
  interpret :: (Monoid b) => (a -> b) -> m a -> b

instance FreeMonoid [] where
  define def = def return
  interpret = foldMap
```

```haskell
expr :: Bool -> Bool -> (Monoid b => (Bool -> b) -> b)
expr this that = \lift ->
  lift this <> lift that <> lift that <> mempty

program :: Bool -> Bool -> [Bool]
program this that = define $ program this that
```

----

### Many Free Monoids?

* 'The Free Monoid' or 'A Free Monoid'?
* Actually both
* Multiple encodings can exist
* Isomorphic by definition

----

```haskell
iso :: (FreeMonoid m, FreeMonoid n) => m a -> n a
iso ma = define $ flip interpret ma
```

----

### Practical Uses

* Define an expression in the language of the algebra
* Can interpret it in many ways
* Using Free Applicatives we can do static analysis
  * Not possible with Free Monads, as structure not statically known

----

### A Simple expression language

```haskell
data WithResource a where
  ReadFile :: FilePath -> WithResource String
  ReadEnv :: String -> WithResource String

type Resource a = Ap WithResource a -- Ap is the Free Applicative

loadFile = liftAp . ReadFile
loadEnv = liftAp . ReadEnv

data Foo = Foo Int Int Int

resource :: Resource Foo
resource = Foo
            <$> (read <$> loadFile "first.txt")
            <*> (read <$> loadFile "second.txt")
            <*> (read <$> loadEnv "VAR_THIRD")
```

----

* Execute
```haskell
run :: Resource a -> IO a
run = runAp exec
  where exec :: WithResource a -> IO a
        exec (ReadFile f) = P.readFile f
        exec (ReadEnv f) = getEnv f
```
----

* Analyse
```haskell
files :: Resource a -> [FilePath]
files prg = getConst $ runAp inputFiles prg
  where inputFiles :: WithResource a -> Const [FilePath] a
        inputFiles (ReadFile file) = Const [file]
        inputFiles _ = Const []

vars :: Resource a -> [String]
vars prg = getConst $ runAp envVars prg
  where envVars :: WithResource a -> Const [String] a
        envVars (ReadEnv var) = Const [var]
        envVars _ = Const []
```

----

## Questions?

* nick@nstack.com
* @Nick_enGB
