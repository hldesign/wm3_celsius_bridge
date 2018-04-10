# frozen_string_literal: true

module Wm3CelsiusBridge
  class NullReporter
    def initialize(*args)
    end

    def method_missing(*args)
      self
    end
  end
end
