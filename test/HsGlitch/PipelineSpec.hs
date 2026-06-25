module HsGlitch.PipelineSpec (spec) where

import Codec.Picture (Image, PixelRGB8 (..), generateImage, pixelAt)
import HsGlitch.Filter (FilterSpec (..))
import HsGlitch.Pipeline (runPipeline)
import HsGlitch.Pixel (Direction (..))
import System.Random (mkStdGen)
import Test.Hspec

rowImage :: [PixelRGB8] -> Image PixelRGB8
rowImage ps = generateImage (\x _ -> ps !! x) (length ps) 1

pixels :: Image PixelRGB8 -> [PixelRGB8]
pixels img = [pixelAt img 0 0, pixelAt img 1 0, pixelAt img 2 0]

spec :: Spec
spec = do
    let img = rowImage [PixelRGB8 10 20 30, PixelRGB8 40 50 60, PixelRGB8 70 80 90]
        specs = [PixelSort 0.0 Horizontal 0.3, RgbShift 2 True]

    describe "runPipeline reproducibility" $ do
        it "same seed yields identical output" $
            pixels (runPipeline (mkStdGen 42) specs img)
                `shouldBe` pixels (runPipeline (mkStdGen 42) specs img)

        it "the empty pipeline is the identity" $
            pixels (runPipeline (mkStdGen 42) [] img) `shouldBe` pixels img

        it "different seeds produce different output (seed-sensitivity)" $
            pixels (runPipeline (mkStdGen 1) specs img)
                `shouldNotBe` pixels (runPipeline (mkStdGen 2) specs img)

        it "fixed seed + pipeline + input yields known pixel list (golden)" $
            pixels (runPipeline (mkStdGen 2) specs img)
                `shouldBe` [ PixelRGB8 10 20 90
                           , PixelRGB8 40 50 30
                           , PixelRGB8 70 80 60
                           ]

    describe "runPipeline ordering" $
        it "order of filters affects the result" $ do
            let img2 = rowImage [PixelRGB8 70 80 90, PixelRGB8 40 50 60, PixelRGB8 10 20 30]
                a = [PixelSort 0.15 Horizontal 0.0, RgbShift 1 False]
                b = [RgbShift 1 False, PixelSort 0.15 Horizontal 0.0]
            pixels (runPipeline (mkStdGen 1) a img2)
                `shouldNotBe` pixels (runPipeline (mkStdGen 1) b img2)
