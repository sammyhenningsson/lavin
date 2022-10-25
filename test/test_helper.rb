# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "lavin"

require "minitest/autorun"
require "debug"

class TestCase < Minitest::Test
  def teardown
    Lavin::User.instance_variable_set(:@all_personas, Set.new)
    super
  end
end
