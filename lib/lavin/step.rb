# frozen_string_literal: true

require 'lavin/error'

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
    rescue SuccessfulStep, SuccessfulUser => error
      Statistics.register_step(user: user.name, step_name: name)
      throw :stop_user if error.is_a? SuccessfulUser
    rescue IrrecoverableError => error
      Statistics.register_step(user: user.name, step_name: name, failure: error.message)
      throw :stop_user
    rescue => error
      puts "Exception in #{user.name}.#{name} - #{error.class}: #{error.message}"
      Statistics.register_step(user: user.name, step_name: name, failure: error.message)
    end
  end
end
