# frozen_string_literal: true

module Wm3CelsiusBridge
  class ImportServiceLedgerEntries
    include ProductImporter

    def initialize(store:, entries:, reporter:)
      @entries = entries
      @store = store
      @reporter = reporter
    end

    def call
      group = find_or_build_group(name: 'Servicetransaktioner', url: 'chiller-services')
      unless group.save
        reporter.error(
          message: "Could not save group #{group.url}",
          info: group.errors.full_messages,
        )
        return false
      end

      imported = entries.map do |entry|
        import_entry(entry: entry, group: group)
      end.compact

      reporter.finish(message: "Imported #{imported.size} of #{entries.size} service ledger entries.")
    end

    private

    attr_reader :store, :entries, :reporter

    def import_entry(entry:, group:)
      product = find_or_build_product(
        sku: "SLE-#{entry.entry_no}",
        name: entry.description
      )
      unless product.save
        reporter.error(
          message: "Could not update product #{product.id}",
          model: entry,
          info: product.errors.full_messages,
        )
        return
      end

      product_group = find_or_create_product_group(product, group)
      if product_group.new_record?
        reporter.error(
          message: "Could not create or update product group for #{product.id}",
          info: product.errors.full_messages,
          model: entry,
        )
        return
      end

      # Create or update properties
      entry.to_hash.each_pair do |key, value|
        add_property_to_product(product: product, name: key, value: value)
      end

      true
    rescue StandardError => e
      reporter.error(
        message: "Could not import service ledger entry (serial_no=#{entry.serial_no})",
        info: e.message
      )
      return nil
    end
  end
end
