open System

let highMiddle low high = low + (high - low) / 2
let lowMiddle low high = (highMiddle low high) + (high - low) % 2

let extractSeatPosition lowChar highChar low high pass =
    let rec extractSeatPositionRec pass low high =
        match pass, low, high with
        | _, l, h when h=l -> Ok low
        | c :: rest, _, _ when c=lowChar -> extractSeatPositionRec rest (lowMiddle low high) high
        | c :: rest, _, _ when c=highChar -> extractSeatPositionRec rest low (highMiddle low high)
        | s, l, h -> Error (sprintf "Bad input: %s %d %d" (string s) l h)
    extractSeatPositionRec (Seq.toList pass) low high

let extractRow = extractSeatPosition 'B' 'F' 0 127
let extractColumn = extractSeatPosition 'R' 'L' 0 7

let extractSeat (pass: string) =
    let rowResult = extractRow pass.[..6]
    let columnResult = extractColumn pass.[7..]
    match rowResult, columnResult with
    | Ok row, Ok column -> Ok (row, column)
    | Error row_e, Ok _ -> Error (sprintf "Row error: %s" row_e)
    | Ok _, Error column_e -> Error (sprintf "Column error: %s" column_e)
    | Error row_e, Error column_e -> Error (sprintf "Both errors: %s, %s" row_e column_e)

let logError input =
    match input with
    | Ok x -> Some x
    | Error e -> 
        printfn "%s" e
        None

let handleErrors = (Seq.map logError) >> (Seq.filter Option.isSome) >> (Seq.map (fun o -> o.Value))

let seatID (row, column) = (row * 8) + column

[<EntryPoint>]
let main argv =
    let seatIds =
        IO.File.ReadLines "input.txt"
        |> Seq.map extractSeat
        |> handleErrors
        |> Seq.map seatID
    printfn "Part 1: %d" (Seq.max seatIds)

    let seat = 
        seatIds
        |> Seq.sort
        |> Seq.pairwise
        |> Seq.filter (fun (a, b) -> b - a = 2)
        |> Seq.map (fun (a, b) -> b - 1)
        |> Seq.head
    printfn "Part 2: %d" seat

    0
