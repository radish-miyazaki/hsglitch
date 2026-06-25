module HsGlitch.Parser (
    ParseError (..),
    parsePipeline,
) where

import Data.Char (isSpace)
import HsGlitch.Filter (FilterSpec (..))
import HsGlitch.Pixel (Direction (..))
import Text.Read (readMaybe)

-- | A human-readable pipeline parse failure.
newtype ParseError = ParseError String
    deriving (Eq, Show)

-- | Parse a pipeline DSL string into a list of filter specs.
parsePipeline :: String -> Either ParseError [FilterSpec]
parsePipeline input
    | all isSpace input = Left (ParseError "empty pipeline")
    | otherwise = traverse (parseStep . trim) (splitOn '|' input)

parseStep :: String -> Either ParseError FilterSpec
parseStep step = do
    kvs <- traverse parseParam rawParams
    buildFilter name kvs
    where
        (rawName, rest) = break (== ':') step
        name = trim rawName
        rawParams = case rest of
            [] -> []
            (_ : ps) -> map trim (splitOn ',' ps)

parseParam :: String -> Either ParseError (String, String)
parseParam p = case break (== '=') p of
    (k, '=' : v) -> Right (trim k, trim v)
    _ -> Left (ParseError ("invalid parameter: " ++ p))

buildFilter :: String -> [(String, String)] -> Either ParseError FilterSpec
buildFilter "pixelsort" kvs = do
    mapM_ (checkKey ["threshold", "direction", "jitter"] "pixelsort" . fst) kvs
    threshold <- getDouble "threshold" 0.5 kvs
    direction <- getDirection "direction" Horizontal kvs
    jitter <- getDouble "jitter" 0.0 kvs
    Right (PixelSort threshold direction jitter)
buildFilter "rgbshift" kvs = do
    mapM_ (checkKey ["shift", "random"] "rgbshift" . fst) kvs
    shift <- getInt "shift" 5 kvs
    rand <- getBool "random" False kvs
    Right (RgbShift shift rand)
buildFilter other _ = Left (ParseError ("unknown filter: " ++ other))

checkKey :: [String] -> String -> String -> Either ParseError ()
checkKey valid fname k
    | k `elem` valid = Right ()
    | otherwise = Left (ParseError ("unknown key '" ++ k ++ "' for " ++ fname))

getDouble :: String -> Double -> [(String, String)] -> Either ParseError Double
getDouble k def kvs = case lookup k kvs of
    Nothing -> Right def
    Just v -> maybe (Left (ParseError ("invalid number for " ++ k ++ ": " ++ v))) Right (readMaybe v)

getInt :: String -> Int -> [(String, String)] -> Either ParseError Int
getInt k def kvs = case lookup k kvs of
    Nothing -> Right def
    Just v -> maybe (Left (ParseError ("invalid integer for " ++ k ++ ": " ++ v))) Right (readMaybe v)

getBool :: String -> Bool -> [(String, String)] -> Either ParseError Bool
getBool k def kvs = case lookup k kvs of
    Nothing -> Right def
    Just "true" -> Right True
    Just "false" -> Right False
    Just v -> Left (ParseError ("invalid boolean for " ++ k ++ ": " ++ v))

getDirection :: String -> Direction -> [(String, String)] -> Either ParseError Direction
getDirection k def kvs = case lookup k kvs of
    Nothing -> Right def
    Just "horizontal" -> Right Horizontal
    Just "vertical" -> Right Vertical
    Just v -> Left (ParseError ("invalid direction: " ++ v))

-- | Trim leading and trailing whitespace.
trim :: String -> String
trim = f . f
    where
        f = reverse . dropWhile isSpace

-- | Split a string on a delimiter, keeping empty fields.
splitOn :: Char -> String -> [String]
splitOn c s = case break (== c) s of
    (a, []) -> [a]
    (a, _ : rest) -> a : splitOn c rest
