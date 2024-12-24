# frozen_string_literal: true

class Map < Grid
  INFINITY = Float::INFINITY

  def initialize(*args)
    @neighbours_of_proc = nil
    super
  end

  def shortest_path(from, to, algorithm: :dijkstra)
    case algorithm
    when :dijkstra
      shortest_path_dijkstra(from, to)
    end
  end

  def shortest_paths(from, to, algorithm: :dijkstra)
    case algorithm
    when :dijkstra
      shortest_paths_dijkstra(from, to)
    end
  end

  def set_neighbours_of_proc(proc, cardinal: true, ordinal: false)
    @cardinal = cardinal
    @ordinal = ordinal
    @neighbours_of_proc = proc
  end

  private
  def shortest_path_dijkstra(from, to)
    unvisited = Hash.new(INFINITY)
    visited = Hash.new(false)
    distances = Hash.new(INFINITY)
    path = Hash.new { |h, k| h[k] = [] }

    unvisited[from] = 0
    distances[from] = 0
    path[from] = [from]

    until to.first.is_a?(Array) ? to.any? { |dest| visited[dest] } : visited[to]
      raise RuntimeError, "route blocked" if unvisited.empty?
      current = unvisited.key(unvisited.values.min)
      unvisited_neighbours = neighbours_of(current).reject { |n, _c| visited[n] }

      unvisited_neighbours.each do |neighbour, cost|
        new_cost = distances[current] + cost

        if new_cost < distances[neighbour]
          distances[neighbour] = new_cost
          unvisited[neighbour] = new_cost
          path[neighbour] = path[current] + [neighbour]
        end
      end

      visited[current] = true
      distances[current] = unvisited[current]
      unvisited.delete(current)
    end

    if to.first.is_a?(Array)
      path[to.select { |dest| visited[dest] }.first]
    else
      path[to]
    end
  end

  def shortest_paths_dijkstra(from, to)
    unvisited = Hash.new(INFINITY)
    visited = Hash.new(false)
    distances = Hash.new(INFINITY)
    paths = Hash.new { |h, k| h[k] = [] }
    unvisited[from] = 0
    distances[from] = 0
    paths[from] = [[from]]

    until to.first.is_a?(Array) ? to.any? { |dest| visited[dest] } : visited[to]
      raise RuntimeError, "route blocked" if unvisited.empty?
      current = unvisited.key(unvisited.values.min)
      unvisited_neighbours = neighbours_of(current).reject { |n, _c| visited[n] }

      unvisited_neighbours.each do |neighbour, cost|
        new_cost = distances[current] + cost

        if new_cost < distances[neighbour]
          distances[neighbour] = new_cost
          unvisited[neighbour] = new_cost
          paths[neighbour] = paths[current].map { |path| path + [neighbour] }
        elsif new_cost == distances[neighbour]
          paths[neighbour] += paths[current].map { |path| path + [neighbour] }
        end
      end

      visited[current] = true
      distances[current] = unvisited[current]
      unvisited.delete(current)
    end

    to.first.is_a?(Array) ? to.flat_map { |dest| paths[dest] } : paths[to]
  end

  def neighbours_of(current)
    if @neighbours_of_proc
      @neighbours_of_proc.call(self, current)
    else
      self.neighbours(*current) { |cell| cell != "#" }.map { |neighbour| [neighbour, 1] }
    end
  end
end
