module HsGlitch.Filter (
    FilterSpec (..),
    interpret,
) where

import Codec.Picture (Image, PixelRGB8)
import Control.Monad.State (State, state)
import HsGlitch.Pixel (Direction, pixelSort, rgbShift)
import System.Random (StdGen)

-- | Declarative description of a single pipeline step.
data FilterSpec
    = PixelSort
        { psThreshold :: Double
        , psDirection :: Direction
        , psJitter :: Double
        }
    | RgbShift
        { rsShift :: Int
        , rsRandom :: Bool
        }
    deriving (Eq, Show)

-- | Turn a spec into a stateful image transform threading the generator.
interpret :: FilterSpec -> Image PixelRGB8 -> State StdGen (Image PixelRGB8)
interpret (PixelSort th dir jit) img = state (pixelSort th dir jit img)
interpret (RgbShift sh rnd) img = state (rgbShift sh rnd img)
