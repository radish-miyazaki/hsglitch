module HsGlitch.CodecSpec (spec) where

import Codec.Picture (PixelRGB8 (..), generateImage, pixelAt)
import Data.Either (isLeft)
import HsGlitch.Codec (ImageFormat (..), formatFromPath, readImageRGB8, writeImageAuto)
import System.Directory (getTemporaryDirectory, removeFile)
import System.FilePath ((</>))
import Test.Hspec

spec :: Spec
spec = do
    describe "formatFromPath" $ do
        it "recognizes .png" $ formatFromPath "a.png" `shouldBe` Right FormatPng
        it "recognizes .jpg and .jpeg" $ do
            formatFromPath "a.jpg" `shouldBe` Right FormatJpg
            formatFromPath "a.JPEG" `shouldBe` Right FormatJpg
        it "rejects unsupported extensions" $
            formatFromPath "a.gif" `shouldSatisfy` isLeft

    describe "PNG round-trip" $
        it "writes then reads back an identical RGB8 image" $ do
            tmp <- getTemporaryDirectory
            let path = tmp </> "hsglitch-codec-test.png"
                img = generateImage (\x y -> PixelRGB8 (fromIntegral x) (fromIntegral y) 0) 4 4
            Right () <- writeImageAuto path img
            Right back <- readImageRGB8 path
            removeFile path
            pixelAt back 3 2 `shouldBe` pixelAt img 3 2
