# frozen_string_literal: true

module Wm3CelsiusBridge
  # CelsiusLogger wraps Ruby or Rails logger.
  class CelsiusLogger < SimpleDelegator
    %w[debug info warn error fatal].each do |name|
      define_method(name) do |msg = nil, &block|
        message = block ? block.call : msg
        super("[CELSIUS BRIDGE] #{message}")
      end
    end
  end
end
