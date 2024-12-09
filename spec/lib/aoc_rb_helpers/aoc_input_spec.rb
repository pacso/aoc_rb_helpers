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
  let(:grid_input) do
    <<~EOF
      abcde
      fghij
      klmno
      pqrst
      uvwxy
    EOF
  end

  describe "#single_line" do
    let(:single_newline_input) do
      <<~EOF
        the-only-line
      EOF
    end
    let(:multi_newline_input) do
      <<~EOF
        the-only-line


      EOF
    end

    it "strips a single newline character" do
      aoc_input = described_class.new(single_line_input)
      expect { aoc_input.single_line }.to change { aoc_input.data }
                                            .from("the-only-line\n")
                                            .to("the-only-line")
    end

    it "strips multiple newline characters" do
      aoc_input = described_class.new(multi_newline_input)
      expect { aoc_input.single_line }.to change { aoc_input.data }
                                            .from("the-only-line\n\n\n")
                                            .to("the-only-line")
    end

    it "returns the aoc_input instance" do
      aoc_input = described_class.new(multi_newline_input)
      expect(aoc_input.single_line).to be aoc_input
    end
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

  describe "#to_grid" do
    it "returns an instance of Grid" do
      expect(described_class.new(grid_input).to_grid).to be_a Grid
    end
  end

  describe "#sections" do
    let(:input_with_2_sections) do
      <<~EOF
        23|45
        34|38
        83|21

        4,3,1,8
      EOF
    end

    it "returns two AocInput instances when provided an input with 2 sections" do
      sections = described_class.new(input_with_2_sections).sections
      expect(sections).to be_an Array
      expect(sections.length).to eq 2
      sections.each do |section|
        expect(section).to be_an AocInput
      end
    end
  end

  describe "#process_each_line" do
    let(:multi_type_row_input) do
      <<~EOF
        abc: 123
        def: 456
        ghi: 789
      EOF
    end
    subject(:processed_input) {
      described_class
        .new(multi_type_row_input)
        .multiple_lines
        .process_each_line do |line|
        key, value = line.split(": ")
        [key, value.to_i]
      end
    }

    it "returns an instance of AocInput" do
      expect(processed_input).to be_an AocInput
    end

    it "modifies @data correctly" do
      expect(processed_input.data).to eq [["abc", 123], ["def", 456], ["ghi", 789]]
    end

    it "returns an enumerator if no block is given" do
      enumerator = described_class.new(multi_type_row_input).multiple_lines.process_each_line
      expect(enumerator).to be_an Enumerator
      expect(enumerator.next).to eq "abc: 123"
    end
  end

  it "is important which order you call the methods in" do
    expect(described_class.new(multiline_numbers).multiple_lines.columns_of_numbers.transpose.sort_arrays.data).to eq [[123, 345, 789], [12, 456, 678]]
    expect(described_class.new(multiline_numbers).multiple_lines.columns_of_numbers.sort_arrays.transpose.data).to eq [[123, 12, 345], [456, 789, 678]]
  end
end
