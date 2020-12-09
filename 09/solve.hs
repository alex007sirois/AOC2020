import Control.Monad (replicateM)

preambleSize :: Int
preambleSize = 25

calculate :: [Int] -> Int -> Bool
calculate xs x = any ((x ==) . sum) (replicateM 2 xs)

part1Rec :: [Int] -> [Int] -> Maybe Int
part1Rec _ [] = Nothing
part1Rec preamble values
  | calculate (take preambleSize preamble) (head values) = part1Rec (tail preamble) (tail values)
  | otherwise = Just (head values)

part1 :: [Int] -> Maybe Int
part1 xs = part1Rec xs (drop preambleSize xs)

part2Rec :: Int -> [Int] -> Int -> Maybe [Int]
part2Rec _ [] _ = Nothing
part2Rec x xs count
  | x == y = Just subSeq
  | x > y = part2Rec x xs (count + 1)
  | x < y = part2Rec x (tail xs) (count - 1)
  where
    subSeq = take count xs
    y = sum subSeq

part2 :: Maybe Int -> [Int] -> Maybe Int
part2 Nothing _ = Nothing
part2 (Just x) xs = (Just . extractEncryptionWeakness) =<< part2Rec x xs 1

extractEncryptionWeakness :: [Int] -> Int
extractEncryptionWeakness xs = maximum xs + minimum xs

main :: IO ()
main = do
  contents <- readFile "input.txt"
  let input = map read . lines $ contents

  let invalidNumber = part1 input
  putStr "Part 1: "
  print invalidNumber

  let encryptionWeakness = part2 invalidNumber input
  putStr "Part 2: "
  print encryptionWeakness
