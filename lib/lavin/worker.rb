# frozen_string_literal: true

require 'lavin/step'

module Lavin
  module Worker
    module ClassMethods
      def before(&block)
        return @before unless block

        @before = block
      end

      def after(&block)
        return @after unless block

        @after = block
      end

      def steps
        @steps ||= []
      end

      def step(**options, &block)
        steps << Step.new(**options, &block)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    attr_writer :index

    def run
      self.class.before.call.then { Runner.yield } if self.class.before

      run_step until finished?

      self.class.after.call.then { Runner.yield } if self.class.after
    end

    private

    def run_step
      current_step = steps[step_index]
      self.index += 1
      current_step&.run(context: self)
    end

    def steps
      self.class.steps
    end

    def index
      @index ||= 0
    end

    def step_index
      index % steps.size
    end

    def iteration
      @iteration ||= 0
    end

    def finished?
      return false if config[:iterations].negative?

      (index / steps.size) >= config[:iterations]
    end
  end
end
