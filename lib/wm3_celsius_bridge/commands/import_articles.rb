# frozen_string_literal: true

module Wm3CelsiusBridge
  # The ImportArticles command imports parsed articles into WM3.
  class ImportArticles
    include ProductImporter

    attr_reader :store, :articles

    def initialize(store:, articles:)
      @articles = articles
      @store = store
    end

    def call
      group = find_or_build_group(name: 'Articles')
      unless group.save
        Wm3CelsiusBridge.logger.fatal("Could not save group #{group.url}: #{group.errors.full_messages}")
        return false
      end

      imported = articles.map do |article|
        import_article(article: article, group: group)
      end.compact

      Wm3CelsiusBridge.logger.info("Imported #{imported.size} of #{articles.size} articles.")
    end

    private

    def import_article(article:, group:)
      product = find_or_build_product(
        sku: article.no,
        name: article.description
      )
      unless product.save
        Wm3CelsiusBridge.logger.error("Could not update product #{product.id}: #{product.errors.full_messages}")
        return
      end

      product_group = find_or_create_product_group(product, group)
      if product_group.new_record?
        Wm3CelsiusBridge.logger.error("Could not create or update product group for #{product.id}: #{product_group.errors.full_messages}")
        return
      end

      # Create or update properties
      article.to_hash.each_pair do |key, value|
        add_property_to_product(product: product, name: key, value: value)
      end

      true
    end
  end
end
