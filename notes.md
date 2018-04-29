




Notes:



* So I'm here to talk about Free objects, such as Free Monads
* Firstly, we might ask, what *is* a Free object? 
* Well, by object we mean an algebra. An algebra is a set of operations (functions) and rules over some set (type).
* In Haskell this could be a record of functions, or more commonly, a type class
* So that's an object; what makes it Free?
* Your first thought, and the thought of many, is that they come 'for Free' - say, you can just magically make something a Monad/ without doing any work
* This is true from a certain point of view, but it's also a misleading way to think about it and not why they're called 'Free'
* In the Free and Open Source Software community, people talk about things being 'Free and Libre'
* That is because in English, the word Free has two meanings - without cost, and without constraint
* Free software is more importantly *without constraint*, and only incidentally without cost
* The objects we're concerned with could perhaps more accurately be called 'Libre', rather than 'Free' - that is they have a certain Freedom we're interested in
* In essence, they are *free* from any additional functionality - the most generic form of the object

* So what does that look like?
* Lets take a Monoid, one of the simpler and more common algebras
* Well a Monoid defines some 'identity' and an associative binary 'append' operation
* So it has to be parametric because we can't know about any particular type, plus it wouldn't be useful

some data type M

```haskell
-- M will be our free monoid
data M a = ...
```

We need to satisfy the Monoid class, and be able to lift our underlying type
```haskell
class Monoid (M a) where
  mempty :: M a
  mappend :: M a -> M a -> M a

lift :: a -> M a
```


lets add these as constructors:
```haskell
data M a = Empty
         | Append (M a) (M a)
         | Lift a
```

```haskell
class Monoid (M a) where
  mempty = Empty
  mappend a b = Append a b
```


That hopefully looks pretty familiar. Here's one encoding of a tree:

```haskell
data Tree a = Empty
            | Node (Tree a) (Tree a)
            | Leaf a
```

This is an abstract syntax tree for Monoid operations - we have a single operation, plus leaves containing values. However, thanks to the Monoid laws, we know that the operation must be associative. This means we can flatten all the operations to a single sequence. When we do this, another familiar type drops out:

```haskell
data M a = Nil
         | Cons a (M a)
```

Yes, List is a free monoid. This is enough to preserve the order (monoids are not necessarily commutative) and the original values, but we drop any knowledge of association as they are not needed.

Now sometimes people talk about 'The Free Monoid' and sometimes 'a Free Monoid'. In fact, both are right. There are often different ways to encode Free structures, but - by the very definition of Free - they are always equivalent.

We can see this in the following encoding:

```haskell
class FreeMonoid m where
  define :: (forall b. Monoid b => (a -> b) -> b) -> m a
  interpret :: (Monoid b) => (a -> b) -> m a -> b
```

```haskell
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

```haskell
iso :: (FreeMonoid m, FreeMonoid n) => m a -> n a
iso ma = define $ flip interpret ma
```



structure:
* What do we mean by Free and Object?
  - explain Object/Algebra
  - explain Free
* Example of a Free Monoid
  - concrete example
  - list as free monoid
  - show isomorphism
  - trivial example of program interpretation
* Free Applicatives
  - Money shot
  - useful example of interpreting a Free Applicative expression
* Questions?
