# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "lavin"
require "lavin/user"

require "minitest/autorun"
require "debug"

class TestCase < Minitest::Test
  def setup
    Lavin::Statistics.reset
    super
  end

  def teardown
    Lavin::User.instance_variable_set(:@all_personas, Set.new)
    Lavin::Statistics.reset
    super
  end
end

class MockClient
  attr_accessor :report_statistics

  def initialize(*)
    @report_statistics = true
  end

  def close = nil

  def request(_method, **_kwargs)
    [200, {}, "mock_data"]
  end
end

class TestUser < Lavin::User
  def initialize(**kwargs)
    client = MockClient.new
    super(**kwargs.merge(client:))
  end
end
