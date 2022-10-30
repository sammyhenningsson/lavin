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
    end
  end
end
