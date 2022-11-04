# frozen_string_literal: true

require "test_helper"
require "lavin/user"

module Lavin
  class User
    class UserTest < TestCase
      def test_that_users_inheritng_from_the_base_class_get_configuration
        user_class = Class.new(User)

        assert_respond_to user_class, :user_count

        assert user_class.user_count

        user_class.user_count 5
        assert_equal 5, user_class.user_count
      end

      def test_that_it_runs
        result = []
        user_class = Class.new(TestUser) do
          iterations 2

          before { result << :before }
          after { result << :after }
          step { result << :step1 }
          step(repeat: 3) { result << :step2 }
        end

        user = user_class.new
        user.run

        assert_equal(
          %i[before step1 step2 step2 step2 step1 step2 step2 step2 after],
          result
        )
      end

      def test_that_a_step_can_be_aborted_successfully
        result = []
        user_class = Class.new(TestUser) do
          step(repeat: 2) do
            result << :good1
            success
            result << :bad
          end
          step do
            result << :good2
          end
        end

        user = user_class.new
        user.run

        assert_equal(%i[good1 good1 good2], result)
        assert_equal(3, Statistics.stats.successful_steps)
        assert_equal(0, Statistics.stats.failed_steps)
      end

      def test_that_a_user_can_be_aborted_successfully
        result = []
        user_class = Class.new(TestUser) do
          step(repeat: 2) do
            result << :good1
            success!
            result << :bad
          end
          step do
            result << :good2
          end
        end

        user = user_class.new
        user.run

        assert_equal(%i[good1], result)
        assert_equal(1, Statistics.stats.successful_steps)
        assert_equal(0, Statistics.stats.failed_steps)
      end

      def test_that_a_step_can_be_aborted_with_failure
        result = []
        user_class = Class.new(TestUser) do
          step(repeat: 2) do
            result << :good1
            failure "boom"
            result << :bad
          end
          step do
            result << :good2
          end
        end

        user = user_class.new
        user.run

        assert_equal(%i[good1 good1 good2], result)
        assert_equal(1, Statistics.stats.successful_steps)
        assert_equal(2, Statistics.stats.failed_steps)
      end

      def test_that_a_user_can_be_aborted_with_failure
        result = []
        user_class = Class.new(TestUser) do
          step(repeat: 2) do
            result << :good1
            failure! "boom"
            result << :bad
          end
          step do
            result << :good2
          end
        end

        user = user_class.new
        user.run

        assert_equal(%i[good1], result)
        assert_equal(0, Statistics.stats.successful_steps)
        assert_equal(1, Statistics.stats.failed_steps)
      end

      def test_that_before_hook_can_start_steps
        result = []
        user_class = Class.new(TestUser) do
          before do
            result << :before1
            success
            result << :before2
          end

          step do
            result << :step
          end
        end

        user = user_class.new
        user.run

        assert_equal(%i[before1 step], result)
        assert_equal(1, Statistics.stats.successful_steps)
        assert_equal(0, Statistics.stats.failed_steps)
      end

      def test_that_before_hook_can_successfully_finish_user
        result = []
        user_class = Class.new(TestUser) do
          before do
            result << :before1
            success!
            result << :before2
          end

          step do
            result << :step
          end
        end

        user = user_class.new
        user.run

        assert_equal(%i[before1], result)
        assert_equal(0, Statistics.stats.successful_steps)
        assert_equal(0, Statistics.stats.failed_steps)
      end

      def test_that_before_hook_can_unsuccessfully_finish_user
        result = []
        user_class = Class.new(TestUser) do
          before do
            result << :before1
            failure! "boom"
            result << :before2
          end

          step do
            result << :step
          end
        end

        user = user_class.new
        user.run

        assert_equal(%i[before1], result)
        assert_equal(0, Statistics.stats.successful_steps)
        assert_equal(0, Statistics.stats.failed_steps)
      end
    end
  end
end
