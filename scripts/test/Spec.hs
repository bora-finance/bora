module Main (main) where

import Data.Default (def)
import Data.Set qualified as Set
import Test.Hspec (Spec)
import Test.Hspec qualified as Hspec

conf :: GoldenConf
conf =
  def
    { chosenTests = Set.fromList [PTest.GoldenT'UPLCPostEval, PTest.GoldenT'Bench]
    , goldenBasePath = "test/golden"
    }

main :: IO ()
main = dundefine


