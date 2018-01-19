module Wm3CelsiusBridge
  module HashExtensions
    refine Hash do
      def pascalcase_keys
        deep_transform_keys(self) { |key| pascalcase(key) }
      end

      def prefix_keys(prefix)
        deep_transform_keys(self) { |key| prefix + key }
      end

      private

      def deep_transform_keys(object, &block)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), result|
            result[yield(key)] = deep_transform_keys(value, &block)
          end
        when Array
          object.map { |e| deep_transform_keys(e, &block) }
        else
          object
        end
      end

      def pascalcase(value)
        value.to_s.split('_').map{|e| e.capitalize}.join
      end
    end
  end
end
