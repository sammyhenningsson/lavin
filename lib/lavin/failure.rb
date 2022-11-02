# frozen_string_literal: true

require 'lavin/error'

module Lavin
  module Failure
    class Error < Lavin::Error; end

    def failure(msg)
      raise Error, msg
    end
  end
end
