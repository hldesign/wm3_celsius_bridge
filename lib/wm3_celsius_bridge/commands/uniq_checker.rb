# frozen_string_literal: true

module Wm3CelsiusBridge
  class UniqChecker
    def initialize(models:, prop_names:, reporter:)
      @store = {}
      @models = models
      @prop_names = prop_names
      @reporter = reporter
    end

    def call
      models.each { |model| add(model) }
      report
    end

    private

    attr_reader :store, :models, :prop_names, :reporter

    def add(model)
      prop_names.each do |name|
        prop = store[name] ||= {}
        val = prop[model[name]] ||= []
        val << model
      end
    end

    def report
      count = 0
      result = {}
      store.each do |name, props|
        props.each do |value, items|
          if items.size > 1
            count += 1
            result[name] ||= {}
            result[name][value] = items
            items.each do |item|
              reporter.warning(message: "Found duplicate for #{name} value '#{value}'.", model: item)
            end
          end
        end
      end
      reporter.finish(message: "Found #{count} duplicates.")
      result
    end
  end
end
