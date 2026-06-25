module SmokeSpec (spec) where

import Test.Hspec

spec :: Spec
spec =
    describe "smoke" $
        it "test harness runs" $
            (1 + 1 :: Int) `shouldBe` 2
