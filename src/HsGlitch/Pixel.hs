module HsGlitch.Pixel (
    Direction (..),
    luminance,
    pixelSort,
    rgbShift,
) where

import Codec.Picture (Image, PixelRGB8 (..), generateImage, imageHeight, imageWidth, pixelAt)
import Data.List (groupBy, mapAccumL, sortOn)
import qualified Data.Vector as V
import System.Random (StdGen, randomR)

-- | Sorting/shift axis.
data Direction = Horizontal | Vertical
    deriving (Eq, Show)

-- | Normalized perceptual luminance in [0, 1].
luminance :: PixelRGB8 -> Double
luminance (PixelRGB8 r g b) =
    (0.299 * fromIntegral r + 0.587 * fromIntegral g + 0.114 * fromIntegral b) / 255

{- | Sort each line's maximal above-threshold runs by luminance.
When jitter > 0, each line's effective threshold is perturbed by a
uniform value in [-jitter, jitter] drawn from the generator.
-}
pixelSort :: Double -> Direction -> Double -> Image PixelRGB8 -> StdGen -> (Image PixelRGB8, StdGen)
pixelSort threshold dir jitter img gen0 =
    let w = imageWidth img
        h = imageHeight img
        lineCount = case dir of Horizontal -> h; Vertical -> w
        lineLen = case dir of Horizontal -> w; Vertical -> h
        getPixel i k = case dir of
            Horizontal -> pixelAt img k i
            Vertical -> pixelAt img i k
        origLines = [[getPixel i k | k <- [0 .. lineLen - 1]] | i <- [0 .. lineCount - 1]]
        (gen1, sortedLines) = mapAccumL sortLine gen0 origLines
        lineVec = V.fromList (map V.fromList sortedLines)
        out =
            generateImage
                ( \x y -> case dir of
                    Horizontal -> (lineVec V.! y) V.! x
                    Vertical -> (lineVec V.! x) V.! y
                )
                w
                h
     in (out, gen1)
    where
        sortLine g line
            | jitter <= 0 = (g, sortRun threshold line)
            | otherwise =
                let (d, g') = randomR (-jitter, jitter) g
                    th' = max 0 (min 1 (threshold + d))
                 in (g', sortRun th' line)

-- | Sort maximal runs of above-threshold pixels ascending by luminance.
sortRun :: Double -> [PixelRGB8] -> [PixelRGB8]
sortRun th = concatMap process . groupBy sameSide
    where
        sameSide a b = (luminance a >= th) == (luminance b >= th)
        process grp = case grp of
            (p : _) | luminance p >= th -> sortOn luminance grp
            _ -> grp

{- | Shift the R channel right and the B channel left by `shift` pixels
(horizontal), keeping G fixed and wrapping at the edges. When `rand`
is True, per-channel offsets are drawn uniformly from [-shift, shift].
-}
rgbShift :: Int -> Bool -> Image PixelRGB8 -> StdGen -> (Image PixelRGB8, StdGen)
rgbShift shift rand img gen0 =
    let w = imageWidth img
        ((rOff, bOff), gen1)
            | not rand = ((shift, -shift), gen0)
            | otherwise =
                let (rs, g1) = randomR (-shift, shift) gen0
                    (bs, g2) = randomR (-shift, shift) g1
                 in ((rs, bs), g2)
        wrap x = ((x `mod` w) + w) `mod` w
        out =
            generateImage
                ( \x y ->
                    let PixelRGB8 r _ _ = pixelAt img (wrap (x - rOff)) y
                        PixelRGB8 _ g _ = pixelAt img x y
                        PixelRGB8 _ _ b = pixelAt img (wrap (x - bOff)) y
                     in PixelRGB8 r g b
                )
                w
                (imageHeight img)
     in (out, gen1)
