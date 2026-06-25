module HsGlitch.ParserSpec (spec) where

import Data.Either (isLeft)
import HsGlitch.Filter (FilterSpec (..))
import HsGlitch.Parser (parsePipeline)
import HsGlitch.Pixel (Direction (..))
import Test.Hspec

spec :: Spec
spec = do
    describe "parsePipeline (valid)" $ do
        it "parses two steps with params and ignores whitespace" $
            parsePipeline "pixelsort:threshold=0.5,direction=horizontal | rgbshift:shift=10"
                `shouldBe` Right
                    [ PixelSort 0.5 Horizontal 0.0
                    , RgbShift 10 False
                    ]

        it "applies defaults when params are omitted" $
            parsePipeline "rgbshift"
                `shouldBe` Right [RgbShift 5 False]

        it "parses vertical direction and jitter and random flags" $
            parsePipeline "pixelsort:direction=vertical,jitter=0.2 | rgbshift:random=true"
                `shouldBe` Right
                    [ PixelSort 0.5 Vertical 0.2
                    , RgbShift 5 True
                    ]

    describe "parsePipeline (invalid)" $ do
        it "rejects an unknown filter name" $
            parsePipeline "bogus" `shouldSatisfy` isLeft

        it "rejects a non-numeric threshold" $
            parsePipeline "pixelsort:threshold=abc" `shouldSatisfy` isLeft

        it "rejects an unknown key" $
            parsePipeline "rgbshift:wat=1" `shouldSatisfy` isLeft
