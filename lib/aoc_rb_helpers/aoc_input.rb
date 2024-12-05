# frozen_string_literal: true

# Provides input manipulation helper methods.
# Methods are chainable, and directly modify the parsed view of the input data within the +@data+ instance variable.
#
# Once manipulated as required, the input is accessable using the {#data} method.
class AocInput
  # Returns a new AocInput initialized with the given puzzle input.
  #
  # @param puzzle_input [String] the puzzle input as a single string with embedded newline characters
  def initialize(puzzle_input)
    @raw_input = puzzle_input
    configure_method_access
  end

  # Returns the parsed puzzle input.
  #
  # If the data has not been parsed yet, it defaults to the raw input provided in {initialize}.
  #
  # @return [Object] the parsed puzzle input
  def data
    @data ||= @raw_input
  end

  # Splits the input string into an array of lines.
  #
  # This method processes +@data+ by splitting the input string into multiple lines,
  # removing trailing newline characters. It modifies +@data+ directly and returns +self+
  # to enable method chaining.
  #
  # @return [AocInput] self
  def multiple_lines
    @data = data.lines(chomp: true)
    allow(:columns_of_numbers)
    revoke(:multiple_lines)
    self
  end

  # Splits each string in the data array into an array of numbers.
  #
  # This method processes +@data+ by splitting each string in the array using the specified delimiter,
  # then converting each resulting element to an integer. It modifies +@data+ directly and enables
  # chaining by returning +self+.
  #
  # @param delimiter [String, nil] the delimiter to be passed to +String#split+
  # @raise [RuntimeError] if {#multiple_lines} has not been called
  # @return [AocInput] self
  def columns_of_numbers(delimiter = nil)
    can_call?(:columns_of_numbers, "call .multiple_lines first")
    @data = data.map { |line| line.split(delimiter).map(&:to_i) }
    allow(:sort_arrays)
    allow(:transpose)
    revoke(:columns_of_numbers)
    self
  end

  # Transposes the data array.
  #
  # This method can only be called after {columns_of_numbers}.
  # It directly modifies +@data+ by transposing it and returns +self+ to allow method chaining.
  #
  # @raise [RuntimeError] if {columns_of_numbers} has not been called.
  # @return [AocInput] self
  def transpose
    can_call?(:transpose, "call .columns_of_numbers first")
    @data = data.transpose
    self
  end

  # Sorts each array within the +@data+ array.
  #
  # This method processes +@data+ by sorting each nested array in ascending order.
  # It directly modifies +@data+ and returns +self+ to enable method chaining.
  #
  # @raise [RuntimeError] if {#columns_of_numbers} has not been called
  # @return [AocInput] self
  def sort_arrays
    can_call?(:sort_arrays, "call .columns_of_numbers first")
    @data = data.map { |ary| ary.sort }
    self
  end

  # Returns a new +Grid+ object from the parsed input
  # @return [Grid] the new grid
  def to_grid
    Grid.from_input(@raw_input)
  end

  # Returns a new +AocInput+ for each section of the raw input, split by the given delimiter.
  # @param delimiter [String] the string used to split sections
  # @return [Array<AocInput>] an array of new AocInput instances initialised with each section of the raw input from +self+
  def sections(delimiter = "\n\n")
    @sections = @raw_input.split(delimiter).map { |section_input| AocInput.new(section_input) }
  end

  private
  def configure_method_access
    @can_call = {
      columns_of_numbers: false,
      multiple_lines: true,
      sort_arrays: false,
      transpose: false
    }
  end

  def allow(method_name)
    @can_call[method_name.to_sym] = true
  end

  def revoke(method_name)
    @can_call[method_name.to_sym] = false
  end

  def can_call?(method_name, msg = "operation not permitted")
    raise RuntimeError, msg unless @can_call[method_name.to_sym]
  end
end
