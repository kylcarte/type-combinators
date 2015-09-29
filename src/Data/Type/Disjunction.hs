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

module Data.Type.Disjunction where

import Type.Class.HFunctor
import Type.Class.Known
import Type.Class.Witness

-- (:+:) {{{

data ((f :: k -> *) :+: (g :: k -> *)) :: k -> * where
  L :: !(f a) -> (f :+: g) a
  R :: !(g a) -> (f :+: g) a
infixr 4 :+:

(>+<) :: (f a -> r) -> (g a -> r) -> (f :+: g) a -> r
f >+< g = \case
  L a -> f a
  R b -> g b
infixr 2 >+<

instance HFunctor ((:+:) f) where
  map' f = \case
    L a -> L a
    R b -> R $ f b

instance HFoldable ((:+:) f) where
  foldMap' f = \case
    L _ -> mempty
    R b -> f b

instance HTraversable ((:+:) f) where
  traverse' f = \case
    L a -> pure $ L a
    R b -> R <$> f b

instance HBifunctor (:+:) where
  bimap' f g = \case
    L a -> L $ f a
    R b -> R $ g b

instance (Witness p q (f a), Witness p q (g a)) => Witness p q ((f :+: g) a) where
  type WitnessC p q ((f :+: g) a) = (Witness p q (f a), Witness p q (g a))
  (\\) r = \case
    L a -> r \\ a
    R b -> r \\ b

-- }}}

-- (:|:) {{{

data ((f :: k -> *) :|: (g :: l -> *)) :: Either k l -> * where
  L' :: !(f a) -> (f :|: g) (Left  a)
  R' :: !(g b) -> (f :|: g) (Right b)
infixr 4 :|:

(>|<) :: (forall a. (e ~ Left a) => f a -> r) -> (forall b. (e ~ Right b) => g b -> r) -> (f :|: g) e -> r
f >|< g = \case
  L' a -> f a
  R' b -> g b
infixr 2 >|<

instance Known f a => Known (f :|: g) (Left a) where
  type KnownC (f :|: g) (Left a) = Known f a
  known = L' known

instance Known g b => Known (f :|: g) (Right b) where
  type KnownC (f :|: g) (Right b) = Known g b
  known = R' known

instance HFunctor ((:|:) f) where
  map' f = \case
    L' a -> L' a
    R' b -> R' $ f b

instance HFoldable ((:|:) f) where
  foldMap' f = \case
    L' _ -> mempty
    R' b -> f b

instance HTraversable ((:|:) f) where
  traverse' f = \case
    L' a -> pure $ L' a
    R' b -> R' <$> f b

instance HBifunctor (:|:) where
  bimap' f g = \case
    L' a -> L' $ f a
    R' b -> R' $ g b

instance Witness p q (f a) => Witness p q ((f :|: g) (Left a)) where
  type WitnessC p q ((f :|: g) (Left a)) = Witness p q (f a)
  r \\ L' a = r \\ a

instance Witness p q (g b) => Witness p q ((f :|: g) (Right b)) where
  type WitnessC p q ((f :|: g) (Right b)) = Witness p q (g b)
  r \\ R' b = r \\ b

-- }}}

