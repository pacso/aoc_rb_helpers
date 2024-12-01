# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AocInput do
  let(:multiline_input) do
    <<~EOF
      Lots of input
      split
      over
      many lines
    EOF
  end
  let(:multiline_numbers) do
    <<~EOF
      123 456
      789 012
      345 678
    EOF
  end

  describe '#multiple_lines' do
    subject(:method_chain) { described_class.new(multiline_input).multiple_lines }

    it "splits the input into an array of lines" do
      expect(method_chain.data).to eq ["Lots of input", "split", "over", "many lines"]
    end

    it "returns an instance of AocInput" do
      expect(method_chain).to be_an AocInput
    end
  end

  describe "#columns_of_numbers" do
    subject(:method_chain) { described_class.new(multiline_numbers).multiple_lines.columns_of_numbers }

    it "raises StandardError if you call columns of numbers before multiple lines" do
      expect { described_class.new(multiline_input).columns_of_numbers }.to raise_error RuntimeError, "call .multiple_lines first"
    end

    it "splits the lines into arrays of numbers" do
      expect(method_chain.data).to eq [[123, 456], [789, 12], [345, 678]]
    end

    it "returns an instance of AocInput" do
      expect(method_chain).to be_an AocInput
    end
  end

  describe "#transpose" do
    subject(:method_chain) { described_class.new(multiline_numbers).multiple_lines.columns_of_numbers.transpose }

    it "raises StandardError if you call transpose without columns_of_numbers" do
      expect { described_class.new(multiline_input).transpose }.to raise_error RuntimeError, "call .columns_of_numbers first"
      expect { described_class.new(multiline_input).multiple_lines.transpose }.to raise_error RuntimeError, "call .columns_of_numbers first"
    end

    it "transposes columns of numbers" do
      expect(method_chain.data).to eq [[123, 789, 345], [456, 12, 678]]
    end
  end

  describe "#sort_arrays" do
    it "raises an error if you call sort_arrays without columns_of_numbers" do
      expect { described_class.new(multiline_numbers).multiple_lines.sort_arrays.data }.to raise_error RuntimeError, "call .columns_of_numbers first"
    end

    it "sorts the top level of arrays within data" do
      expect(described_class.new(multiline_numbers).multiple_lines.columns_of_numbers.sort_arrays.data).to eq [[123, 456], [12, 789], [345, 678]]
      expect(described_class.new(multiline_numbers).multiple_lines.columns_of_numbers.transpose.sort_arrays.data).to eq [[123, 345, 789], [12, 456, 678]]
    end
  end

  it "is important which order you call the methods in" do
    expect(described_class.new(multiline_numbers).multiple_lines.columns_of_numbers.transpose.sort_arrays.data).to eq [[123, 345, 789], [12, 456, 678]]
    expect(described_class.new(multiline_numbers).multiple_lines.columns_of_numbers.sort_arrays.transpose.data).to eq [[123, 12, 345], [456, 789, 678]]
  end
end
