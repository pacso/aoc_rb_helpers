require "bundler/setup"

lib_path = File.join(File.dirname(__FILE__), "..", "lib", "aoc_rb_helpers", "*.rb")
Dir[lib_path].each { |file| require file }

Dir[File.join(File.dirname(__FILE__), "support", "**", "*.rb")].each { |file| require file }

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
