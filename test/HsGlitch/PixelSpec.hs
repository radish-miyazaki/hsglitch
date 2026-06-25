module HsGlitch.PixelSpec (spec) where

import Codec.Picture (Image, PixelRGB8 (..), generateImage, pixelAt)
import HsGlitch.Pixel (Direction (..), luminance, pixelSort, rgbShift)
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

    describe "rgbShift (random=False)" $
        it "shifts R right and B left by `shift`, wrapping around" $ do
            let x0 = PixelRGB8 10 20 30
                x1 = PixelRGB8 40 50 60
                x2 = PixelRGB8 70 80 90
                img = rowImage [x0, x1, x2]
                (out, _) = rgbShift 1 False img (mkStdGen 7)
            -- out x: R from (x-1) mod 3, G from x, B from (x+1) mod 3
            [pixelAt out 0 0, pixelAt out 1 0, pixelAt out 2 0]
                `shouldBe` [PixelRGB8 70 20 60, PixelRGB8 10 50 90, PixelRGB8 40 80 30]

    describe "rgbShift (shift=0)" $
        it "is the identity" $ do
            let img = rowImage [PixelRGB8 10 20 30, PixelRGB8 40 50 60]
                (out, _) = rgbShift 0 False img (mkStdGen 7)
            [pixelAt out 0 0, pixelAt out 1 0]
                `shouldBe` [PixelRGB8 10 20 30, PixelRGB8 40 50 60]
