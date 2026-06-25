module HsGlitch.FilterSpec (spec) where

import Codec.Picture (Image, PixelRGB8 (..), generateImage, pixelAt)
import Control.Monad.State (evalState)
import HsGlitch.Filter (FilterSpec (..), interpret)
import HsGlitch.Pixel (Direction (..))
import System.Random (mkStdGen)
import Test.Hspec

rowImage :: [PixelRGB8] -> Image PixelRGB8
rowImage ps = generateImage (\x _ -> ps !! x) (length ps) 1

spec :: Spec
spec = do
    describe "interpret RgbShift" $
        it "shift=0 is the identity" $ do
            let img = rowImage [PixelRGB8 10 20 30, PixelRGB8 40 50 60]
                out = evalState (interpret (RgbShift 0 False) img) (mkStdGen 1)
            [pixelAt out 0 0, pixelAt out 1 0]
                `shouldBe` [PixelRGB8 10 20 30, PixelRGB8 40 50 60]

    describe "interpret PixelSort" $
        it "threshold above 1.0 leaves the image unchanged" $ do
            let img = rowImage [PixelRGB8 255 255 255, PixelRGB8 0 0 0]
                out = evalState (interpret (PixelSort 1.1 Horizontal 0.0) img) (mkStdGen 1)
            [pixelAt out 0 0, pixelAt out 1 0]
                `shouldBe` [PixelRGB8 255 255 255, PixelRGB8 0 0 0]
