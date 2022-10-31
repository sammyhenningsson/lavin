# frozen_string_literal: true

require 'lavin/step'
require 'lavin/hook'

module Lavin
  module Worker
    module ClassMethods
      def before(&block)
        return @before unless block

        @before = Hook.new(user: self, &block)
      end

      def after(&block)
        return @after unless block

        @after = Hook.new(user: self, &block)
      end

      def steps
        @steps ||= []
      end

      def step(name: nil, **options, &block)
        name ||= "Step##{steps.size + 1}"
        steps << Step.new(user: self, name:, **options, &block)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    attr_writer :index

    def initialize(**kwargs)
      @task = kwargs.delete(:task)
      super(**kwargs)
    end

    def run
      self.class.before.run(context: self).then { Runner.yield } if self.class.before

      run_step until finished?

      self.class.after.run(context: self).then { Runner.yield } if self.class.after
    end

    private

    attr_reader :task

    def sleep(seconds)
      task.sleep seconds
    end

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
