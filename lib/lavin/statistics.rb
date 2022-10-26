# frozen_string_literal: true

module Lavin
  class Statistics
    class << self
      def reset
        self.data = {
          duration: 0,
          total_requests: 0,
          steps: [],
          requests: Hash.new { |h, k| h[k] = [] }
        }
      end

      def total_requests
        data[:total_requests]
      end

      def duration
        data[:duration]
      end

      def duration=(duration)
        data[:duration] = duration
      end

      def register_request(method:, url:, status:, duration:)
        data[:total_requests] += 1
        key = [method, url]
        success = status < 500
        data[:requests][key] << {status:, duration:, success:}
      end

      def register_step
        # TODO
      end

      def show
        time = Time.now
        puts <<~RESULT

          Lavin results:
          Test ran for #{duration}s
          Total number of requests: #{total_requests}
          Rate: #{sprintf("%.2f", total_requests/duration)} rps

        RESULT
        puts sprintf(
          "%-6<method>s %-100<url>s %-6<requests>s %12<avg_duration>s %12<min_duration>s %12<max_duration>s",
          method: "Method",
          url: "URL",
          requests: "Requests",
          avg_duration: "Avg duration",
          min_duration: "Min duration",
          max_duration: "Max duration",
        )
        divider = "-" * 156
        puts divider
        data[:requests].each do |(method, url), requests|
          durations = requests.map { |request| request[:duration] }
          min_duration = durations.min
          max_duration = durations.max
          avg_duration = durations.sum / durations.size
          puts sprintf(
            "%-6<method>s %-100<url>s %6<requests>d %12<avg_duration>fs %12<min_duration>fs %12<max_duration>fs",
            method: method.to_s.upcase,
            requests: requests.size,
            url:,
            avg_duration:,
            min_duration:,
            max_duration:,
          )
        end
        puts divider
        puts "Calculated results in #{Time.now - time}s"
      end

      private

      attr_accessor :data
    end
  end
end
