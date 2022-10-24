# frozen_string_literal: true

module Lavin
  class Step
    attr_reader :block
    attr_accessor :repeat

    def initialize(repeat: 1, &block)
      @repeat = repeat
      @block = block
    end

    def run
      repeat.times do
        call
        # Fiber.yield
      end
    end

    def call
      block.call
    rescue StandarError => _e
      # What to do here?
    end
  end
end
