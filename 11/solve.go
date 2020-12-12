package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

// Seat type
type Seat uint8

// Seat Enum
const (
	Floor    Seat = iota
	Empty    Seat = iota
	Occupied Seat = iota
)

// Position struct
type Position struct {
	X int
	Y int
}

// SeatPosition struct
type SeatPosition struct {
	Position Position
	Value    Seat
}

var seatMapping = map[rune]Seat{
	'.': Floor,
	'L': Empty,
	'#': Occupied,
}

var directions = [8]Position{
	Position{X: 1, Y: 1},
	Position{X: 1, Y: 0},
	Position{X: 1, Y: -1},
	Position{X: 0, Y: -1},
	Position{X: -1, Y: -1},
	Position{X: -1, Y: 0},
	Position{X: -1, Y: 1},
	Position{X: 0, Y: 1},
}

func loadData(data string) [][]Seat {
	matrix := [][]Seat{}

	for _, line := range strings.Split(data, "\n") {
		row := []Seat{}

		for _, char := range line {
			row = append(row, seatMapping[char])
		}

		if len(row) > 0 {
			matrix = append(matrix, row)
		}
	}

	return matrix
}

func countSeatsInMatrix(matrix [][]Seat) map[Seat]int {
	mapping := map[Seat]int{
		Floor:    0,
		Empty:    0,
		Occupied: 0,
	}

	for _, row := range matrix {
		for _, value := range row {
			mapping[value]++
		}
	}

	return mapping
}

func isOccupied(matrix [][]Seat, position, direction Position, firstOnly bool) bool {
	x := position.X
	y := position.Y
	xMin := 0
	xMax := len(matrix) - 1
	yMin := 0
	yMax := len(matrix[0]) - 1

	for true {
		x += direction.X
		y += direction.Y

		if x < xMin || x > xMax || y < yMin || y > yMax {
			break
		}

		seat := matrix[x][y]

		if seat == Occupied {
			return true
		} else if seat == Empty {
			return false
		}

		if firstOnly {
			break
		}
	}

	return false
}

func countOccupied(matrix [][]Seat, position Position, firstOnly bool) int {
	count := 0
	for _, direction := range directions {
		if isOccupied(matrix, position, direction, firstOnly) {
			count++
		}
	}
	return count
}

func changeSeat(matrix [][]Seat, seat SeatPosition, firstOnly bool) Seat {
	if seat.Value == Floor {
		return Floor
	}

	occupied := countOccupied(matrix, seat.Position, firstOnly)

	if seat.Value == Empty && occupied == 0 {
		return Occupied
	} else if seat.Value == Occupied && firstOnly && occupied >= 4 {
		return Empty
	} else if seat.Value == Occupied && !firstOnly && occupied >= 5 {
		return Empty
	} else {
		return seat.Value
	}
}

func changeSeatAsync(changed chan SeatPosition, matrix [][]Seat, seat SeatPosition, firstOnly bool) {
	valueAfter := changeSeat(matrix, seat, firstOnly)
	changed <- SeatPosition{Position: seat.Position, Value: valueAfter}
}

func findStableSeats(matrix [][]Seat, firstOnly bool) [][]Seat {
	matrix = copyMatrix(matrix)
	anyChanged := true

	for anyChanged {
		channels := []chan SeatPosition{}

		for x, row := range matrix {
			for y, value := range row {
				channel := make(chan SeatPosition)
				channels = append(channels, channel)
				position := Position{X: x, Y: y}
				seatPosition := SeatPosition{Position: position, Value: value}
				go changeSeatAsync(channel, matrix, seatPosition, firstOnly)
			}
		}

		anyChanged = false
		var seatPosition SeatPosition
		newSeatPositions := []SeatPosition{}
		for _, channel := range channels {
			seatPosition = <-channel
			newSeatPositions = append(newSeatPositions, seatPosition)

			position := seatPosition.Position
			changed := matrix[position.X][position.Y] != seatPosition.Value
			anyChanged = anyChanged || changed
		}

		for _, seatPosition := range newSeatPositions {
			position := seatPosition.Position
			matrix[position.X][position.Y] = seatPosition.Value
		}
	}
	return matrix
}

func copyMatrix(matrix [][]Seat) [][]Seat {
	newMatrix := [][]Seat{}
	for _, row := range matrix {
		newRow := []Seat{}
		for _, value := range row {
			newRow = append(newRow, value)
		}
		newMatrix = append(newMatrix, newRow)
	}
	return newMatrix
}

func main() {
	data, err := ioutil.ReadFile("input.txt")
	if err != nil {
		fmt.Println("File reading error", err)
		return
	}

	matrix := loadData(string(data[:]))

	part1Seats := findStableSeats(matrix, true)
	fmt.Println("Part 1: ", countSeatsInMatrix(part1Seats)[Occupied])

	part2Seats := findStableSeats(matrix, false)
	fmt.Println("Part 2: ", countSeatsInMatrix(part2Seats)[Occupied])
}
