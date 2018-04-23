module Wm3CelsiusBridge
  module OmitBlankAttributes
    def to_hash
      super.reject { |_, v| v.blank? }
    end
  end
end
