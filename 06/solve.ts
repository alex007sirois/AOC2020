const dataPromise = Deno.readTextFile("input.txt");

interface AggregateFunction {
  (group: string): Set<string>;
}

const aggregateAnyInGroup: AggregateFunction = (group) =>
  new Set(group.split("").filter((value) => /[A-Z]/i.test(value)));

const aggregateAllInGroup: AggregateFunction = (group) =>
  group
    .split("\n")
    .filter(Boolean)
    .map((r) => r.split(""))
    .map((r) => new Set(r))
    .reduce((a, b) => new Set([...a].filter((i) => b.has(i))));

const count = (data: string, aggregateFunc: AggregateFunction) =>
  data
    .split("\n\n")
    .map(aggregateFunc)
    .map((responses) => responses.size)
    .reduce((a, b) => a + b);

const data = await dataPromise;

const countAny = count(data, aggregateAnyInGroup);
console.log(`Part 1: ${countAny}`);

const countAll = count(data, aggregateAllInGroup);
console.log(`Part 2: ${countAll}`);
