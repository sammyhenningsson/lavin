# frozen_string_literal: true

module Lavin
  class Stats
    attr_reader :duration, :total_requests, :rate, :requests, :step_summary, :steps

    def initialize(duration:, total_requests:, rate:, requests: [], step_summary: {}, steps: [])
      @duration = duration
      @total_requests = total_requests
      @rate = rate
      @requests = requests
      @step_summary = step_summary
      @steps = steps
    end

    def empty?
      requests.empty?
    end

    def to_h
      {
        duration:,
        total_requests:,
        rate:,
        requests:,
        step_summary:,
        steps:
      }
    end

    def total_steps
      @step_summary[:count]
    end

    def successful_steps
      @step_summary[:success]
    end

    def failed_steps
      @step_summary[:failure]
    end

    def each_step(&block)
      steps.each(&block)
    end

    def each_request(&block)
      requests.each(&block)
    end
  end
end
