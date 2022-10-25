# frozen_string_literal: true

require "lavin/user"
require "async"

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

    def self.yield
      Async::Task.current.yield if Async::Task.current?
    end

    def initialize(personas: nil)
      @personas = personas || User.personas
      @remaining = @personas.map { |persona| Entry.new(persona) }
      @total_users = @remaining.sum(&:count)
      @spawned_users = 0
      @index = -1
    end

    def start
      @task = Async(annotation: "Main") do |task|
        spawn(count: total_users) do |persona|
          next unless persona

          user_index = spawned_users
          annotation = "User: #{persona.config[:name]} ##{user_index}"
          task.async(annotation:) do |user_task|
            user = persona.new(user_index:)
            user.run
          ensure
            user.cleanup
          end
        end
      end
    rescue StandardError => error
      puts "Failed to run tasks: #{error.message}"
    ensure
      stop
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
