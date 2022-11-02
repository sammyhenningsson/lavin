# frozen_string_literal: true

require 'lavin/error'

module Lavin
  module Failure
    def failure(msg)
      raise RecoverableError, msg
    end

    def failure!(msg)
      raise IrrecoverableError, msg
    end
  end
end
