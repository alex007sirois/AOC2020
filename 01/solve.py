from pathlib import Path
from typing import Iterator, Collection, Optional, Tuple, Callable
from operator import add, sub, mul, getitem
from functools import reduce, partial


def get_data(path: Path) -> Collection[int]:
    return tuple(map(int, path.read_text().split()))


def calculate_next_entries(
    function: Callable[[int], int],
    entries: Tuple[int, ...],
) -> Iterator[Tuple[int, ...]]:
    for index in range(len(entries)):
        yield (*entries[:index], function(entries[index]), *entries[index+1:])


def find_entries(
    data: Collection[int],
    entries_count: int,
    target_value: int = 2020,
) -> Optional[int]:
    size = len(data)
    sorted_data = sorted(data)

    mid_start = (size - entries_count) // 2
    mid_point = tuple(range(mid_start, mid_start + entries_count))
    queue = [mid_point]
    visited = set()

    while queue:
        entries = queue.pop()
        visited.add(entries)

        values = tuple(map(partial(getitem, sorted_data), entries))
        entries_sum = sum(values)

        if entries_sum == target_value:
            return reduce(mul, values)

        operator = add if entries_sum < target_value else sub
        next_entries = calculate_next_entries(lambda x: operator(x, 1), entries)
        next_entries = filter(lambda next_point: next_point not in visited, next_entries)
        next_entries = filter(lambda next_point: all(p != next_point[0] for p in next_point[1:]), next_entries)
        next_entries = filter(lambda next_point: all(p in range(size) for p in next_point), next_entries)
        queue.extend(next_entries)


if __name__ == "__main__":
    data = get_data(Path("input.txt"))
    print(f"pair: {find_entries(data, 2)}")
    print(f"triplet: {find_entries(data, 3)}")
