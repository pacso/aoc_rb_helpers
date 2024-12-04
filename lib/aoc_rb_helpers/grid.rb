# frozen_string_literal: true

# Provides helper methods for manipulating end querying two-dimensional grids.
class Grid
  # Returns a new Grid initialized with the given input.
  #
  # @param input [String] the unprocessed input text containing the grid
  def self.from_input(input)
    self.new(input.lines(chomp: true).map(&:chars))
  end

  # Returns a new Grid initialized with the provided two-dimensional array.
  #
  # @param grid [Array<Array<any>>] the grid in a two-dimensional array
  def initialize(grid)
    @grid = grid
  end

  # Returns the value stored at coordinates (row, column) within the grid.
  #
  # Row and column numbers are zero-indexed.
  #
  # @param row [Integer] the row index of the desired cell
  # @param column [Integer] the column index of the desired cell
  def cell(row, column)
    @grid[row][column]
  end

  # Updates the cell at coordinates (row, column) with the provided value.
  #
  # @param row [Integer] the row index of the cell you wish to set
  # @param column [Integer] the column index of the cell you wish to set
  # @param value [Any] whatever value you want to set within the selected grid cell
  def set_cell(row, column, value)
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

  # Returns an array of +Grid+ objects in all possible rotations, copied from +self+.
  # @return [Array<Grid>] an array containing four +Grid+ objects, one in each possible rotation
  def all_rotations
    rotations = []
    current_grid = self.dup

    4.times do
      rotations << current_grid.dup
      current_grid.rotate!
    end

    rotations
  end

  # Returns a new +Grid+ as a copy of self.
  # @return [Grid] a copy of +self+
  def dup
    Grid.new(@grid)
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
  # @yield [subgrid] invokes the block
  # @yieldparam subgrid [Grid] a new +Grid+ object containing a subgrid from the main grid
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
  # @return [Array<Grid>]
  def subgrids(rows, columns)
    each_subgrid(rows, columns).to_a
  end
end
