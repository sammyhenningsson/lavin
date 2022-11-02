# frozen_string_literal: true

module Lavin
  class Hook
    attr_reader :user, :block, :type

    def initialize(user:, type: :before, &block)
      @user = user
      @block = block
      @type = type
    end

    def run(context: nil)
      call(context:)
      Runner.yield
    end

    def call(context:)
      report_statistics = context.client.report_statistics
      context.client.report_statistics = false
      context.instance_exec(&block)
    rescue RecoverableError
    rescue => error
      puts "Caught #{error.class} in #{type} hook: #{error.message}"
      puts error.backtrace unless error.is_a? IrrecoverableError
      throw :failure
    ensure
      context.client.report_statistics = report_statistics
    end
  end
end
