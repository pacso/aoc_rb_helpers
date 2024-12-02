require_relative "lib/aoc_rb_helpers/version"

Gem::Specification.new do |spec|
  spec.name = "aoc_rb_helpers"
  spec.version = AocRbHelpers::VERSION
  spec.authors = ["Jon Pascoe"]
  spec.email = ["jon.pascoe@me.com"]

  spec.summary = %q{Helper methods to simplify solving Advent of Code puzzles}
  spec.description = %q{Enhances the aoc_rb gem with tools for parsing puzzle input, and handling various data manipulations within Advent of Code puzzle solutions.}
  spec.homepage = "https://github.com/pacso/aoc_rb_helpers"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new("~> 3.1", ">= 3.1.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://rubydoc.info/github/pacso/aoc_rb_helpers"
  spec.metadata["changelog_uri"] = "https://github.com/pacso/aoc_rb_helpers/blob/main/CHANGELOG"

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aoc_rb", "~> 0.2", ">= 0.2.6"
  spec.add_dependency "puts_debuggerer", '~> 1.0', '>= 1.0.1'
end
