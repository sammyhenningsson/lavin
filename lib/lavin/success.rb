# frozen_string_literal: true

require 'lavin/error'

module Lavin
  module Success
    def success
      raise SuccessfulStep
    end

    def success!
      raise SuccessfulUser
    end
  end
end
