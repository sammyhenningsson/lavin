# frozen_string_literal: true

require "test_helper"
require "lavin/runner"
require "lavin/user"

module Lavin
  class Runner
    class RunnerTest < TestCase
      def test_that_total_user_count_is_calculated_from_personas
        3.times do |i|
          # Create three personas with 1, 2, 3 number of users
          Class.new(User) { user_count i + 1 }
        end

        runner = Runner.new

        assert_equal 6, runner.total_users
      end

      def test_that_all_users_can_be_spawned
        Class.new(User) { name "user1"; user_count 2; }
        Class.new(User) { name "user2"; user_count 1 }
        Class.new(User) { name "user3"; user_count 3 }

        runner = Runner.new
        spawned = []
        runner.spawn(count: 6) do |persona|
          spawned << persona.config[:name]
        end

        assert_equal(
          [
            "user1",
            "user2",
            "user3",
            "user1",
            "user3",
            "user3"
          ],
          spawned
        )

        runner.spawn { raise "No more personas should be yielded" }
      end

      def test_that_runner_can_start_all_users
        result = []

        Class.new(User) do
          name "user1"
          user_count 1
          iterations 1

          step { result << "#{name}_step1" }
          step { result << "#{name}_step2" }
        end

        Class.new(User) do
          name "user2"
          user_count 2
          iterations 1

          step { result << "#{name}_step1" }
          step { result << "#{name}_step2" }
        end

        runner = Runner.new
        runner.start
        runner.wait

        assert_equal(
          %w[
            user1_step1
            user1_step2
            user2_step1
            user2_step1
            user2_step2
            user2_step2
          ].sort,
          result.sort
        )
      end
    end
  end
end
