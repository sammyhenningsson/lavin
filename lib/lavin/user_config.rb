# frozen_string_literal: true

module Lavin
  module UserConfig
    DEFAULT = {
      user_count: 1,
      iterations: -1
    }.freeze

    module ClassMethods
      def config
        @config ||= DEFAULT.dup
      end

      DEFAULT.each_key do |name|
        define_method(name) do |value = :no_value_given|
          current = config.fetch(name) # Make sure the key exist!
          if value == :no_value_given
            current
          else
            config[name] = value
          end
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    attr_reader :config

    def initialize(...)
      @config = self.class.config
      super
    end
  end
end
