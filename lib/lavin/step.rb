# frozen_string_literal: true

module Lavin
  class Step
    attr_reader :user, :block, :repeat

    def initialize(repeat: 1, &block)
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
      # Report Success!
    rescue => error
      puts "Caught an error: #{error.message}"
      puts error.backtrace
      # Report Failure!
    end
  end
end
