# frozen_string_literal: true

require "test_helper"
require "lavin/runner"
require "lavin/user"

module Lavin
  class Statistics
    class StatisticsTest < TestCase
      def test_adding_http_request_stats
        assert_equal 0, Statistics.total_requests

        Statistics.register_request(method: :get, url: "/foo", status: 200, duration: 1.5)

        assert_equal 1, Statistics.total_requests
      end

      def test_adding_step_stats
        user_a = Class.new(TestUser) { name "A" }.new
        user_b = Class.new(TestUser) { name "B" }.new

        assert_equal 0, Statistics.total_steps

        Statistics.register_step(user: user_a, step_name: "step1")
        Statistics.register_step(user: user_a, step_name: "step1", failure: "boom")
        Statistics.register_step(user: user_b, step_name: "step1")

        stats = Statistics.stats
        assert_equal 3, stats.total_steps
        assert_equal 2, stats.successful_steps
        assert_equal 1, stats.failed_steps
      end
    end
  end
end

