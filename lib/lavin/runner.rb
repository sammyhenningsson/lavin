# frozen_string_literal: true

require 'async'
require 'lavin/user'
require 'lavin/statistics'

module Lavin
  class Runner
    class Entry
      class DepletedError < Lavin::Error
        def initialize(msg = nil)
          super(msg || "Depleted")
        end
      end

      attr_reader :persona, :name
      attr_accessor :count

      def initialize(persona)
        @persona = persona
        @name = persona.config[:name]
        @count = persona.user_count
      end

      def present?
        count.positive?
      end

      def get
        raise DepletedError unless present?

        self.count -= 1
        persona
      end
    end

    attr_reader :personas, :total_users, :remaining
    attr_accessor :spawned_users, :index

    class << self
      attr_accessor :thread

      def yield
        Async::Task.current.yield if Async::Task.current?
      end

      def start
        new.start
      end

      def start_async
        self.thread = Thread.new do
          new.start
          stop
          exit
        end
      rescue StandardError => error
        puts "Failed to run in thread: #{error.message}"
        thread.join
        thread = nil
        raise
      end

      def stop
        Statistics.stop
        thread&.kill
        self.thread = nil
      end

      def running?
        return false unless thread
        return true if %w[run sleep].include? thread.status

        stop
        false
      end
    end

    def initialize(personas: nil)
      @personas = personas || User.personas
      @remaining = @personas.map { |persona| Entry.new(persona) }
      @total_users = @remaining.sum(&:count)
      @spawned_users = 0
      @index = -1
    end

    def start
      Statistics.meassure { create_async_task }
    rescue StandardError => error
      puts "Failed to run tasks: #{error.message}"
      raise
    ensure
      stop
    end

    def create_async_task
      @task = Async(annotation: "Main") do |task|
        spawn(count: total_users) do |persona|
          next unless persona

          user_index = spawned_users
          annotation = "User: #{persona.name} ##{user_index}"
          task.async(annotation:) do |user_task|
            user = persona.new(user_index:)
            user.run
          ensure
            user.cleanup
          end
        end
      end
    end

    def wait
      @task&.wait
    end

    def stop
      @task&.stop
      @task&.wait
    end

    def spawn(count: 1)
      count.times do
        persona = next_persona
        break unless persona

        self.spawned_users += 1
        yield persona
      end
    end

    def next_persona
      self.index += 1

      entry = remaining[index % remaining.size]
      if entry.present?
        entry.get
      elsif remaining.any?(&:present?)
        next_persona
      end
    end
  end
end
