{-# LANGUAGE GADTs #-}
-----------------------------------------------------------------------------
-- |
-- Module     : Algebra.Graph.Test.Generic
-- Copyright  : (c) Andrey Mokhov 2016-2017
-- License    : MIT (see the file LICENSE)
-- Maintainer : andrey.mokhov@gmail.com
-- Stability  : experimental
--
-- Generic graph API testing.
-----------------------------------------------------------------------------
module Algebra.Graph.Test.Generic (
    -- * Generic tests
    Testsuite (..), testEmpty, testVertex, testTranspose
  ) where

import Data.List (sort)
import Data.Tuple

import Algebra.Graph.Class (Vertex, empty, vertex)
import Algebra.Graph.Test
import Algebra.Graph.Test.API

data Testsuite g where
    Testsuite :: (Arbitrary g, Eq g, GraphAPI g, Show g, Vertex g ~ Int) => String -> g -> Testsuite g

testEmpty :: Testsuite g -> IO ()
testEmpty (Testsuite prefix g) = do
    putStrLn $ "\n============ " ++ prefix ++ "empty ============"
    test "isEmpty     empty == True" $
          isEmpty    (empty `asTypeOf` g) == True

    test "hasVertex x empty == False" $ \x ->
          hasVertex x (empty `asTypeOf` g) == False

    test "vertexCount empty == 0" $
          vertexCount(empty `asTypeOf` g) == 0

    test "edgeCount   empty == 0" $
          edgeCount  (empty `asTypeOf` g) == 0

testVertex :: Testsuite g -> IO ()
testVertex (Testsuite prefix g) = do
    putStrLn $ "\n============ " ++ prefix ++ "vertex ============"
    test "isEmpty     (vertex x) == False" $ \x ->
          isEmpty     (vertex x `asTypeOf` g) == False

    test "hasVertex x (vertex x) == True" $ \x ->
          hasVertex x (vertex x `asTypeOf` g) == True

    test "hasVertex 1 (vertex 2) == False" $
          hasVertex 1 (vertex 2 `asTypeOf` g) == False

    test "vertexCount (vertex x) == 1" $ \x ->
          vertexCount (vertex x `asTypeOf` g) == 1

    test "edgeCount   (vertex x) == 0" $ \x ->
          edgeCount   (vertex x `asTypeOf` g) == 0

testTranspose :: Testsuite g -> IO ()
testTranspose (Testsuite prefix g) = do
    putStrLn $ "\n============ " ++ prefix ++ "transpose ============"
    test "transpose empty       == empty" $
          transpose empty       == empty `asTypeOf` g

    test "transpose (vertex x)  == vertex x" $ \x ->
          transpose (vertex x)  == vertex x `asTypeOf` g

    test "transpose (edge x y)  == edge y x" $ \x y ->
          transpose (edge x y)  == edge y x `asTypeOf` g

    test "transpose . transpose == id" $ \x ->
         (transpose . transpose) x == x `asTypeOf` g

    test "transpose . path      == path    . reverse" $ \xs ->
         (transpose . path) xs  == (path . reverse) xs `asTypeOf` g

    test "transpose . circuit   == circuit . reverse" $ \xs ->
         (transpose . circuit) xs == (circuit . reverse) xs `asTypeOf` g

    test "transpose . clique    == clique  . reverse" $ \xs ->
         (transpose . clique) xs == (clique . reverse) xs `asTypeOf` g

    test "edgeList . transpose  == sort . map swap . edgeList" $ \x ->
         (edgeList . transpose) x == (sort . map swap . edgeList) (x `asTypeOf` g)