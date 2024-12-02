# frozen_string_literal: true

class DotMatrix
  CHAR_WIDTH = 5
  DICTIONARY = {
    a: [
      " XX  ",
      "X  X ",
      "X  X ",
      "XXXX ",
      "X  X ",
      "X  X "
    ],
    b: [
      "XXX  ",
      "X  X ",
      "XXX  ",
      "X  X ",
      "X  X ",
      "XXX  "
    ],
    c: [
      " XX  ",
      "X  X ",
      "X    ",
      "X    ",
      "X  X ",
      " XX  "
    ],
    e: [
      "XXXX ",
      "X    ",
      "XXX  ",
      "X    ",
      "X    ",
      "XXXX "
    ],
    f: [
      "XXXX ",
      "X    ",
      "XXX  ",
      "X    ",
      "X    ",
      "X    "
    ],
    g: [
      " XX  ",
      "X  X ",
      "X    ",
      "X XX ",
      "X  X ",
      " XXX "
    ],
    h: [
      "X  X ",
      "X  X ",
      "XXXX ",
      "X  X ",
      "X  X ",
      "X  X ",
    ],
    j: [
      "  XX ",
      "   X ",
      "   X ",
      "   X ",
      "X  X ",
      " XX  ",
    ],
    k: [
      "X  X ",
      "X X  ",
      "XX   ",
      "X X  ",
      "X X  ",
      "X  X ",
    ],
    l: [
      "X    ",
      "X    ",
      "X    ",
      "X    ",
      "X    ",
      "XXXX ",
    ],
    o: [
      " XX  ",
      "X  X ",
      "X  X ",
      "X  X ",
      "X  X ",
      " XX  "
    ],
    p: [
      "XXX  ",
      "X  X ",
      "X  X ",
      "XXX  ",
      "X    ",
      "X    ",
    ],
    r: [
      "XXX  ",
      "X  X ",
      "X  X ",
      "XXX  ",
      "X X  ",
      "X  X ",
    ],
    s: [
      " XXX ",
      "X    ",
      "X    ",
      " XX  ",
      "   X ",
      "XXX  ",
    ],
    u: [
      "X  X ",
      "X  X ",
      "X  X ",
      "X  X ",
      "X  X ",
      " XX  ",
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
      "XXXX ",
      "   X ",
      "  X  ",
      " X   ",
      "X    ",
      "XXXX ",
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
    (0...max_chars).map do |char_index|
      begin
        char_map = printable_content.map do |row|
          row[char_offset(char_index)...char_offset(char_index + 1)].join
        end

        unless @on == "X" && @off == " "
          new_map = []
          char_map.each do |row|
            row_chars = []
            row.chars.each do |cell|
              row_chars.push(cell == @on ? "X" : " ")
            end
            new_map.push(row_chars.join)
          end
          char_map = new_map
        end

        DICTIONARY.find { |_, map| map == char_map }[0].to_s.upcase
      rescue NoMethodError
        puts "ERROR: Missing character in dictionary:\n\n"
        print(char_map)
        puts "\nReverting to ASCII:\n\n"
        print
        break
      end
    end.join
  end

  private
  def char_offset(index)
    index * CHAR_WIDTH
  end

  def printable_range(row)
    row[first_position..last_position]
  end

  def printable_content
    @input.map { |row| printable_range(row) }
  end

  def first_position
    @input.map { |row| row.index { |dot| dot != ' ' } }.min
  end

  def last_position
    @input.map { |row| row.rindex { |dot| dot != ' ' } }.max + 1
  end

  def max_chars
    printable_content.first.length / CHAR_WIDTH
  end
end
