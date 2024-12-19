# frozen_string_literal: true

# Provides helper methods for manipulating end querying two-dimensional grids.
class Grid
  # Returns a new {Grid} initialized with the given input.
  #
  # @param input [String] the unprocessed input text containing the grid
  def self.from_input(input)
    self.new(input.lines(chomp: true).map(&:chars))
  end

  # Returns a new {Grid} initialised with the given dimensions.
  #
  # By default, grid cells are initialised to +nil+, but this can be overridden by providing a +cell_default+.
  #
  # @param rows [Integer] the height of the grid
  # @param columns [Integer] the width of the grid
  # @param cell_default [Object] the default value for each cell in the grid
  def self.with_dimensions(rows, columns, cell_default = nil)
    self.new(Array.new(rows) { Array.new(columns, cell_default) })
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
  alias_method :eql?, :==

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
    grid = self.dup

    4.times do
      rotations << grid.dup
      grid.rotate!
    end

    rotations
  end

  # Returns a new {Grid} as a copy of self.
  # @return [Grid] a copy of +self+
  def dup
    self.class.new Marshal.load(Marshal.dump(@grid))
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
  # @return [Grid] if given a block, returns +self+ after calling block for each subgrid
  # @return [Enumerator] if no block is given.
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

  # Returns the first coordinates within the grid containing the given value. Returns +nil+ if not found.
  #
  # If given an array of values, the first coordinate matching any of the given values will be returned.
  #
  # Searches the grid from top left (+[0, 0]+) to bottom right, by scanning each row.
  #
  # @param value [Object, Array<Object>] the value, or array of values, to search for.
  # @return [Array<Integer>] if the value was located, its coordinates are returned in a 2-item array where:
  #   - The first item is the row index.
  #   - The second item is the column index.
  # @return [nil] if the value was not located
  def locate(value)
    result = nil
    if value.is_a? Array
      value.each do |e|
        result = locate(e)
        break unless result.nil?
      end
    else
      result = locate_value value
    end
    result
  end

  # Returns an array of coordinates for any location within the grid containing the given value.
  #
  # If given an array of values, the coordinates of any cell matching any of the given values will be returned.
  #
  # @param value [Object, Array<Object>] the value, or array of values, to search for.
  # @return [Array<Array<Integer>>] an array of coordinates. Each coordinate is a 2-item array where:
  #   - The first item is the row index.
  #   - The second item is the column index.
  def locate_all(value)
    locations = []

    if value.is_a? Array
      @grid.each_with_index.select { |row, _r_index| value.any? { |el| row.include?(el) } }.each do |row, r_index|
        row.each_with_index do |cell, c_index|
          locations << [r_index, c_index] if value.include?(cell)
        end
      end
    else
      @grid.each_with_index.select { |row, _r_index| row.include?(value) }.each do |row, r_index|
        row.each_with_index do |cell, c_index|
          locations << [r_index, c_index] if cell == value
        end
      end
    end

    locations
  end

  # Iterates over each cell in the grid.
  #
  # When a block is given, passes the coordinates and value of each cell to the block; returns +self+:
  #     g = Grid.new([
  #           ["a", "b"],
  #           ["c", "d"]
  #         ])
  #     g.each_cell { |coords, value| puts "#{coords.inspect} => #{value}" }
  #
  # Output:
  #     [0, 0] => a
  #     [0, 1] => b
  #     [1, 0] => c
  #     [1, 1] => d
  #
  # When no block is given, returns a new Enumerator:
  #     g = Grid.new([
  #           [:a, "b"],
  #           [3, true]
  #         ])
  #     e = g.each_cell
  #     e # => #<Enumerator: #<Grid: @grid=[[\"a\", \"b\"], [\"c\", \"d\"]]>:each_cell>
  #     g1 = e.each { |coords, value| puts "#{coords.inspect} => #{value.class}: #{value}" }
  #
  # Output:
  #     [0, 0] => Symbol: a
  #     [0, 1] => String: b
  #     [1, 0] => Integer: 3
  #     [1, 1] => TrueClass: true
  # @yieldparam coords [Array<Integer>] the coordinates of the cell in a 2-item array where:
  #   #   - The first item is the row index.
  #   #   - The second item is the column index.
  # @yieldparam value [Object] the value stored within the cell
  # @return [Grid] if given a block, returns +self+ after calling block for each cell
  # @return [Enumerator] if no block is given
  def each_cell
    return to_enum(__callee__) unless block_given?
    @grid.each_with_index do |row, r_index|
      row.each_with_index do |cell, c_index|
        yield [[r_index, c_index], cell]
      end
    end
    self
  end

  # Calls the block, if given, with each cell value; replaces the cell in the grid with the block's return value:
  #
  # Returns a new Enumerator if no block given
  # @yieldparam value [Object] the value stored within the cell
  # @yieldreturn new_value [Object] the updated value to replace cell with
  # @return [Grid] if given a block, returns +self+ after calling block for each cell
  # @return [Enumerator] if no block is given
  def each_cell!
    return to_enum(__callee__) unless block_given?
    @grid.each_with_index do |row, r_index|
      row.each_with_index do |cell, c_index|
        @grid[r_index][c_index] = yield cell
      end
    end
    self
  end
  alias_method :format_cells, :each_cell!

  # Iterates over each row in the grid, without modifying the grid.
  #
  # When a block is given, passes each row to the block; returns +self+:
  #     g = Grid.new([
  #           ["a", "b", "c"],
  #           ["d", "e", "f"]
  #         ])
  #     g.each_row { |row| puts row.join }
  #
  # Output:
  #     abc
  #     def
  #
  # When no block is given, returns a new Enumerator.
  #
  # @yieldparam row [Array<Object>] an array containing the cells of the row
  # @return [Grid] if given a block, returns +self+ after calling block for each row
  # @return [Enumerator] if no block is given
  def each_row
    return to_enum(__callee__) unless block_given?
    @grid.each do |row|
      yield Marshal.load(Marshal.dump(row))
    end
    self
  end

  # Calls the block, if given, with each row in the grid; replaces the row in the grid with the block's return value.
  #
  # Returns a new Enumerator if no block given.
  #
  # @yieldparam row [Array<Object>] an array containing the cells of the row
  # @return [Grid] if given a block, returns +self+ after calling block for each row
  # @return [Enumerator] if no block is given
  def each_row!
    return to_enum(__callee__) unless block_given?
    @grid.each_with_index do |row, index|
      @grid[index] = yield row
    end
    self
  end
  alias_method :format_rows, :each_row!

  # For the given position indicated by the +row+ and +column+ provided, returns
  # an array of coordinates which are direct neighbours. The returned coordinates are in
  # clockwise order starting directly above the given cell:
  #     g = Grid.new([
  #           [0, 1, 2, 3],
  #           [4, 5, 6, 7],
  #           [8, 9, 10, 11]
  #         ])
  #     g.neighbours(1, 1) # => [[0, 1], [1, 2], [2, 1], [1, 0]]
  #
  # If the keyword argument +allow_diagonal: true+ is provided, diagonally accessible neighbours will also be included:
  #     g = Grid.new([
  #           [0, 1, 2, 3],
  #           [4, 5, 6, 7],
  #           [8, 9, 10, 11]
  #         ])
  #     g.neighbours(1, 1) # => [[0, 1], [0, 2], [1, 2], [2, 2], [2, 1], [2, 0], [1, 0], [0, 0]]
  #
  # If provided a block, each neighbour's cell value is yielded to the block, and only those neighbours for which the block
  # returns a truthy value will be returned in the results:
  #     g = Grid.new([
  #           [0, 1, 2, 3],
  #           [4, 5, 6, 7],
  #           [8, 9, 10, 11]
  #         ])
  #     g.neighbours(1, 2) { |cell| cell.even? } # => [[0, 2], [2, 2]]
  #     g.neighbours(1, 2, allow_diagonal: true) { |cell| cell <= 5 } # => [[0, 2], [0, 3], [1, 1], [0, 1]]
  #
  # @param row [Integer] the row index of the starting cell
  # @param column [Integer] the column index of the starting cell
  # @param cardinal [Boolean] permits the direct north/east/south/west directions
  # @param ordinal [Boolean] permits diagonal north-east/south-east/south-west/north-west directions
  # @return [Array<Array<Integer>>] an array of coordinates. Each coordinate is a 2-item array where:
  #   - The first item is the row index.
  #   - The second item is the column index.
  def neighbours(row, column, cardinal: true, ordinal: false)
    possible_neighbours = []
    possible_neighbours << [row - 1, column] if cardinal
    possible_neighbours << [row - 1, column + 1] if ordinal
    possible_neighbours << [row, column + 1] if cardinal
    possible_neighbours << [row + 1, column + 1] if ordinal
    possible_neighbours << [row + 1, column] if cardinal
    possible_neighbours << [row + 1, column - 1] if ordinal
    possible_neighbours << [row, column - 1] if cardinal
    possible_neighbours << [row - 1, column - 1] if ordinal

    valid_neighbours = possible_neighbours.select { |r, c| includes_coords?(r, c) }

    if block_given?
      valid_neighbours.select { |r, c| yield cell(r, c) }
    else
      valid_neighbours
    end
  end

  def regions
    regions = Set.new
    cells = all_cells
    until cells.empty?
      cell = cells.first
      cells.delete(cell)
      region = Region.new(contiguous_cells(*cell))
      region.each_cell do |coords|
        cells.delete(coords)
      end
      regions << region
    end
    regions
  end

  def all_cells
    Set.new(each_cell.map { |(y, x), _value| [y, x] })
  end

  def contiguous_cells(row, column, cells = Set.new)
    value = cell(row, column)
    cells.add([row, column])
    neighbours = neighbours(row, column) { |nv| value == nv }
    neighbours.each do |neighbour|
      contiguous_cells(*neighbour, cells) unless cells.include?(neighbour)
    end
    cells
  end

  def hash
    all_cells.sort.to_a.unshift(self.class).hash
  end

  # Outputs the grid to STDOUT
  def print
    @grid.each do |row|
      puts row.join
    end
    puts ""
  end

  private

  def locate_value(element)
    row = @grid.index { |row| row.include?(element) }
    return nil if row.nil?
    column = @grid[row].index(element)
    [row, column]
  end
end
