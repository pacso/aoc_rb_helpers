# frozen_string_literal: true

class Grid
  class Region
    def initialize(cells)
      if cells.is_a? Set
        @cells = cells
      else
        region_set = Set.new
        region_set.add(cells)
        @cells = region_set
      end
    end

    def ==(other)
      self.instance_variable_get(:@cells) == other.instance_variable_get(:@cells)
    end

    alias_method :eql?, :==

    def hash
      @cells.sort.to_a.unshift(self.class).hash
    end

    def each_cell
      @cells.each
    end

    def area
      @cells.count
    end

    def perimeter
      directions = [[-1, 0], [0, 1], [-1, 0], [0, -1]]
      p = 0
      @cells.each do |row, column|
        edges = 4
        directions.each do |dr, dc|
          neighbour = [row + dr, column + dc]
          edges -= 1 if @cells.include?(neighbour)
        end

        p += edges
      end
      p
    end

    def edge_count
      directions = [[-1, 0], [0, 1], [1, 0], [0, -1]]
      edges = Set.new

      @cells.each do |row, column|
        cell_edges = []
        neighbours = directions.map { |dr, dc| [row + dr, column + dc] }

        neighbours.each do |neighbour|
          edge = []
          edge << [row, column]
          edge << neighbour
          cell_edges << edge unless @cells.include?(neighbour)
        end

        cell_edges.each do |edge|
          first, second = edge_neighbours(edge)

          first_neighbour_edgeset = edges.find { |e| e.include?(first) }
          second_neighbour_edgeset = edges.find { |e| e.include?(second) }

          if first_neighbour_edgeset.nil? && second_neighbour_edgeset.nil?
            new_edgeset = Set.new
            new_edgeset << edge
            edges.add(new_edgeset)
          elsif !first_neighbour_edgeset.nil? && second_neighbour_edgeset.nil?
            first_neighbour_edgeset.add(edge)
          elsif first_neighbour_edgeset.nil? && !second_neighbour_edgeset.nil?
            second_neighbour_edgeset.add(edge)
          elsif !first_neighbour_edgeset.nil? && !second_neighbour_edgeset.nil?
            first_neighbour_edgeset.add(edge)
            first_neighbour_edgeset.merge(second_neighbour_edgeset)

            edges = edges.reject { |e| e == second_neighbour_edgeset }.to_set
          end
        end
      end

      edges.count
    end

    private

    def edge_neighbours(edge)
      inside, outside = edge

      results = if inside.last == outside.last
                  [
                    [
                      [inside.first, inside.last - 1],
                      [outside.first, outside.last - 1]
                    ],
                    [
                      [inside.first, inside.last + 1],
                      [outside.first, outside.last + 1]
                    ]
                  ]
                else
                  [
                    [
                      [inside.first - 1, inside.last],
                      [outside.first - 1, outside.last]
                    ],
                    [
                      [inside.first + 1, inside.last],
                      [outside.first + 1, outside.last]
                    ]
                  ]
                end

      results.select { |first, last| @cells.include?(first) && !@cells.include?(last) }
    end
  end
end
