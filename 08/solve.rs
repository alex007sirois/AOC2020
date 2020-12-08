use std::collections::HashMap;
use std::collections::HashSet;
use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

#[derive(Copy,Clone)]
enum Instruction {
    Nop(),
    Jmp(i64),
    Acc(i64),
}

fn get_diff(instruction: &Instruction) -> (i64, i64) {
    match instruction {
        Instruction::Nop() => (1, 0),
        Instruction::Acc(x) => (1, *x),
        Instruction::Jmp(x) => (*x, 0),
    }
}

fn main() {
    let path = Path::new("input.txt");
    let data: Vec<Instruction> = load(&path).map(transform).collect();

    part_1(&data);
    part_2(&data);
}

fn part_1(data: &Vec<Instruction>) {
    let (accumulator, position, _, _) = read_instructions(data);
    println!("Part 1: accumulator {}, position {}", accumulator, position);
}

fn part_2(data: &Vec<Instruction>) {
    let mut modified_data: Vec<Instruction> = data.to_vec();
    let mut queue: HashSet<usize> = HashSet::new();
    let mut tried: HashSet<usize> = HashSet::new();
    let mut accumulator: Option<i64> = None;

    loop {
        let (acc, _, success, path) = read_instructions(&modified_data);

        if success {
            accumulator = Some(acc);
            break;
        }

        queue.extend(
            path.iter()
                .filter(|p| !tried.contains(p))
                .filter(|p| match data[**p] {
                    Instruction::Jmp(_) => true,
                    _ => false,
                })
        );
        let position = match queue.iter().next() {
            Some(p) => *p,
            None => break,
        };
        queue.remove(&position);
        tried.insert(position);

        modified_data = data.to_vec();
        modified_data[position] = Instruction::Nop();
    }
    match accumulator {
        Some(acc) => println!("Part 2: accumulator {}", acc),
        None => println!("Part 2: could not fix program"),
    }
    
}

fn read_instructions(data: &Vec<Instruction>) -> (i64, usize, bool, Vec<usize>) {
    let success_position = data.len();
    let mut accumulator: i64 = 0;
    let mut position: usize = 0;
    let mut success = false;
    let mut visited: HashSet<usize> = HashSet::new();
    let mut path: Vec<usize> = Vec::new();

    while !success && !visited.contains(&position) {
        visited.insert(position);
        path.push(position);

        let (pos_diff, acc_diff) = get_diff(&data[position]);

        position = add(position, pos_diff);
        accumulator += acc_diff;
        success = position >= success_position;
    }

    (accumulator, position, success, path)
}

fn load(path: &Path) -> io::Lines<io::BufReader<File>> {
    let display = path.display();

    let file = match File::open(&path) {
        Ok(file) => file,
        Err(reason) => panic!("Couldn't open {}: {}", display, reason),
    };

    io::BufReader::new(file).lines()
}

fn transform(line: std::result::Result<String, std::io::Error>) -> Instruction {
    let line = match line {
        Err(reason) => panic!("Couldn't transform because: {}", reason),
        Ok(l) => l,
    };
    let mut line = line.split_whitespace();

    let instruction = line.next().unwrap();
    let number = line.next().unwrap();

    let number = i64::from_str_radix(number, 10).unwrap();

    match instruction {
        "jmp" => Instruction::Jmp(number),
        "acc" => Instruction::Acc(number),
        "nop" => Instruction::Nop(),
        _ => panic!(
            "Couldn't transform because: unknown instruction {}",
            instruction
        ),
    }
}

fn add(a: usize, b: i64) -> usize {
    let c = (a as i64) + b;
    if c < 0 {
        panic!("Negative unsigned")
    };
    c as usize
}
