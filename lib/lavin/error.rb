# frozen_string_literal: true

module Lavin
  class Error < StandardError; end

  class RecoverableError < Error; end

  class IrrecoverableError < Error; end
end
