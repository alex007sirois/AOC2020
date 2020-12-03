import streams, sequtils


proc is_tree_present(s: char): bool =
    case s
    of '#':
        return true
    of '.':
        return false
    else:
        raise newException(ValueError, "Bad Value in data")


proc load_data(file: string): seq[seq[bool]] =
    let strm = newFileStream(file, fmRead)
    var tree_matrix = newSeq[seq[bool]]()
    var line = ""

    if isNil(strm):
        raise newException(IOError, "Provided file does not exist")
    
    try:
        while strm.readLine(line):
            var tree_line = newSeq[bool]()
            for s in line.items():
                tree_line.add(is_tree_present(s))
            tree_matrix.add(tree_line)
    finally:
        strm.close()

    tree_matrix


proc solve(x_step: int, y_step: int, tree_matrix: seq[seq[bool]]): int =
    let 
        x_size = tree_matrix[0].len()
        y_size = tree_matrix.len()
    var 
        count = 0
        x = 0
        y = 0

    while y < y_size:
        count += int(tree_matrix[y][x])
        x = (x + x_step) mod x_size
        y += y_step

    count


let tree_matrix = load_data("input.txt")
let steps = @[(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
var results = newSeq[int]()
for _, (x, y) in steps:
    results.add(solve(x, y, tree_matrix))
echo results
echo foldr(results, a * b)
