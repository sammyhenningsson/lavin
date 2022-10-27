# frozen_string_literal: true

require 'lavin/stats'

module Lavin
  class Statistics
    class << self
      # FIXME: make thread safe

      def meassure
        reset
        start = Time.now
        yield.tap { self.duration = Time.now - start }
      end

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
        puts "registering request.."
        data[:total_requests] += 1
        key = [method, url]
        success = status < 500
        data[:requests][key] << {status:, duration:, success:}
      end

      def register_step
        # TODO
      end

      def stats
        reset unless data
        time = Time.now

        requests = data[:requests].map do |(method, url), requests|
          durations = []
          statuses = []
          requests.each do |request|
            durations << request[:duration]
            statuses << request[:status]
          end
          min_duration = durations.min
          max_duration = durations.max
          avg_duration = durations.empty? ? 0 : (durations.sum / durations.size)

          {
            method: method.to_s.upcase,
            url: url,
            requests: requests.size,
            statuses: statuses.tally,
            avg_duration: avg_duration,
            min_duration: min_duration,
            max_duration: max_duration,
          }
        end

        Stats.new(
          duration: duration,
          total_requests: total_requests,
          rate: duration.zero? ? 0: format("%.2f", total_requests / duration),
          requests: requests
        ).tap do |stats|
          # FIXME remove!
          puts "Calculated stats in #{Time.now - time}s"
          p stats.to_h
        end
      end

      def show
        values = stats

        show_summary(values)

        show_table(values) do |request_values|
          format(
            "%-6<method>s %-100<url>s %6<requests>d %12<avg_duration>fs %12<min_duration>fs %12<max_duration>fs",
            **request_values
          )
        end
      end

      private

      attr_accessor :data

      def show_summary(values)
        puts <<~RESULT

          Lavin results:
          Test ran for #{values.duration}s
          Total number of requests: #{values.total_requests}
          Rate: #{format("%.2f", values.total_requests/values.duration)} rps

        RESULT
      end

      def show_table(values)
        puts format(
          "%-6<method>s %-100<url>s %-6<requests>s %12<avg_duration>s %12<min_duration>s %12<max_duration>s",
          method: "Method",
          url: "URL",
          requests: "Requests",
          avg_duration: "Avg duration",
          min_duration: "Min duration",
          max_duration: "Max duration"
        )

        divider = "-" * 156
        puts divider
        values.each_request { |request_values| puts yield request_values }
        puts divider
      end
    end
  end
end
