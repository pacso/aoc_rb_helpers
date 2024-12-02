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
       XX  XXX   XX  XXX  XXXX XXXX  XX  X  X XXX   XX X  X X     XX  XXX  XXX   XXX XXX X  X X   X XXXX 
      X  X X  X X  X X  X X    X    X  X X  X  X     X X X  X    X  X X  X X  X X     X  X  X X   X    X 
      X  X XXX  X    X  X XXX  XXX  X    XXXX  X     X XX   X    X  X X  X X  X X     X  X  X  X X    X  
      XXXX X  X X    X  X X    X    X XX X  X  X     X X X  X    X  X XXX  XXX   XX   X  X  X   X    X   
      X  X X  X X  X X  X X    X    X  X X  X  X  X  X X X  X    X  X X    X X     X  X  X  X   X   X    
      X  X XXX   XX  XXX  XXXX X     XXX X  X XXX  XX  X  X XXXX  XX  X    X  X XXX   X   XX    X   XXXX 
    EOF
  end
  let(:code_input) do
    <<~EOF
       XX  XXXX X    XXXX X     XX  X   XXXXX  XX   XXX 
      X  X X    X    X    X    X  X X   XX    X  X X    
      X    XXX  X    XXX  X    X  X  X X XXX  X    X    
      X    X    X    X    X    X  X   X  X    X     XX  
      X  X X    X    X    X    X  X   X  X    X  X    X 
       XX  X    XXXX XXXX XXXX  XX    X  X     XX  XXX  
    EOF
  end

  def array_from_input(input)
    input.lines(chomp: true).map(&:chars)
  end

  describe ".decode" do
    it "returns the decoded input" do
      expect(described_class.decode(array_from_input alphabet_input)).to eq "ABCDEFGHIJKLOPRSTUYZ"
    end

    it "handles letters without spaces" do
      expect(described_class.decode(array_from_input code_input)).to eq "CFLELOYFCS"
    end

    it "accepts alternative matrix characters" do
      expect(described_class.decode(array_from_input(hello_input_alternate), on: "#", off: ".")).to eq "HELLO"
    end
  end

  describe "#to_s" do
    let(:dot_matrix) { described_class.new(array_from_input hello_input) }

    it "returns the decoded input" do
      expect(dot_matrix.to_s).to eq "HELLO"
    end
  end

  describe "#print" do
    let(:dot_matrix) { described_class.new(array_from_input hello_input) }

    it "prints the matrix input" do
      expect { dot_matrix.print }.to output(hello_input).to_stdout
    end
  end

  describe "#print_decoded" do
    let(:dot_matrix) { described_class.new(array_from_input hello_input) }

    it "prints the decoded input to STDOUT" do
      expect { dot_matrix.print_decoded }.to output("HELLO\n").to_stdout
    end
  end
end
