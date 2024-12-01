# frozen_string_literal: true

class AocInput
  def initialize(input)
    @raw_input = input
    configure_method_access
  end

  def data
    @data ||= @raw_input
  end

  def multiple_lines
    @data = data.lines(chomp: true)
    allow(:columns_of_numbers)
    self
  end

  def columns_of_numbers(divider = nil)
    can_call?(:columns_of_numbers, "call .multiple_lines first")
    @data = data.map { |line| line.split(divider).map(&:to_i) }
    allow(:sort_arrays)
    allow(:transpose)
    self
  end

  def transpose
    can_call?(:transpose, "call .columns_of_numbers first")
    @data = data.transpose
    self
  end

  def sort_arrays
    can_call?(:sort_arrays, "call .columns_of_numbers first")
    @data = data.map { |ary| ary.sort }
    self
  end

  private
  def configure_method_access
    @can_call = {
      columns_of_numbers: false,
      sort_arrays: false,
      transpose: false
    }
  end

  def allow(method_name)
    @can_call[method_name.to_sym] = true
  end

  def can_call?(method_name, msg = "operation not permitted")
    raise RuntimeError, msg unless @can_call[method_name.to_sym]
  end
end
