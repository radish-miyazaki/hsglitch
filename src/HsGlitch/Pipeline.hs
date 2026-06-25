module HsGlitch.Pipeline (
    runPipeline,
) where

import Codec.Picture (Image, PixelRGB8)
import Control.Monad ((>=>))
import Control.Monad.State (evalState)
import HsGlitch.Filter (FilterSpec, interpret)
import System.Random (StdGen)

-- | Apply filters left-to-right, threading the generator for reproducibility.
runPipeline :: StdGen -> [FilterSpec] -> Image PixelRGB8 -> Image PixelRGB8
runPipeline gen specs img =
    evalState (composed img) gen
    where
        composed = foldr ((>=>) . interpret) pure specs
