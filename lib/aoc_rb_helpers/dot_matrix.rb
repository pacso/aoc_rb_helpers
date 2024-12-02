# frozen_string_literal: true

class DotMatrix
  DICTIONARY = {
    a: [
      " XX ",
      "X  X",
      "X  X",
      "XXXX",
      "X  X",
      "X  X"
    ],
    b: [
      "XXX ",
      "X  X",
      "XXX ",
      "X  X",
      "X  X",
      "XXX "
    ],
    c: [
      " XX ",
      "X  X",
      "X   ",
      "X   ",
      "X  X",
      " XX "
    ],
    d: [
      "XXX ",
      "X  X",
      "X  X",
      "X  X",
      "X  X",
      "XXX "
    ],
    e: [
      "XXXX",
      "X   ",
      "XXX ",
      "X   ",
      "X   ",
      "XXXX"
    ],
    f: [
      "XXXX",
      "X   ",
      "XXX ",
      "X   ",
      "X   ",
      "X   "
    ],
    g: [
      " XX ",
      "X  X",
      "X   ",
      "X XX",
      "X  X",
      " XXX"
    ],
    h: [
      "X  X",
      "X  X",
      "XXXX",
      "X  X",
      "X  X",
      "X  X",
    ],
    i: [
      "XXX",
      " X ",
      " X ",
      " X ",
      " X ",
      "XXX"
    ],
    j: [
      "  XX",
      "   X",
      "   X",
      "   X",
      "X  X",
      " XX ",
    ],
    k: [
      "X  X",
      "X X ",
      "XX  ",
      "X X ",
      "X X ",
      "X  X",
    ],
    l: [
      "X   ",
      "X   ",
      "X   ",
      "X   ",
      "X   ",
      "XXXX",
    ],
    o: [
      " XX ",
      "X  X",
      "X  X",
      "X  X",
      "X  X",
      " XX "
    ],
    p: [
      "XXX ",
      "X  X",
      "X  X",
      "XXX ",
      "X   ",
      "X   ",
    ],
    r: [
      "XXX ",
      "X  X",
      "X  X",
      "XXX ",
      "X X ",
      "X  X",
    ],
    s: [
      " XXX",
      "X   ",
      "X   ",
      " XX ",
      "   X",
      "XXX ",
    ],
    t: [
      "XXX",
      " X ",
      " X ",
      " X ",
      " X ",
      " X "
    ],
    u: [
      "X  X",
      "X  X",
      "X  X",
      "X  X",
      "X  X",
      " XX ",
    ],
    y: [
      "X   X",
      "X   X",
      " X X ",
      "  X  ",
      "  X  ",
      "  X  "
    ],
    z: [
      "XXXX",
      "   X",
      "  X ",
      " X  ",
      "X   ",
      "XXXX",
    ]
  }

  # Returns the decoded input using the specified characters for printed text (on) and whitespace (off).
  # @param [Array<Array<String>>] input a two-dimensional array of characters
  # @param on [String] specifies the character representing the "on" state, or printed text
  # @param off [String] specifies the character representing the "off" state, or whitespace
  # @return [String] the decoded string
  def self.decode(input, on: "X", off: " ")
    new(input, on, off).to_s
  end

  # @param [Array<Array<String>>] input a two-dimensional array of characters
  # @param on [String] specifies the character representing the "on" state, or printed text
  # @param off [String] specifies the character representing the "off" state, or whitespace
  def initialize(input, on = "X", off = " ")
    @input = input
    @on = on
    @off = off

    convert_characters
  end

  # Prints the input array to STDOUT and returns self.
  # @return [DotMatrix] self
  def print(input = @input)
    input.each do |row|
      puts row.is_a?(String) ? row : row.join
    end
    self
  end

  # Prints the decoded input to STDOUT and returns self.
  # @return [DotMatrix] self
  def print_decoded
    puts to_s
    self
  end

  # Returns the decoded input.
  # @return [String] the decoded input
  def to_s
    cursor = 0
    decoded = ""
    while cursor < max_cursor
      begin
        cursor += 1 while @input.all? { |row| row[cursor] == ' ' }
        cursor_end = cursor_range(cursor)
        char_map = @input.map do |row|
          row[cursor...cursor_end].join
        end
        cursor = cursor_end

        decoded += DICTIONARY.find { |_, map| map == char_map }[0].to_s.upcase
      rescue NoMethodError
        puts "ERROR: Missing character in dictionary:\n\n"
        print(char_map)
        puts "\nReverting to ASCII:\n\n"
        print
        break
      end
    end

    decoded
  end

  private

  def convert_characters
    unless @on == "X" && @off == " "
      @input = @input.map do |row|
        row.map do |cell|
          cell == @on ? "X" : " "
        end
      end
    end
  end

  def cursor_range(cursor)
    c = cursor
    c += 1 while @input.any? { |row| row[c] != ' ' } && c - cursor < max_cursor_range
    c
  end

  def max_cursor
    @input.first.length - 4
  end

  def max_cursor_range
    DICTIONARY.values.map { |v| v.first.length }.max
  end
end
