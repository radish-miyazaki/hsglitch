module HsGlitch.CLISpec (spec) where

import Data.Either (isLeft)
import HsGlitch.CLI (Options (..), parseOptionsPure)
import Test.Hspec

spec :: Spec
spec = do
    describe "parseOptionsPure" $ do
        it "parses all options including seed" $
            parseOptionsPure
                ["-i", "in.png", "-o", "out.png", "-p", "rgbshift:shift=3", "-s", "42"]
                `shouldBe` Right (Options "in.png" "out.png" "rgbshift:shift=3" (Just 42))

        it "leaves seed as Nothing when omitted" $
            parseOptionsPure ["-i", "in.png", "-o", "out.png", "-p", "rgbshift"]
                `shouldBe` Right (Options "in.png" "out.png" "rgbshift" Nothing)

        it "fails when a required option is missing" $
            parseOptionsPure ["-i", "in.png"] `shouldSatisfy` isLeft
