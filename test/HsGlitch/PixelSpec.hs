module HsGlitch.PixelSpec (spec) where

import Codec.Picture (Image, PixelRGB8 (..), generateImage, pixelAt)
import HsGlitch.Pixel (Direction (..), luminance, pixelSort)
import System.Random (mkStdGen)
import Test.Hspec

-- Build a width*1 image from an explicit pixel list (row).
rowImage :: [PixelRGB8] -> Image PixelRGB8
rowImage ps = generateImage (\x _ -> ps !! x) (length ps) 1

-- Build a 1*height image from an explicit pixel list (column).
colImage :: [PixelRGB8] -> Image PixelRGB8
colImage ps = generateImage (\_ y -> ps !! y) 1 (length ps)

spec :: Spec
spec = do
    describe "luminance" $ do
        it "white is 1.0" $
            luminance (PixelRGB8 255 255 255) `shouldBe` 1.0
        it "black is 0.0" $
            luminance (PixelRGB8 0 0 0) `shouldBe` 0.0

    describe "pixelSort (horizontal, jitter=0)" $
        it "sorts the above-threshold run ascending by luminance" $ do
            let p1 = PixelRGB8 255 255 255 -- lum 1.0
                p2 = PixelRGB8 128 128 128 -- lum ~0.502 (>= 0.5)
                p3 = PixelRGB8 0 0 0 -- lum 0.0
                img = rowImage [p1, p2, p3]
                (out, _) = pixelSort 0.5 Horizontal 0.0 img (mkStdGen 1)
            -- [p1,p2] are above threshold and get sorted ascending -> [p2,p1]; p3 stays.
            [pixelAt out 0 0, pixelAt out 1 0, pixelAt out 2 0]
                `shouldBe` [p2, p1, p3]

    describe "pixelSort (vertical, jitter=0)" $
        it "sorts the above-threshold column run ascending by luminance" $ do
            let p1 = PixelRGB8 255 255 255 -- lum 1.0
                p2 = PixelRGB8 128 128 128 -- lum ~0.502 (>= 0.5)
                p3 = PixelRGB8 0 0 0 -- lum 0.0
                img = colImage [p1, p2, p3]
                (out, _) = pixelSort 0.5 Vertical 0.0 img (mkStdGen 1)
            -- [p1,p2] are above threshold and get sorted ascending -> [p2,p1]; p3 stays.
            [pixelAt out 0 0, pixelAt out 0 1, pixelAt out 0 2]
                `shouldBe` [p2, p1, p3]

    describe "pixelSort (jitter>0)" $
        it "advances the generator when jitter > 0" $ do
            let p1 = PixelRGB8 255 255 255
                img = rowImage [p1]
                g0 = mkStdGen 1
                (_, g1) = pixelSort 0.5 Horizontal 0.5 img g0
            show g1 `shouldNotBe` show g0
