{-# LANGUAGE ScopedTypeVariables #-}

module Main (main) where

import Codec.Picture (Image, PixelRGB8)
import Control.Exception (SomeException, catch, fromException, throwIO)
import HsGlitch.CLI (Options (..), optionsParser)
import HsGlitch.Codec (CodecError (..), readImageRGB8, writeImageAuto)
import HsGlitch.Parser (ParseError (..), parsePipeline)
import HsGlitch.Pipeline (runPipeline)
import Options.Applicative (
    execParser,
    fullDesc,
    header,
    helper,
    info,
    progDesc,
    (<**>),
 )
import System.Exit (ExitCode (..), exitWith)
import System.IO (hPutStrLn, stderr)
import System.Random (initStdGen, mkStdGen)

main :: IO ()
main = do
    opts <-
        execParser $
            info
                (optionsParser <**> helper)
                (fullDesc <> progDesc "Transform an image into glitch art" <> header "hsglitch")
    run opts `catch` \(e :: SomeException) ->
        case fromException e :: Maybe ExitCode of
            Just ec -> throwIO ec
            Nothing -> failWith 3 ("unexpected error: " ++ show e)

run :: Options -> IO ()
run opts =
    case parsePipeline (optPipeline opts) of
        Left (ParseError msg) -> failWith 1 ("pipeline parse error: " ++ msg)
        Right specs -> do
            readResult <- readImageRGB8 (optInput opts)
            case readResult of
                Left (CodecError msg) -> failWith 2 ("read error: " ++ msg)
                Right img -> do
                    gen <- maybe initStdGen (pure . mkStdGen) (optSeed opts)
                    let out = runPipeline gen specs img :: Image PixelRGB8
                    writeResult <- writeImageAuto (optOutput opts) out
                    case writeResult of
                        Left (CodecError msg) -> failWith 2 ("write error: " ++ msg)
                        Right () -> pure ()

failWith :: Int -> String -> IO ()
failWith code msg = hPutStrLn stderr msg >> exitWith (ExitFailure code)
