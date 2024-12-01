# frozen_string_literal: true

class AocInput
  def initialize(input)
    @raw_input = input
  end

  def data
    @data ||= @raw_input
  end

  def multiple_lines
    @data = data.lines(chomp: true)
    self
  end

  def columns_of_numbers(divider = nil)
    @data = data.map { |line| line.split(divider).map(&:to_i) }
    self
  end

  def transpose
    @data = data.transpose
    self
  end

  def sort_arrays
    @data = data.map { |ary| ary.sort }
    self
  end
end
