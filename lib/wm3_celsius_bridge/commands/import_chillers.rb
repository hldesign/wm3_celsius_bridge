# frozen_string_literal: true

module Wm3CelsiusBridge
  # The ImportChillers command imports parsed chillers into WM3.
  class ImportChillers
    include ProductImporter

    def initialize(store:, chillers:, reporter:)
      @chillers = chillers
      @store = store
      @reporter = reporter
    end

    def call
      group = find_or_build_group(name: 'Chillers')
      unless group.save
        reporter.error(
          message: "Could not save group #{group.url}",
          info: group.errors.full_messages,
        )
        return false
      end

      imported = chillers.map do |chiller|
        import_chiller(chiller: chiller, group: group)
      end.compact

      reporter.finish(message: "Imported #{imported.size} of #{chillers.size} chillers.")
    end

    private

    attr_reader :store, :chillers, :reporter

    def import_chiller(chiller:, group:)
      product = find_or_build_product(
        sku: "CH-#{chiller.no}",
        name: chiller.model
      )
      unless product.save
        reporter.error(
          message: "Could not update product #{product.id}",
          model: chiller,
          info: product.errors.full_messages,
        )
        return
      end

      product_group = find_or_create_product_group(product, group)
      if product_group.new_record?
        reporter.error(
          message: "Could not create or update product group for #{product.id}",
          info: product.errors.full_messages,
          model: chiller,
        )
        return
      end

      # Create or update properties
      chiller.to_hash.each_pair do |key, value|
        add_property_to_product(product: product, name: key, value: value)
      end

      true
    end
  end
end
