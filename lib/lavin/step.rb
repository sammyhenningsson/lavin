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

    def call(context: nil)
      if context
        context.instance_exec(&block)
      else
        block.call
      end
    rescue StandarError => error
      puts "Caught an error: #{error.message}"
      # What to do here?
    end
  end
end
