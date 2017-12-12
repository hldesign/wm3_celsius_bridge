# frozen_string_literal: true

module Wm3CelsiusBridge
  # The ImportChillers command imports parsed chillers into WM3.
  class ImportChillers
    attr_reader :chillers, :store

    def initialize(chillers:, store:)
      @chillers = chillers
      @store = store
    end

    def call
      @group = find_or_build_group
      unless @group.save
        Wm3CelsiusBridge.logger.fatal("Could not save group #{group.url}: #{group.errors.full_messages}")
        return false
      end

      imported = chillers.map { |c| import_chiller(c) }.compact
      Wm3CelsiusBridge.logger.info("Imported #{imported.size} of #{chillers.size} chillers.")
    end

    private

    attr_reader :group

    def import_chiller(chiller)
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
      unless chiller.customer_no.blank?
        add_to_customer_product_group(chiller.customer_no, product.id)
      end

      product_group = find_or_create_product_group(product)
      if product_group.new_record?
        Wm3CelsiusBridge.logger.error("Could not create or update product group for #{product.id}: #{product_group.errors.full_messages}")
        return
      end

      # Create or update properties
      chiller.to_hash.each_pair do |key, value|

        property = find_or_build_property(name: key)
        unless property.save
          Wm3CelsiusBridge.logger.error("Could not create or update property '#{key}' on product #{product.id}")
          next
        end

        # No blank values allowed on product properties.
        if value.blank?
          product.product_properties.where(property: property).destroy_all
          next
        end

        property_value = store.property_values.where(
          property: property,
          value: value
        ).first_or_create

        if property_value.new_record?
          Wm3CelsiusBridge.logger.error("Could not create property value '#{value}' on property #{property.name} and product #{product.id}")
          next
        end

        product_property = product.product_properties.where(
          property: property,
          property_value: property_value
        ).first_or_create

        if product_property.new_record?
          Wm3CelsiusBridge.logger.error("Could not create product property with name '#{property.name}' and value #{property_value.value}")
        end
      end

      true
    end

    def find_or_build_product(sku:, name:)
      product = product_by_sku(sku) || store.products.new

      product.tap do |p|
        p.master.assign_attributes(sku: sku)
        p.default_editable.assign_attributes(name: name)
        p.customer_group_specific = true
      end
    end

    def find_or_build_group
      store.groups.where(url: "chillers").first_or_initialize.tap do |g|
        g.name = "Chillers"
      end
    end

    def find_or_create_product_group(product)
      product.product_groups.where(group: group).first_or_create
    end

    def product_by_sku(sku)
      store.products.joins(:master).where(shop_variants: { sku: sku }).first
    end

    def find_or_build_property(name:)
      locale = store.default_locale

      store.properties.where(name: name).first_or_initialize.tap do |p|
        p.presentation = { locale => name.to_s.titleize }
      end
    end

    def add_to_customer_product_group(customer_no, product_id)
      group = store.customer_groups.where(name: customer_no).first_or_create
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
