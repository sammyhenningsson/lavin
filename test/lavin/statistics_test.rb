# frozen_string_literal: true

require "test_helper"
require "lavin/runner"
require "lavin/user"

module Lavin
  class Statistics
    class StatisticsTest < TestCase
      def test_adding_http_request_stats
        Statistics.total_requests
        assert_equal 0, Statistics.total_requests

        Statistics.register_request(method: :get, url: "/foo", status: 200, duration: 1.5)

        assert_equal 1, Statistics.total_requests
      end
    end
  end
end

