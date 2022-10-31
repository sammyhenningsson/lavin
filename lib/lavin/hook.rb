# frozen_string_literal: true
#

module Lavin
  class Hook
    attr_reader :user, :block

    def initialize(user:, &block)
      @user = user
      @block = block
    end

    def run(context: nil)
      call(context:)
      Runner.yield
    end

    def call(context:)
      report_statistics = context.client.report_statistics
      context.client.report_statistics = false
      context.instance_exec(&block)
    rescue => error
      puts "Caught an error - #{error.class}: #{error.message}"
      puts error.backtrace
    ensure
      context.client.report_statistics = report_statistics
    end
  end
end
