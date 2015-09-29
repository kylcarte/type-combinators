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

module Type.Family.Nat
  ( module Type.Family.Nat
  , type (==)
  ) where

import Data.Type.Equality
import Type.Family.List

data N
  = Z
  | S N
  deriving (Eq,Ord,Show)

type family NatEq (x :: N) (y :: N) :: Bool where
  NatEq  Z     Z    = True
  NatEq  Z    (S y) = False
  NatEq (S x)  Z    = False
  NatEq (S x) (S y) = NatEq x y
type instance x == y = NatEq x y

type family Iota (x :: N) :: [N] where
  Iota Z     = Ø
  Iota (S x) = x :< Iota x

type family Pred (x :: N) :: N where
  Pred (S n) = n

type family (x :: N) + (y :: N) :: N where
  Z   + y = y
  S x + y = S (x + y)
infixr 6 +

type family (x :: N) * (y :: N) :: N where
  Z   * y = Z
  S x * y = (x * y) + y
infixr 7 *

type family (x :: N) ^ (y :: N) :: N where
  x ^   Z = S Z
  x ^ S y = (x ^ y) * x
infixl 8 ^

type N0  = Z
type N1  = S N0
type N2  = S N1
type N3  = S N2
type N4  = S N3
type N5  = S N4
type N6  = S N5
type N7  = S N6
type N8  = S N7
type N9  = S N8
type N10 = S N9

