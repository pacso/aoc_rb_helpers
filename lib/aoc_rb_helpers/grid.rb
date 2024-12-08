# frozen_string_literal: true

# Provides helper methods for manipulating end querying two-dimensional grids.
class Grid
  # Returns a new {Grid} initialized with the given input.
  #
  # @param input [String] the unprocessed input text containing the grid
  def self.from_input(input)
    self.new(input.lines(chomp: true).map(&:chars))
  end

  # Returns a new {Grid} initialized with the provided two-dimensional array.
  #
  # @param grid [Array<Array<Object>>] the grid in a two-dimensional array
  def initialize(grid)
    @grid = grid
  end

  # Returns +true+ if the provided coordinates exceed the bounds of the grid; +false+ otherwise.
  #
  # @param row [Integer] the row index to test
  # @param column [Integer] the column index to test
  # @return [Boolean]
  # @see #includes_coords?
  def beyond_grid?(row, column)
    !includes_coords?(row, column)
  end

  # Returns +true+ if the provided coordinates exist within the bounds of the grid; +false+ otherwise.
  #
  # @param row [Integer] the row index to test
  # @param column [Integer] the column index to test
  # @return [Boolean]
  # @see #beyond_grid?
  def includes_coords?(row, column)
    row >= 0 && column >= 0 && row < @grid.length && column < @grid.first.length
  end
  alias_method(:within_grid?, :includes_coords?)

  # Returns the value stored at coordinates +(row, column)+ within the grid.
  #
  # Returns +nil+ if the provided coordinates do not exist within the grid.
  #
  # Row and column numbers are zero-indexed.
  #
  # @param row [Integer] the row index of the desired cell
  # @param column [Integer] the column index of the desired cell
  # @return [Object] the value at the given coordinates within the grid
  # @return [nil] if the given coordinates do not exist within the grid
  # @see #set_cell
  def cell(row, column)
    return nil unless includes_coords?(row, column)
    @grid[row][column]
  end

  # Updates the cell at coordinates +(row, column)+ with the object provided in +value+; returns the given object.
  #
  # Returns +nil+ if the provided coordinates do not exist within the grid.
  #
  # @param row [Integer] the row index of the cell you wish to update
  # @param column [Integer] the column index of the cell you wish to update
  # @param value [Object] the object to assign to the selected grid cell
  # @return [Object] the given +value+
  # @return [nil] if the provided coordinates do not exist within the grid
  # @see #cell
  def set_cell(row, column, value)
    return nil unless includes_coords?(row, column)
    @grid[row][column] = value
  end

  # Returns +true+ if the other grid has the same content in the same orientation, +false+ otherwise.
  #
  #   grid = Grid.new([1, 2], [3, 4])
  #   grid == Grid.new([1, 2], [3, 4]) # => true
  #   grid == Grid.new([0, 1], [2, 3]) # => false
  #   grid == "non-grid object" # => false
  #
  # @param other [Grid] the grid you wish to compare with
  # @return [Boolean]
  def ==(other)
    return false unless other.is_a?(self.class)
    @grid == other.instance_variable_get(:@grid)
  end

  # Returns +true+ if the other grid can be rotated into an orientation where it is equal to +self+, +false+ otherwise.
  #
  #   grid = Grid.new([1, 2], [3, 4])
  #   grid == Grid.new([1, 2], [3, 4]) # => true
  #   grid == Grid.new([3, 1], [4, 2]) # => true
  #   grid == Grid.new([1, 2], [4, 3]) # => false
  #   grid == "non-grid object" # => false
  #
  # @param other [Grid] the grid you wish to compare with
  def matches_with_rotations?(other)
    other.all_rotations.any? { |rotated| self == rotated }
  end

  # Returns an array of {Grid} objects in all possible rotations, copied from +self+.
  # @return [Array<Grid>] an array containing four {Grid} objects, one in each possible rotation
  def all_rotations
    rotations = []
    current_grid = self.dup

    4.times do
      rotations << current_grid.dup
      current_grid.rotate!
    end

    rotations
  end

  # Returns a new {Grid} as a copy of self.
  # @return [Grid] a copy of +self+
  def dup
    self.class.new(@grid.map { |row| row.map { |cell| cell } })
  end

  # Updates +self+ with a rotated grid and returns +self+.
  #
  # Will rotate in a clockwise direction by default. Will rotate in an anticlockwise direction if passed
  # a param which is not +:clockwise+.
  #
  # @param direction [Symbol]
  # @return [self]
  def rotate!(direction = :clockwise)
    @grid = direction == :clockwise ? @grid.transpose.map(&:reverse) : @grid.map(&:reverse).transpose
    self
  end

  # Calls the given block with each subgrid from +self+ with the size constraints provided; returns +self+.
  #
  # Returns an enumerator if no block is given
  #
  # @return [Enumerator] if no block is given.
  # @return [self] after processing the provided block
  # @yield [subgrid] calls the provided block with each subgrid as a new {Grid} object
  # @yieldparam subgrid [Grid] a new {Grid} object containing a subgrid from the main grid
  def each_subgrid(rows, columns)
    return to_enum(__callee__, rows, columns) unless block_given?
    @grid.each_cons(rows) do |rows|
      rows[0].each_cons(columns).with_index do |_, col_index|
        yield Grid.new(rows.map { |row| row[col_index, columns] })
      end
    end

    self
  end

  # Returns an array containing all of the subgrids of the specified dimensions.
  # @param rows [Integer] the number of rows each subgrid should contain.
  #   Must be greater than zero and less than or equal to the number of rows in the grid.
  # @param columns [Integer] the number of columns each subgrid should contain.
  #   Must be greater than zero and less than or equal to the number of columns in the grid.
  # @raise [ArgumentError] if the specified rows or columns are not {Integer} values, or exceed the grid's dimensions.
  # @return [Array<Grid>]
  def subgrids(rows, columns)
    raise ArgumentError unless rows.is_a?(Integer) && rows > 0 && rows <= @grid.length
    raise ArgumentError unless columns.is_a?(Integer) && columns > 0 && columns <= @grid.first.length
    each_subgrid(rows, columns).to_a
  end
end
