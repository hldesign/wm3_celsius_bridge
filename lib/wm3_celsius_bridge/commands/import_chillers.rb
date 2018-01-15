# frozen_string_literal: true

module Wm3CelsiusBridge
  # The ImportChillers command imports parsed chillers into WM3.
  class ImportChillers
    include ProductImporter

    attr_reader :store, :chillers

    def initialize(store:, chillers:)
      @chillers = chillers
      @store = store
    end

    def call
      group = find_or_build_group(name: 'Chillers')
      unless group.save
        Wm3CelsiusBridge.logger.fatal("Could not save group #{group.url}: #{group.errors.full_messages}")
        return false
      end

      imported = chillers.map do |chiller|
        import_chiller(chiller: chiller, group: group)
      end.compact

      Wm3CelsiusBridge.logger.info("Imported #{imported.size} of #{chillers.size} chillers.")
    end

    private

    def import_chiller(chiller:, group:)
      product = find_or_build_product(
        sku: "CH-#{chiller.no}",
        name: chiller.model
      )
      unless product.save
        Wm3CelsiusBridge.logger.error("Could not update product #{product.id}: #{product.errors.full_messages}")
        return
      end

      # Add product to customer product group
      # TODO: customer_no cannot be blank.
      if chiller.customer_no.present?
        add_to_customer_product_group(
          group_name: chiller.customer_no,
          product_id: product.id
        )
      end

      product_group = find_or_create_product_group(product, group)
      if product_group.new_record?
        Wm3CelsiusBridge.logger.error("Could not create or update product group for #{product.id}: #{product_group.errors.full_messages}")
        return
      end

      # Create or update properties
      chiller.to_hash.each_pair do |key, value|
        add_product_property(name: key, value: value)
      end

      true
    end

    def add_to_customer_product_group(group_name:, product_id:)
      group = store.customer_groups.where(name: group_name).first_or_create
      if group.new_record?
        Wm3CelsiusBridge.logger.error("Could not create or find customer group for customer number #{customer_no}.")
        return
      end

      group_product = group.customer_group_products.where(product_id: product_id).first_or_create
      if group_product.new_record?
        Wm3CelsiusBridge.logger.error("Could not create customer product group for customer number #{customer_no}.")
      end
    end
  end
end
