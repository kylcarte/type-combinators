{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE GADTs #-}

module Data.Type.Conjunction where

import Type.Class.HFunctor
import Type.Class.Known
import Type.Class.Witness
import Type.Family.Pair

-- (:&:) {{{

data ((f :: k -> *) :&: (g :: k -> *)) :: k -> * where
  (:&:) :: !(f a) -> !(g a) -> (f :&: g) a
infixr 5 :&:

deriving instance (Eq   (f a), Eq   (g a)) => Eq   ((f :&: g) a)
deriving instance (Ord  (f a), Ord  (g a)) => Ord  ((f :&: g) a)
deriving instance (Show (f a), Show (g a)) => Show ((f :&: g) a)

fanFst :: (f :&: g) a -> f a
fanFst (a :&: _) = a

fanSnd :: (f :&: g) a -> g a
fanSnd (_ :&: b) = b

uncurryFan :: (f a -> g a -> r) -> (f :&: g) a -> r
uncurryFan f (a :&: b) = f a b

curryFan :: ((f :&: g) a -> r) -> f a -> g a -> r
curryFan f a b = f (a :&: b)

instance DecEquality f => DecEquality (f :&: g) where
  decideEquality (a :&: _) (c :&: _) = decideEquality a c

instance (Known f a, Known g a) => Known (f :&: g) a where
  known = known :&: known

instance HFunctor ((:&:) f) where
  map' f (a :&: b) = a :&: f b

instance HFoldable ((:&:) f) where
  foldMap' f (_ :&: b) = f b

instance HTraversable ((:&:) f) where
  traverse' f (a :&: b) = (:&:) a <$> f b

instance HBifunctor (:&:) where
  bimap' f g (a :&: b) = f a :&: g b

instance (Witness p q (f a), Witness s t (g a)) => Witness (p,s) (q,t) ((f :&: g) a) where
  type WitnessC (p,s) (q,t) ((f :&: g) a) = (Witness p q (f a), Witness s t (g a))
  r \\ a :&: b = r \\ a \\ b

{-
instance Witness p q (f a) => Witness p q (WitFst (:&:) f g a) where
  r \\ WitFst (a :&: _) = r \\ a

instance Witness p q (g a) => Witness p q (WitSnd (:&:) f g a) where
  r \\ WitSnd (_ :&: b) = r \\ b
-}

-- }}}

-- (:*:) {{{

data ((f :: k -> *) :*: (g :: l -> *)) :: (k,l) -> * where
  (:*:) :: !(f a) -> !(g b) -> (f :*: g) (a#b)
infixr 5 :*:

deriving instance (Eq   (f (Fst p)), Eq   (g (Snd p))) => Eq   ((f :*: g) p)
deriving instance (Ord  (f (Fst p)), Ord  (g (Snd p))) => Ord  ((f :*: g) p)
deriving instance (Show (f (Fst p)), Show (g (Snd p))) => Show ((f :*: g) p)

parFst :: (f :*: g) p -> f (Fst p)
parFst (a :*: _) = a

parSnd :: (f :*: g) p -> g (Snd p)
parSnd (_ :*: b) = b

uncurryPar :: (forall a b. (p ~ (a#b)) => f a -> g b -> r) -> (f :*: g) p -> r
uncurryPar f (a :*: b) = f a b

curryPar :: ((f :*: g) (a#b) -> r) -> f a -> g b -> r
curryPar f a b = f (a :*: b)

instance (p ~ (a#b), Known f a, Known g b) => Known (f :*: g) p where
  known = known :*: known

instance HFunctor ((:*:) f) where
  map' f (a :*: b) = a :*: f b

instance HFoldable ((:*:) f) where
  foldMap' f (_ :*: b) = f b

instance HTraversable ((:*:) f) where
  traverse' f (a :*: b) = (:*:) a <$> f b

instance HBifunctor (:*:) where
  bimap' f g (a :*: b) = f a :*: g b

_fst :: (a#b) :~: (c#d) -> a :~: c
_fst Refl = Refl

_snd :: (a#b) :~: (c#d) -> b :~: d
_snd Refl = Refl

instance (DecEquality f, DecEquality g) => DecEquality (f :*: g) where
  decideEquality (a :*: b) (c :*: d) = case decideEquality a c of
    Proven    p -> case decideEquality b d of
      Proven  q -> Proven  $ Refl \\ p \\ q
      Refuted q -> Refuted $ q . _snd
    Refuted   p -> Refuted $ p . _fst

instance (Witness p q (f a), Witness s t (g b), x ~ (a#b)) => Witness (p,s) (q,t) ((f :*: g) x) where
  type WitnessC (p,s) (q,t) ((f :*: g) x) = (Witness p q (f (Fst x)), Witness s t (g (Snd x)))
  r \\ a :*: b = r \\ a \\ b

-- }}}
