# frozen_string_literal: true

module Wm3CelsiusBridge
  # The ImportArticles command imports parsed articles into WM3.
  class ImportArticles
    include ProductImporter

    def initialize(store:, articles:, reporter:)
      @articles = articles
      @store = store
      @reporter = reporter
    end

    def call
      group = find_or_build_group(name: 'Articles')
      unless group.save
        reporter.error(
          message: "Could not save group #{group.url}",
          info: group.errors.full_messages,
        )
        return false
      end

      imported = articles.map do |article|
        import_article(article: article, group: group)
      end.compact

      reporter.finish(message: "Imported #{imported.size} of #{articles.size} articles.")
    end

    private

    attr_reader :store, :articles, :reporter

    def import_article(article:, group:)
      product = find_or_build_product(
        sku: article.no,
        name: article.description
      )
      unless product.save
        reporter.error(
          message: "Could not update product #{product.id}",
          model: article,
          info: product.errors.full_messages,
        )
        return
      end

      product_group = find_or_create_product_group(product, group)
      if product_group.new_record?
        reporter.error(
          message: "Could not create or update product group for #{product.id}",
          model: article,
          info: product_group.errors.full_messages,
        )
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
