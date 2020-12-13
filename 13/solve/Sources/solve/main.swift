import Foundation

func readFile(file: String) -> String {
    let fileManager = FileManager.default
    let path = fileManager.currentDirectoryPath
    let inputPath = path.appendingPathComponent(file)
    let inputURL = URL(fileURLWithPath: inputPath)
    return try! String(contentsOf: inputURL, encoding: .utf8)
}

func transformData(data: String) -> (Int, [Int?]) {
    let separated_data = data.components(separatedBy: "\n")
    let departure = Int(separated_data[0])!
    let busTimelines = separated_data[1]
        .components(separatedBy: ",")
        .map {busId in Int(busId)}
    return (departure, busTimelines)
}

func findMinimumWait(departure: Int, busId: Int) -> Int {
    let rem = departure % busId
    return rem == 0 ? rem : busId - rem
}

func ceilDiv(a: Int, b: Int) -> Int {
    return Int(ceil(Float(a) / Float(b)))
}

func findIntersection(firstBus: (Int, Int), secondBus: (Int, Int)) -> (Int, Int) {
    // f(x) = ax + b
    let (a1, b1) = firstBus
    let (a2, b2) = secondBus

    let a = a1 * a2
    
    var first = b1
    var second = b2
    repeat {
        if first < second {
            let diff = second - first
            let x = ceilDiv(a: diff, b: a1)
            first += x * a1
        } else if second < first {
            let diff = first - second
            let x = ceilDiv(a: diff, b: a2)
            second += x * a2
        }
    } while first != second

    let b = first

    return (a, b)
}

let (departure, busTimelines) = transformData(data: readFile(file: "input.txt"))

let (earliestBus, wait) = busTimelines
    .filter {busId in busId != nil}
    .map {busId in busId!}
    .map {busId in (busId, findMinimumWait(departure: departure, busId: busId))}
    .min(by: {$0.1 < $1.1})!

print("Part 1: \(earliestBus * wait)")

let (_, time) = busTimelines
    .enumerated()
    .filter {(_, busId) in busId != nil}
    .map {(i, busId) in (busId!, -i)}
    .reduce((1, 0), findIntersection)

print("Part 2: \(time)")
