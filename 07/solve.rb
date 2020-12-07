class Constraint
  attr_reader :count, :color
  def initialize(count, color)
    @count = count
    @color = color
  end

  def +(other)
    raise "Can't add Constraints of different colors '#{@color}' '#{other.color}'" if @color != other.color

    Constraint.new(@count + other.count, @color)
  end

  def *(other)
    Constraint.new(@count * other, @color)
  end
end

def extract_color(value)
  /((?:\w|\ )+) bags?/.match(value).captures[0]
end

def extract_bag_content(contraint)
  count, color = /(\d+) ((?:\w|\ )+) bags?/.match(contraint).captures
  Constraint.new(count.to_i, color)
end

def extract_bag_rule(rule)
  bag, inside = rule.split(' contain ')
  bag_color = extract_color bag

  content = if /no other bags./.match? inside
              []
            else
              inside.chomp('.').split(', ').map { |c| extract_bag_content(c) }
            end

  [bag_color, content]
end

def contains_color?(constraints, color)
  constraints.any? { |c| c.color == color }
end

def bag_rules_to_recursive_bag_rules(rules)
  recursive_rules = {}

  rules.each_pair do |bag_color, contraints|
    queue = Array.new contraints
    contraints_mapping = Hash.new { |h, color| h[color] = Constraint.new(0, color) }

    until queue.empty?
      constraint = queue.pop
      count = constraint.count
      color = constraint.color

      queue += rules[color].map { |c| c * count }
      contraints_mapping[color] += constraint
    end

    recursive_rules[bag_color] = contraints_mapping.values
  end

  recursive_rules
end

file_data = File.readlines('input.txt').map(&:chomp)
rules = file_data.map { |r| extract_bag_rule(r) } .to_h
recursive_rules = bag_rules_to_recursive_bag_rules rules

color = 'shiny gold'
target_bags = recursive_rules.select { |_color, contraints| contains_color?(contraints, color) }
puts "Part 1: #{target_bags.length}"

puts "Part 2: #{recursive_rules[color].map(&:count).inject(0, :+)}"
