module HsGlitch.PixelSpec (spec) where

import Codec.Picture (Image, PixelRGB8 (..), generateImage, pixelAt)
import HsGlitch.Pixel (Direction (..), luminance, pixelSort)
import System.Random (mkStdGen)
import Test.Hspec

-- Build a width*1 image from an explicit pixel list (row).
rowImage :: [PixelRGB8] -> Image PixelRGB8
rowImage ps = generateImage (\x _ -> ps !! x) (length ps) 1

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
          p3 = PixelRGB8 0 0 0       -- lum 0.0
          img = rowImage [p1, p2, p3]
          (out, _) = pixelSort 0.5 Horizontal 0.0 img (mkStdGen 1)
      -- [p1,p2] are above threshold and get sorted ascending -> [p2,p1]; p3 stays.
      [pixelAt out 0 0, pixelAt out 1 0, pixelAt out 2 0]
        `shouldBe` [p2, p1, p3]
