# frozen_string_literal: true

require "lavin/user"
require "async"

module Lavin
  class Runner
    class Entry
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
        raise "Depleted" unless present?

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
          task.async(annotation:) { |t| persona.new(user_index:).run }
        end
      end
      # @task.reactor.print_hierarchy
    rescue StandardError => error
      puts "Failed to run tasks: #{error.message}"
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

      # print_status
      entry = remaining[index % remaining.size]
      if entry.present?
        entry.get
      elsif remaining.any?(&:present?)
        next_persona
      end
    end

    def print_status
      puts "\nindex: #{index}"
      puts "spawned_users: #{spawned_users}"
      puts remaining.to_h { |entry| [entry.name, entry.count] }
    end
  end
end
