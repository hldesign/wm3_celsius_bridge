# frozen_string_literal: true

module Wm3CelsiusBridge
  module OmitBlankAttributes
    def to_hash
      recursively_compact_blank(super)
    end

    private

    def recursively_compact_blank(hash)
      hash.each_with_object({}) do |(key, value), result|
        if value.is_a?(Hash)
          compacted_value = recursively_compact_blank(value)
          result[key] = compacted_value unless compacted_value.nil?
        elsif value && !value.to_s.empty?
          result[key] = value
        end
      end
    end
  end
end
