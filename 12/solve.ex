alias :math, as: Math

defmodule Ferry do
  @action_mapping %{
    "N" => :north,
    "E" => :east,
    "S" => :south,
    "W" => :west,
    "F" => :forward,
    "R" => :right,
    "L" => :left
  }
  @cardinal_mapping %{
    0 => :east,
    90 => :north,
    180 => :west,
    270 => :south
  }

  def manhattan_distance(values) do
    values
    |> Enum.map(&abs/1)
    |> Enum.sum()
  end

  def normalize_orientation(orientation) do
    new_orientation = rem(orientation, 360)

    if new_orientation < 0 do
      new_orientation + 360
    else
      new_orientation
    end
  end

  def rotate({x, y}, degree) do
    radian = Math.pi * degree / 180
    sin = Math.sin(radian)
    cos = Math.cos(radian)

    {
      x * cos - y * sin,
      y * cos + x * sin
    }
  end

  def transform(input) do
    action = Map.get(@action_mapping, String.first(input))
    value = String.to_integer(String.slice(input, 1..-1))

    {action, value}
  end

  def move({:north, value}, {x, y, orientation}) do
    {x, y + value, orientation}
  end

  def move({:south, value}, {x, y, orientation}) do
    {x, y - value, orientation}
  end

  def move({:east, value}, {x, y, orientation}) do
    {x + value, y, orientation}
  end

  def move({:west, value}, {x, y, orientation}) do
    {x - value, y, orientation}
  end

  def move({:forward, value}, {x, y, orientation}) do
    direction = Map.get(@cardinal_mapping, orientation)
    move({direction, value}, {x, y, orientation})
  end

  def move({:right, value}, {x, y, orientation}) do
    new_orientation = normalize_orientation(orientation - value)
    {x, y, new_orientation}
  end

  def move({:left, value}, {x, y, orientation}) do
    new_orientation = normalize_orientation(orientation + value)
    {x, y, new_orientation}
  end

  def move_waypoint({:north, value}, {ship, {x, y}}) do
    {ship, {x, y + value}}
  end

  def move_waypoint({:south, value}, {ship, {x, y}}) do
    {ship, {x, y - value}}
  end

  def move_waypoint({:east, value}, {ship, {x, y}}) do
    {ship, {x + value, y}}
  end

  def move_waypoint({:west, value}, {ship, {x, y}}) do
    {ship, {x - value, y}}
  end

  def move_waypoint({:forward, value}, {{x, y}, waypoint}) do
    {diff_x, diff_y} = waypoint
    new_x = round(value * diff_x + x)
    new_y = round(value * diff_y + y)
    {{new_x, new_y}, waypoint}
  end

  def move_waypoint({:right, value}, {ship, waypoint}) do
    {ship, rotate(waypoint, -value)}
  end

  def move_waypoint({:left, value}, {ship, waypoint}) do
    {ship, rotate(waypoint, value)}
  end
end

instructions =
  File.stream!("input.txt")
  |> Stream.map(&String.trim/1)
  |> Stream.map(&Ferry.transform/1)

starting_state = {0, 0, 0}
{x, y, _} = Enum.reduce(instructions, starting_state, &Ferry.move/2)
distance = Ferry.manhattan_distance([x, y])
IO.puts("Part 1: #{distance}")

ship_start = {0, 0}
waypoint_start = {10, 1}
starting_state = {ship_start, waypoint_start}
{{x, y}, _} = Enum.reduce(instructions, starting_state, &Ferry.move_waypoint/2)
distance = Ferry.manhattan_distance([x, y])
IO.puts("Part 2: #{distance}")
