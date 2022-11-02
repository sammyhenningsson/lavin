# frozen_string_literal: true
#

module Lavin
  class Step
    attr_reader :name, :user, :block, :repeat

    def initialize(name:, user:, repeat: 1, &block)
      @name = name
      @user = user
      @repeat = repeat
      @block = block
    end

    def run(context: nil)
      repeat.times do
        call(context:)
        Runner.yield
      end
    end

    def call(context:)
      context.instance_exec(&block)
      Statistics.register_step(user: user.name, step_name: name)
    rescue => error
      Statistics.register_step(user: user.name, step_name: name, failure: error.message)
    end
  end
end
