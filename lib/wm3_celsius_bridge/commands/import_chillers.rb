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
      group = find_or_build_group(name: 'Kylaggregat', url: 'chillers')
      unless group.save
        reporter.error(
          message: "Could not save group #{group.url}",
          info: group.errors.full_messages,
        )
        return false
      end

      filtered_chillers = chillers
        .select { |chiller| valid_serial_number?(chiller.serial_no) }

      removed_count = chillers.size - filtered_chillers.size
      reporter.info(message: "Removed #{removed_count} chillers based on filter settings.")

      imported = filtered_chillers.map do |chiller|
        import_chiller(chiller: chiller, group: group)
      end.compact

      reporter.finish(message: "Imported #{imported.size} of #{chillers.size} chillers.")
    end

    private

    attr_reader :store, :chillers, :reporter

    def import_chiller(chiller:, group:)
      product = find_or_build_product(
        sku: chiller.serial_no,
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
    rescue StandardError => e
      reporter.error(
        message: "Could not import chiller (serial_no=#{chiller.serial_no})",
        info: e.message
      )
      return nil
    end

    def valid_serial_number?(serial_no)
      serial_no.present? && serial_no =~ /^(M|Z)-/i
    end
  end
end
