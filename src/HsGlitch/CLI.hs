module HsGlitch.CLI (
    Options (..),
    optionsParser,
    parseOptionsPure,
) where

import Options.Applicative

-- | Parsed command-line options.
data Options = Options
    { optInput :: FilePath
    , optOutput :: FilePath
    , optPipeline :: String
    , optSeed :: Maybe Int
    }
    deriving (Eq, Show)

-- | optparse-applicative parser for 'Options'.
optionsParser :: Parser Options
optionsParser =
    Options
        <$> strOption (long "input" <> short 'i' <> metavar "FILE" <> help "Input image path")
        <*> strOption (long "output" <> short 'o' <> metavar "FILE" <> help "Output image path")
        <*> strOption (long "pipeline" <> short 'p' <> metavar "DSL" <> help "Filter pipeline DSL")
        <*> optional
            (option auto (long "seed" <> short 's' <> metavar "INT" <> help "Random seed"))

-- | Pure option parsing for tests.
parseOptionsPure :: [String] -> Either String Options
parseOptionsPure args =
    case execParserPure defaultPrefs (info optionsParser fullDesc) args of
        Success opts -> Right opts
        Failure failure -> Left (fst (renderFailure failure "hsglitch"))
        CompletionInvoked _ -> Left "completion invoked"
