let rec input_lines file =
   match try [input_line file] with End_of_file -> [] with
      | [] -> []
      | line -> line @ input_lines file

let pairs data =
    let rec aux first second acc =
        match first, second with
            | [], _ -> acc
            | _, [] -> acc
            | (f :: frest), (s :: srest) -> (f, s) :: aux frest srest acc
    in
    aux data (List.tl data) []

let tribonacci count =
    let rec aux n a b c =
        match n with
        | 0 -> c
        | _ -> aux (n-1) b c (a+b+c)
    in
    aux count 0 0 1

let count_total_possibilities diffs = 
    let rec aux diffs count acc =
        match diffs, count with
        | [], 0 -> acc
        | 1 :: rest, _ -> aux rest (count + 1) acc
        | _ :: rest, 0 -> aux rest 0 acc
        | _, _ -> aux diffs 0 (acc * (tribonacci count))
    in
    aux diffs 0 1

let adapters = input_lines (open_in "input.txt")
|> List.map int_of_string
|> List.fast_sort compare

let differentials = pairs (0 :: adapters)
|> List.map (fun (a, b) -> b - a)
|> List.append [3]

let count_1 = List.length (List.filter ((==) 1) differentials);;
let count_3 = List.length (List.filter ((==) 3) differentials);;
let part_1_result = count_1 * count_3;;
Printf.printf "Part 1: %d\n" part_1_result;;

let part_2_result = count_total_possibilities differentials;;
Printf.printf "Part 2: %d\n" part_2_result;;
