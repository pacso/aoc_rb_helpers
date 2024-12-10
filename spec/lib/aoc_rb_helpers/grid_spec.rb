# frozen_string_literal: true

require 'spec_helper'
require 'pd'

RSpec.describe Grid do
  let(:input_text) { "abcd\nefgh\nijkl\nmnop" }
  let(:rotated_input_text) { "miea\nnjfb\nokgc\nplhd" }
  let(:subgrid_1) { Grid.from_input("abc\nefg\nijk") }
  let(:subgrid_2) { Grid.from_input("bcd\nfgh\njkl") }
  let(:subgrid_3) { Grid.from_input("efg\nijk\nmno") }
  let(:subgrid_4) { Grid.from_input("fgh\njkl\nnop") }
  let(:row_set_1) { Grid.from_input("abcd\nefgh") }
  let(:row_set_2) { Grid.from_input("efgh\nijkl") }
  let(:row_set_3) { Grid.from_input("ijkl\nmnop") }

  describe ".from_input" do
    it "converts input text into a grid" do
      expect(described_class.from_input(input_text)).to be_an_instance_of Grid
    end
  end

  describe "#cell(y, x)" do
    let(:grid) { described_class.from_input(input_text) }

    it "returns the cell at the given coordinates" do
      expect(grid.cell(0, 0)).to eq "a"
    end

    it "returns nil if the coords are out of bounds" do
      expect(grid.cell(-1, -1)).to be_nil
    end
  end

  describe "#set_cell(y, x, value)" do
    let(:grid) { described_class.from_input(input_text) }

    it "sets the cell at the given coordinates" do
      expect { grid.set_cell(0, 0, "z") }
        .to change { grid.cell(0, 0) }.from("a").to("z")
    end

    it "returns nil if the coordinates are out of bounds" do
      expect(grid.set_cell(-1, 0, "z")).to be_nil
    end

    it "does not modify the grid if the coordinates are out of bounds" do
      expect { grid.set_cell(-1, 0, "z") }.not_to change { grid.instance_variable_get("@grid") }
    end
  end

  describe "==" do
    it "return true if the grids are identical" do
      grid_1 = described_class.from_input(input_text)
      grid_2 = described_class.from_input(input_text)

      expect(grid_1).to eq grid_2
    end

    it "returns false if the grids are not identical" do
      grid_1 = described_class.from_input(input_text)
      grid_2 = described_class.from_input(input_text)
      grid_2.set_cell(0, 0, "z")

      expect(grid_1).to_not eq grid_2
    end
  end

  describe "#matches_with_rotations?(other)" do
    it "returns true if the grids are the same" do
      grid_1 = described_class.from_input(input_text)
      grid_2 = described_class.from_input(input_text)

      expect(grid_1.matches_with_rotations?(grid_2)).to be true
    end

    it "returns true if one grid is rotated" do
      grid_1 = described_class.from_input(input_text)
      grid_2 = described_class.from_input(rotated_input_text)

      expect(grid_1.matches_with_rotations?(grid_2)).to be true
    end

    it "works for all rotations" do
      grid = described_class.from_input(input_text)
      expect(grid.all_rotations.all? { |rotation| grid.matches_with_rotations?(rotation) }).to be true
    end

    it "returns false for all rotations if the grids differ" do
      grid = described_class.from_input(input_text)
      different_grid = described_class.from_input(input_text)
      different_grid.set_cell(2, 3, ".")
      expect(different_grid.all_rotations.any? { |rotation| grid.matches_with_rotations?(rotation) }).to be false
    end
  end

  describe "#subgrids(width, height)" do
    it "returns an array of Grid objects" do
      grid = described_class.from_input(input_text)
      expect(grid.subgrids(3, 3)).to be_an Array
      grid.subgrids(3, 3).each do |subgrid|
        expect(subgrid).to be_an_instance_of Grid
      end
    end

    it "returns the expected grids" do
      grid = described_class.from_input(input_text)
      expect(grid.subgrids(3, 3))
        .to match_array([subgrid_1, subgrid_2, subgrid_3, subgrid_4])
    end

    it "accepts arbitrary grid sizes" do
      grid = described_class.from_input(input_text)
      expect(grid.subgrids(2, 4))
        .to match_array([row_set_1, row_set_2, row_set_3])
    end

    it "raises ArgumentError if provided non-Integer values" do
      grid = described_class.from_input(input_text)
      expect { grid.subgrids("3", 3) }.to raise_error(ArgumentError)
      expect { grid.subgrids(3, "3") }.to raise_error(ArgumentError)
    end

    it "raises ArgumentError if zero rows or columns are requested" do
      grid = described_class.from_input(input_text)
      expect { grid.subgrids(0, 3) }.to raise_error(ArgumentError)
      expect { grid.subgrids(3, 0) }.to raise_error(ArgumentError)
    end

    it "raises ArgumentError if the requested rows or columns exceed the grid size" do
      grid = described_class.from_input(input_text)
      expect { grid.subgrids(5, 3) }.to raise_error(ArgumentError)
      expect { grid.subgrids(3, 5) }.to raise_error(ArgumentError)
    end

    it "returns a single subgrid matching self if the requested size equals the source grid" do
      grid = described_class.from_input(input_text)
      results = grid.subgrids(4, 4)
      expect(results).to be_an Array
      expect(results.first).to be_an_instance_of Grid
      expect(results.first).to eq grid
    end

    it "returns a new Grid rather than self if the requested size equals the source grid" do
      grid = described_class.from_input(input_text)
      subgrid = grid.subgrids(4, 4).first
      expect(subgrid).to eq grid
      expect(subgrid).not_to be grid
    end
  end

  describe "#each_subgrid(rows, columns, &block)" do
    it "yields each expected subgrid when passed a block" do
      expected_subgrids = [subgrid_1, subgrid_2, subgrid_3, subgrid_4]
      grid = described_class.from_input(input_text)
      grid.each_subgrid(3, 3) do |subgrid|
        expected_subgrid = expected_subgrids.shift
        expect(subgrid).to eq expected_subgrid
      end
    end

    it "returns an enumerator when no block is provided" do
      expected_subgrids = [subgrid_1, subgrid_2, subgrid_3, subgrid_4]
      grid = described_class.from_input(input_text)

      enumerator = grid.each_subgrid(3, 3)

      expect(enumerator).to be_an Enumerator
      expect(enumerator.to_a).to eq expected_subgrids
    end
  end

  describe "#rotate!" do
    it "rotates the grid clockwise by default" do
      grid = described_class.new([[0, 1], [2, 3]])
      grid.rotate!
      expect(grid).to eq Grid.new([[2, 0], [3, 1]])
    end

    it "can optionally rotate anticlockwise" do
      grid = described_class.new([[2, 0], [3, 1]])
      grid.rotate!(:anticlockwise)
      expect(grid).to eq Grid.new([[0, 1], [2, 3]])
    end
  end

  describe "#includes_coords?(row, column)" do
    let(:grid) { described_class.new([[0, 1], [2, 3]]) }

    it "returns true if the given row and column are in the grid" do
      [[0, 0], [0, 1], [1, 0], [1, 1]].each do |coords|
        expect(grid.includes_coords?(*coords)).to be true
      end
    end

    it "returns false if the given row and column are not in the grid" do
      [[-1, 0], [0, -1], [0, 2], [2, 0]].each do |coords|
        expect(grid.includes_coords?(*coords)).to be false
      end
    end
  end

  describe "#beyond_grid?(row, column)" do
    let(:grid) { described_class.new([[0, 1], [2, 3]]) }

    it "returns false if the given row and column are in the grid" do
      [[0, 0], [0, 1], [1, 0], [1, 1]].each do |coords|
        expect(grid.beyond_grid?(*coords)).to be false
      end
    end

    it "returns true if the given row and column are not in the grid" do
      [[-1, 0], [0, -1], [0, 2], [2, 0]].each do |coords|
        expect(grid.beyond_grid?(*coords)).to be true
      end
    end
  end

  describe "#dup" do
    let(:grid) { described_class.new([[0, 1], [2, 3]]) }

    it "returns a new Grid instance" do
      expect(grid.dup).to be_an_instance_of Grid
    end

    it "returns a new Grid with a matching @grid" do
      expect(grid.dup.instance_variable_get(:@grid)).to eq grid.instance_variable_get(:@grid)
    end

    it "does not create a Grid with the same instance of @grid" do
      expect(grid.dup.instance_variable_get(:@grid)).not_to be grid.instance_variable_get(:@grid)
    end

    it "isolates changes in the new grid from the original" do
      other = grid.dup
      expect { other.set_cell(0, 0, "9") }.not_to change { grid.cell(0, 0) }.from(0)
      expect(other.cell(0, 0)).to eq "9"
    end
  end

  describe "#locate" do
    let(:grid) { described_class.new([%w[a b], %w[c d]]) }

    it "returns the coordinates of the given value" do
      expect(grid.locate("a")).to eq [0, 0]
      expect(grid.locate("b")).to eq [0, 1]
      expect(grid.locate("c")).to eq [1, 0]
      expect(grid.locate("d")).to eq [1, 1]
    end

    it "returns nil if the given value is not in the grid" do
      expect(grid.locate("missing")).to be_nil
    end

    context "with a grid contining duplicate values" do
      let(:grid) { described_class.new([%w[a b], %w[b a]]) }

      it "returns the first coordinate of the given value, searching from the top-left by row" do
        expect(grid.locate("a")).to eq [0, 0]
        expect(grid.locate("b")).to eq [0, 1]
      end
    end
  end

  describe "#locate_all" do
    let(:grid) { described_class.new([%w[a b c a], %w[c d e b], %w[f a g h]]) }

    it "returns all coordinates of the given value" do
      expect(grid.locate_all("a")).to eq [[0, 0], [0, 3], [2, 1]]
    end

    it "returns an empty array if the given value is not in the grid" do
      expect(grid.locate_all("missing")).to eq []
    end
  end

  describe "#each_cell" do
    let(:grid) { described_class.new([%w[a b], %w[c d]]) }

    it "returns an enumerator when no block is given" do
      e = grid.each_cell
      expect(e).to be_an Enumerator
      expect(e.next).to eq [[0, 0], "a"]
    end

    it "allows the grid to be modified during iteration" do
      grid.each_cell { |coords, value| grid.set_cell(*coords, value * 2) }
      expect(grid.cell(0, 0)).to eq "aa"
    end

    it "returns self when given a block" do
      expect(grid.each_cell { |_, value| value * 2 }).to eq grid
    end

    it "yields the coordinates and values of each cell in the grid" do
      expected_values = [
        [[0, 0], "a"],
        [[0, 1], "b"],
        [[1, 0], "c"],
        [[1, 1], "d"],
      ]
      returned_values = []
      grid.each_cell do |coords, value|
        returned_values << [coords, value]
      end
      expect(returned_values).to eq expected_values
    end
  end

  describe "#neighbours" do
    let(:grid) { described_class.new([
                                       [7, 4, 2, 4, 7],
                                       [4, 2, 1, 2, 4],
                                       [2, 1, 0, 1, 2],
                                       [4, 2, 1, 2, 4],
                                       [7, 4, 2, 4, 7]
                                     ]) }

    it "returns the surrounding neighbour coords when no block is given" do
      expect(grid.neighbours(*[2, 2])).to eq [[1, 2], [2, 3], [3, 2], [2, 1]]
    end

    it "returns diagonal neighbour coords when requested" do
      expect(grid.neighbours(*[2, 2], ordinal: true)).to eq [[1, 2], [1, 3], [2, 3], [3, 3], [3, 2], [3, 1], [2, 1], [1, 1]]
    end

    it "returns only diagonal neighbours when requested" do
      expect(grid.neighbours(*[2, 2], cardinal: false, ordinal: true)).to eq [[1, 3], [3, 3], [3, 1], [1, 1]]
    end

    it "excludes coordinates outside the grid" do
      expect(grid.neighbours(*[0,0])).to eq [[0, 1], [1, 0]]
      expect(grid.neighbours(*[1,0])).to eq [[0, 0], [1, 1], [2, 0]]
      expect(grid.neighbours(*[0,1])).to eq [[0, 2], [1, 1], [0, 0]]
    end

    it "accepts a block to filter neighbours based on each cell value" do
      expect(grid.neighbours(*[1, 1]) { true }).to eq [[0, 1], [1, 2], [2, 1], [1, 0]]
      expect(grid.neighbours(*[1, 1]) { |cell| cell.even? }).to eq [[0, 1], [1, 0]]
      expect(grid.neighbours(*[1, 1]) { |cell| cell.odd? }).to eq [[1, 2], [2, 1]]
      expect(grid.neighbours(*[1, 1]) { false }).to eq []
    end

    it "filters diagonal neighbours also" do
      expect(grid.neighbours(*[1, 1], ordinal: true) { |cell| cell.even? }).to eq [[0, 1], [0, 2], [2, 2], [2, 0], [1, 0]]
    end
  end
end
