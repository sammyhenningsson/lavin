# frozen_string_literal: true

require 'lavin/stats'

module Lavin
  class Statistics
    class << self
      # FIXME: make thread safe

      def meassure
        reset
        data[:start] = Time.now
        yield.tap { data[:duration] = Time.now - data[:start] }
      end

      def reset
        self.data = new_data
      end

      def stop
        return if data.frozen?

        data[:duration] = (Time.now - data[:start])
        data.freeze
      end

      def total_requests
        data[:total_requests]
      end

      def total_steps
        data[:step_summary][:count]
      end

      def duration
        return data[:duration] if data[:duration]

        Time.now - data[:start] if data[:start]
      end

      def register_request(method:, url:, status:, duration:)
        data[:total_requests] += 1
        key = [method, url]
        result = {status:, duration:}
        result[:failure] = true if status > 499
        data[:requests][key] << result
      end

      def register_step(user:, step_name:, failure: nil)
        data[:step_summary][:count] += 1
        data[:step_summary][:success] += 1 unless failure
        data[:step_summary][:failure] += 1 if failure
        key = [user, step_name]
        data[:steps][key][:success] += 1 unless failure
        data[:steps][key][:failure] += 1 if failure
        data[:failures][failure.to_s] += 1 if failure
      end

      def stats
        reset unless data
        time = Time.now

        requests = data[:requests].map do |(method, url), requests|
          durations = []
          statuses = []
          failed_requests = 0
          requests.each do |request|
            durations << request[:duration]
            statuses << request[:status]
            failed_requests += 1 if request[:failure]
          end
          min_duration = durations.min
          max_duration = durations.max
          avg_duration = durations.empty? ? 0 : (durations.sum / durations.size)

          {
            method: method.to_s.upcase,
            url: url,
            requests: requests.size,
            statuses: statuses.tally,
            failed_requests:,
            avg_duration:,
            min_duration:,
            max_duration:
          }
        end

        Stats.new(
          duration: duration,
          total_requests: total_requests,
          rate: duration ? format("%.2f", total_requests / duration) : 0,
          step_summary: data[:step_summary],
          steps: data[:steps],
          requests: requests,
          failures: data[:failures]
        ).tap do |stats|
          # FIXME remove!
          puts "Calculated stats in #{Time.now - time}s"
        end
      end

      def show
        values = stats

        show_summary(values)

        show_steps(values) do |(user, step), hash|
          format(
            "%-48<user_step>s %8<success>d %8<failure>d",
            user_step: "#{user}.#{step}",
            **hash
          )
        end

        show_table(values) do |request_values|
          format(
            "%-6<method>s %-100<url>s %6<requests>d %12<avg_duration>fs %12<min_duration>fs %12<max_duration>fs",
            **request_values
          )
        end

        show_failures(values) do |message, count|
          format("%-64<message>s %6<count>d", message:, count:)
        end
      end

      private

      def data
        synchronize { @data ||= new_data }
      end

      def data=(values)
        synchronize { @data = values }
      end

      def synchronize(&block)
        @mutex ||= Thread::Mutex.new
        @mutex.synchronize(&block)
      end

      def new_data
        {
          start: nil,
          duration: nil,
          total_requests: 0,
          step_summary: {
            count: 0,
            success: 0,
            failure: 0
          },
          steps: Hash.new { |h, k| h[k] = {success: 0, failure: 0} },
          requests: Hash.new { |h, k| h[k] = [] },
          failures: Hash.new { |h, k| h[k] = 0 }
        }
      end

      def show_summary(values)
        puts <<~RESULT

          Lavin results:
          Test ran for #{values.duration}s
          Total number of requests: #{values.total_requests}
          Rate: #{format("%.2f", values.total_requests / values.duration)} rps

          Total number of steps: #{values.total_steps}
          Step success rate: #{format("%.2f %%", 100 * values.successful_steps.to_f / values.total_steps)}
        RESULT
      end

      def show_steps(values)
        puts format(
          "\n%-48<user_step>s %8<success>s %8<failure>s",
          user_step: "Steps",
          success: "Success",
          failure: "Failure"
        )
        divider = "-" * 66
        puts divider
        values.each_step { |step_values| puts yield step_values }
        puts divider
      end

      def show_table(values)
        puts format(
          "\n%-6<method>s %-100<url>s %-6<requests>s %12<avg_duration>s %12<min_duration>s %12<max_duration>s",
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

      def show_failures(values)
        puts format("\n%-64<message>s %6<count>s", message: "Failures", count: "Count")
        divider = "-" * 71
        puts divider
        values.each_failure { |failures| puts yield failures }
        puts divider
      end
    end
  end
end
