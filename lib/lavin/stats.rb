# frozen_string_literal: true

module Lavin
  class Stats
    attr_reader :duration, :total_requests, :rate, :requests

    def initialize(duration:, total_requests:, rate:, requests: [])
      @duration = duration
      @total_requests = total_requests
      @rate = rate
      @requests = requests
    end

    def empty?
      requests.empty?
    end

    def to_h
      {
        duration:,
        total_requests:,
        rate:,
        requests:
      }
    end

    def each_request(&block)
      requests.each(&block)
    end
  end
end
