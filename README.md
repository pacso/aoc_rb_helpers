# AocRbHelpers

[![Gem Version](https://badge.fury.io/rb/aoc_rb_helpers.svg)](https://badge.fury.io/rb/aoc_rb_helpers)

This gem provides helper classes and functions to simplify solving [Advent of Code](https://adventofcode.com) puzzles. 
It is a companion gem to the [aoc_rb](https://github.com/pacso/aoc_rb) gem.

Be warned - using this gem might suck the fun out of solving the puzzles yourself!

## Getting Started

First of all, install the [aoc_rb](https://github.com/pacso/aoc_rb) gem and set up your project.

Next, add this gem to your project Gemfile, and run `bundle install`.

Open up `challenges/shared/solution.rb` in your project and require this gem at the top:

```ruby
# frozen_string_literal: true

require "aoc_rb_helpers"     # <-- Add this line

class Solution
  ...
end
```

You're good to go!

This gem additionally installs the excellent [puts_debuggerer](https://github.com/AndyObtiva/puts_debuggerer) gem, which you can use like this:

```ruby
pd some_object
```

You can read more on how you can use `pd` in their [README](https://github.com/AndyObtiva/puts_debuggerer/blob/master/README.md).

## Examples

Below are some examples of how you can use the features of this gem.

### Input manipulation

This example solution for 2024 Day 1 shows how the convenience methdos can be used to format the puzzle input:

```ruby
# frozen_string_literal: true

module Year2024
  class Day01 < Solution
    def part_1
      list_1, list_2 = data
      list_1.each_with_index.sum { |item, index| (item - list_2[index]).abs }
    end

    def part_2
      list_1, list_2 = data
      list_1.each.sum { |item| item * list_2.count(item) }
    end

    private

    def data
      aoc_input
        .multiple_lines
        .columns_of_numbers
        .transpose
        .sort_arrays
        .data
    end
  end
end
```

### Decoding printed text

```ruby
text_input = <<~EOF
  X  X XXXX X    X     XX  
  X  X X    X    X    X  X 
  XXXX XXX  X    X    X  X 
  X  X X    X    X    X  X 
  X  X X    X    X    X  X 
  X  X XXXX XXXX XXXX  XX  
EOF

input_array = text_input.lines(chomp: true).map(&:chars)
DotMatrix.decode(input_array) # returns the string "HELLO"
```
