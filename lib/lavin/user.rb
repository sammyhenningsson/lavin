# frozen_string_literal: true

require "lavin/user_config"
require "lavin/worker"

module Lavin
  class User
    def self.inherited(subclass)
      subclass.include UserConfig
      subclass.include Worker
      personas << subclass
    end

    def self.personas
      @personas ||= []
    end
  end
end
