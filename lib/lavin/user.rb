# frozen_string_literal: true

require "set"
require "lavin/user_config"
require "lavin/worker"

module Lavin
  class User
    def self.inherited(subclass)
      super
      subclass.include UserConfig
      subclass.include Worker
      all_personas << subclass
    end

    def self.all_personas
      @all_personas ||= Set.new
    end

    def self.personas
      all_personas.select(&:enabled?)
    end

    attr_reader :user_index

    def initialize(**options)
      @user_index = options.delete(:user_index)
    end

    def user_name
      "##{user_index}_#{name}"
    end
  end
end
