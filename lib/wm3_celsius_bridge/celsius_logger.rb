module Wm3CelsiusBridge

  # CelsiusLogger wraps Ruby or Rails logger.
  class CelsiusLogger
    attr_reader :unwrap

    def initialize(logger)
      @logger = @unwrap = logger
    end

    %w(debug info warn error).each do |name|
      define_method(name) do |msg|
        logger.send(name, format_message(msg))
      end
    end

    def exception(e, args = {})
      extra_info = args[:info]

      error(extra_info) if extra_info
      error(e.message)
      error(e.backtrace.join("\n"))
    end

    private

    attr_reader :logger

    def format_message(msg)
      "[Celsius] #{msg}"
    end
  end
end
