# frozen_string_literal: true

require "spec_helper"

RSpec.describe DotMatrix do
  let(:hello_input) do
    <<~EOF
      X  X XXXX X    X     XX  
      X  X X    X    X    X  X 
      XXXX XXX  X    X    X  X 
      X  X X    X    X    X  X 
      X  X X    X    X    X  X 
      X  X XXXX XXXX XXXX  XX  
    EOF
  end
  let(:hello_input_alternate) do
    <<~EOF
      #..#.####.#....#.....##..
      #..#.#....#....#....#..#.
      ####.###..#....#....#..#.
      #..#.#....#....#....#..#.
      #..#.#....#....#....#..#.
      #..#.####.####.####..##..
    EOF
  end
  let(:alphabet_input) do
    <<~EOF
       XX  XXX   XX  XXXX XXXX  XX  X  X   XX X  X X     XX  XXX  XXX   XXX X  X X   XXXXX 
      X  X X  X X  X X    X    X  X X  X    X X X  X    X  X X  X X  X X    X  X X   X   X 
      X  X XXX  X    XXX  XXX  X    XXXX    X XX   X    X  X X  X X  X X    X  X  X X   X  
      XXXX X  X X    X    X    X XX X  X    X X X  X    X  X XXX  XXX   XX  X  X   X   X   
      X  X X  X X  X X    X    X  X X  X X  X X X  X    X  X X    X X     X X  X   X  X    
      X  X XXX   XX  XXXX X     XXX X  X  XX  X  X XXXX  XX  X    X  X XXX   XX    X  XXXX 
    EOF
  end
  let(:hello_array) { hello_input.lines(chomp: true).map(&:chars) }
  let(:hello_alt_array) { hello_input_alternate.lines(chomp: true).map(&:chars) }
  let(:alphabet_array) { alphabet_input.lines(chomp: true).map(&:chars) }

  describe ".decode" do
    it "returns the decoded input" do
      expect(described_class.decode(alphabet_array)).to eq "ABCEFGHJKLOPRSUYZ"
    end

    it "accepts alternative matrix characters" do
      expect(described_class.decode(hello_alt_array, on: "#", off: ".")).to eq "HELLO"
    end
  end

  describe "#to_s" do
    let(:dot_matrix) { described_class.new(hello_array) }

    it "returns the decoded input" do
      expect(dot_matrix.to_s).to eq "HELLO"
    end
  end

  describe "#print" do
    let(:dot_matrix) { described_class.new(hello_array) }

    it "prints the matrix input" do
      expect { dot_matrix.print }.to output(hello_input).to_stdout
    end
  end

  describe "#print_decoded" do
    let(:dot_matrix) { described_class.new(hello_array) }

    it "prints the decoded input to STDOUT" do
      expect { dot_matrix.print_decoded }.to output("HELLO\n").to_stdout
    end
  end
end
