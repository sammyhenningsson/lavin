# frozen_string_literal: true

require 'lavin/error'

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
    rescue SuccessfulStep, RecoverableError
    rescue SuccessfulUser, IrrecoverableError
      throw :stop_user
    rescue => error
      puts "Exception in #{user.name}.#{type} block - #{error.class}: #{error.message}"
    ensure
      context.client.report_statistics = report_statistics
    end
  end
end
