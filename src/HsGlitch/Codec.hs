module HsGlitch.Codec (
    CodecError (..),
    ImageFormat (..),
    formatFromPath,
    readImageRGB8,
    writeImageAuto,
) where

import Codec.Picture (
    DynamicImage (ImageRGB8),
    Image,
    PixelRGB8,
    convertRGB8,
    readImage,
    saveJpgImage,
    savePngImage,
 )
import Data.Char (toLower)
import System.FilePath (takeExtension)

-- | An image read/write failure.
newtype CodecError = CodecError String
    deriving (Eq, Show)

-- | Supported output container formats.
data ImageFormat = FormatPng | FormatJpg
    deriving (Eq, Show)

-- | Choose an output format from a file extension.
formatFromPath :: FilePath -> Either CodecError ImageFormat
formatFromPath path = case map toLower (takeExtension path) of
    ".png" -> Right FormatPng
    ".jpg" -> Right FormatJpg
    ".jpeg" -> Right FormatJpg
    ext -> Left (CodecError ("unsupported image format: " ++ ext))

-- | Read any supported image and normalize to RGB8.
readImageRGB8 :: FilePath -> IO (Either CodecError (Image PixelRGB8))
readImageRGB8 path = do
    res <- readImage path
    pure $ case res of
        Left err -> Left (CodecError err)
        Right dyn -> Right (convertRGB8 dyn)

-- | Write an RGB8 image, selecting the encoder by file extension.
writeImageAuto :: FilePath -> Image PixelRGB8 -> IO (Either CodecError ())
writeImageAuto path img = case formatFromPath path of
    Left err -> pure (Left err)
    Right FormatPng -> savePngImage path (ImageRGB8 img) >> pure (Right ())
    Right FormatJpg -> saveJpgImage 90 path (ImageRGB8 img) >> pure (Right ())
