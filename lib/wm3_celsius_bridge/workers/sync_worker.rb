# frozen_string_literal: true

module Wm3CelsiusBridge
  # SyncWorker starts a complete import of
  # data from NAV
  #
  # ==== Attributes
  #
  # * +client+ - A client to request data from NAV.
  # * +store+ - Storage for parsed NAV items.
  # * +limit+ - Max amount of NAV items to import.
  #
  # ==== Examples
  #
  #   client = NavClient.new(debug: true)
  #   store = Shop::Store.first
  #
  #   SyncWorker.new(
  #     client: client,
  #     store: store,
  #     limit: 100
  #   ).call
  class SyncWorker
    def initialize(
      client:,
      store:,
      limit: 0,
      last_sync: Time.zone.today - 1)

      @client = client
      @store = store
      @limit = limit
      @last_sync = last_sync
    end

    def call
      @reporter = build_reporter

      # Note that import order matters.
      sync_customers
      sync_chillers
      sync_articles

      export_service_orders

      reporter
    end

    private

    attr_reader :client, :store, :limit, :last_sync, :reporter

    def sync_customers
      main_reporter = reporter.sub_report(title: 'Import customers')

      sub_reporter = main_reporter.sub_report(title: 'Fetch customers from NAV')
      begin
        resp = client.customers
        unless resp.ok?
          sub_reporter.error(message: resp.message)
          return
        end
        sub_reporter.finish(message: "Fetched #{resp.data.size} customers.")
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Parse fetched customer data')
      begin
        customers = ParseItems.new(
          data: resp.data,
          item_class: Customer,
          reporter: sub_reporter,
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Check unique constraints')
      begin
        UniqChecker.new(
          models: customers,
          prop_names: [:no],
          reporter: sub_reporter
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Store parsed customer data')
      begin
        limited_customers = limit > 0 ? customers.take(limit) : customers
        ImportCustomers.new(
          customers: limited_customers,
          store: store,
          reporter: sub_reporter,
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end
    end

    def sync_chillers
      main_reporter = reporter.sub_report(title: 'Import chillers')

      sub_reporter = main_reporter.sub_report(title: 'Fetch chillers from NAV')
      begin
        resp = client.chillers
        unless resp.ok?
          sub_reporter.error(message: resp.message)
          return
        end
        sub_reporter.finish(message: "Fetched #{resp.data.size} chillers.")
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Parse fetched chiller data')
      begin
        chillers = ParseItems.new(
          data: resp.data,
          item_class: Chiller,
          reporter: sub_reporter
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Check unique constraints')
      begin
        UniqChecker.new(
          models: chillers,
          prop_names: [:no, :serial_no],
          reporter: sub_reporter
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Store parsed chiller data')
      begin
        limited_chillers = limit > 0 ? chillers.take(limit) : chillers
        ImportChillers.new(
          store: store,
          chillers: limited_chillers,
          reporter: sub_reporter,
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end
    end

    def sync_articles
      main_reporter = reporter.sub_report(title: 'Import articles')

      sub_reporter = main_reporter.sub_report(title: 'Fetch articles from NAV')
        .start(message: "Filter articles modified after #{last_sync}")
      begin
        resp = client.parts_and_service_types(modified_after: last_sync)
        unless resp.ok?
          sub_reporter.error(message: resp.message)
          return
        end
        sub_reporter.finish(message: "Fetched #{resp.data.size} articles.")
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Parse fetched article data')
      begin
        articles = ParseItems.new(
          data: resp.data,
          item_class: Article,
          reporter: sub_reporter,
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Check unique constraints')
      begin
        UniqChecker.new(
          models: articles,
          prop_names: [:no],
          reporter: sub_reporter
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Store parsed article data')
      begin
        limited_articles = limit > 0 ? articles.take(limit) : articles
        ImportArticles.new(
          store: store,
          articles: limited_articles,
          reporter: sub_reporter,
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end
    end

    def export_service_orders
      main_reporter = reporter.sub_report(title: 'Export service orders')

      sub_reporter = main_reporter.sub_report(title: 'Collect service orders from Celsius')
      begin
        celsius_orders = CollectServiceOrders.new(
          store: store,
          reporter: sub_reporter,
        ).call
        reporter.finish(message: "Collected #{celsius_orders.count} orders.")
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Build NAV service orders')
      begin
        nav_orders = BuildServiceOrders.new(
          data: celsius_orders,
          reporter: sub_reporter,
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Export service orders to NAV')
      begin
        resp = ExportServiceOrders.new(
          data: nav_orders,
          reporter: sub_reporter,
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end
    end

    def build_reporter
      EventReporter.new(title: 'CELSIUS: NAV sync summary')
        .start(message: "Called with: last_sync=#{last_sync} limit=#{limit}")
    end
  end
end
