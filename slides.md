# Free and Libre Monads
NICK POLLARD

# Welcome

* Nick Pollard 
* Principal Engineer @ nstack
* nick@nstack.com
* @Nick_enGB

# Free as in Beer
```haskell
class (Monad m) => FreeMonad m where
  interpret :: Monad n => m a -> n a
```
