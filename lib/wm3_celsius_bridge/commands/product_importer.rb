# frozen_string_literal: true

module Wm3CelsiusBridge
  # The ProductImporter module contains common
  # product import functionality.
  module ProductImporter
    private

    def find_or_build_group(name:)
      store.groups.where(url: name.downcase).first_or_initialize.tap do |g|
        g.name = name
      end
    end

    def find_or_build_product(sku:, name:)
      product = product_by_sku(sku) || store.products.new

      product.tap do |p|
        p.master.assign_attributes(sku: sku, track_inventory: false)
        p.default_editable.assign_attributes(name: name)
        p.customer_group_specific = false
        p.available_on = DateTime.now if p.available_on.nil?
      end
    end

    def find_or_create_product_group(product, group)
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

    def add_property_to_product(product:, name:, value:)
      property = find_or_build_property(name: name)
      unless property.save
        reporter.error(
          message: "Could not create or update property '#{name}' on product #{product.id}",
          info: property.errors.full_messages,
        )
        return
      end

      # No blank values allowed on product properties.
      if value.blank?
        product.product_properties.where(property: property).destroy_all
        return
      end

      property_value = store.property_values.where(
        property: property,
        value: value.to_s
      ).first_or_create

      if property_value.new_record?
        reporter.error(
          message: "Could not create property value '#{value}' on property #{property.name} and product #{product.id}",
          info: property_value.errors.full_messages,
        )
        return
      end

      product_property = product.product_properties.where(
        property: property,
        property_value: property_value
      ).first_or_create

      if product_property.new_record?
        reporter.error(
          message: "Could not create product property with name '#{property.name}' and value #{property_value.value}",
          info: product_property.errors.full_messages,
        )
      end
    end
  end
end
