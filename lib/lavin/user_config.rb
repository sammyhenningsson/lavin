# frozen_string_literal: true

module Lavin
  module UserConfig
    DEFAULT = {
      enabled: true,
      user_count: 1,
      iterations: 1,
      base_url: nil
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

      def name(value = :no_value_given)
        if value == :no_value_given
          @name ||= to_s
        else
          @name = value
        end
      end

      def description(value = :no_value_given)
        if value == :no_value_given
          @description ||= ""
        else
          @description = value
        end
      end

      def enabled?
        !!config[:enabled]
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    attr_reader :config

    def initialize(**kwargs)
      @config = self.class.config
      super(**kwargs)
    end

    def name
      self.class.name
    end

    def description
      self.class.description
    end
  end
end
