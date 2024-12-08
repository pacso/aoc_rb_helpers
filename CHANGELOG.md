# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- No unreleased changes!

## [0.0.5]
### Added
- AocInput#process_each_line - Processes each line of the input data using the provided block
- Grid#includes_coords? - Returns `true` if the provided coordinates exist within the bounds of the grid
- Grid#beyond_grid? - Returns `true` if the provided coordinates exceed the bounds of the grid
- Grid#locate(value) - Returns the first coordinates within the grid containing the given value
- Grid#locate_all(value) - Returns an array of coordinates for any location within the grid containing the given value
- Grid#each_cell - Iterates over each cell in the grid

### Changed
- Grid#cell now returns `nil` if the provided coordinates to not exist within the grid
- Grid#set_cell nwo returns `nil` if the provided coordinates to not exist within the grid

### Fixed
- Grid#dup previously returned a new `Grid` instance with the same instance of the `@grid` array within it. Now `@grid` is a unique copy.

## [0.0.4]
### Added
- Grid class for working with two-dimensional arrays of data
- AocInput updated with convenience method for creating a Grid from input
- AocInput#sections added, for splitting input into multiple sections

## [0.0.3]
### Added
- Characters `I` and `T` now supported by DotMatrix
- Updated README with links to documentation
- Added documentation link to gemspec

## [0.0.2]
### Added
- DotMatrix class for decoding printed puzzle output

## [0.0.1]
Initial release.

### Added
- Created `AocInput` class with initial helper methods

[Unreleased]: https://github.com/pacso/aoc_rb_helpers/compare/v0.0.2...HEAD
[0.0.2]: https://github.com/pacso/aoc_rb_helpers/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/pacso/aoc_rb_helpers
