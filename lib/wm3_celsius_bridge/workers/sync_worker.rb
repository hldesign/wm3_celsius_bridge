# frozen_string_literal: true

module Wm3CelsiusBridge
  # SyncWorker starts a complete import of
  # data from NAV
  #
  # ==== Attributes
  #
  # * +client+        - A client to request data from NAV.
  # * +store+         - Storage for parsed NAV items.
  # * +limit+         - Max amount of NAV items to import.
  # * +last_sync+     - Only sync items changed after last_sync.
  # * +sync_configs+  - Configure individual syncs.
  #
  # ==== Examples
  #
  #   client = NavClient.new(debug: true)
  #   store = Shop::Store.first
  #
  #   SyncWorker.new(
  #     client: client,
  #     store: store,
  #     limit: 100,
  #     sync_configs: {
  #       customers: {
  #         enabled: true,
  #         include_ids: ['1234', '5678']
  #       },
  #       chillers: {
  #         enabled: true,
  #       },
  #       articles: {
  #         enabled: true,
  #       },
  #       service_ledger: {
  #         enabled: true,
  #       },
  #       orders: {
  #         enabled: true
  #       }
  #     }
  #   ).call
  class SyncWorker
    def initialize(
      client:,
      store:,
      limit: 0,
      last_sync: Time.zone.today - 1,
      sync_configs:)

      @client = client
      @store = store
      @limit = limit
      @last_sync = last_sync
      @sync_configs = sync_configs
    end

    def call
      @reporter = build_reporter

      # Note that import order matters.
      sync_customers if sync_configs[:customers][:enabled]
      sync_chillers if sync_configs[:chillers][:enabled]
      sync_articles if sync_configs[:articles][:enabled]
      sync_service_ledger_entries if sync_configs[:service_ledger][:enabled]

      export_service_orders if sync_configs[:orders][:enabled]

      reporter
    end

    private

    attr_reader :client, :store, :limit, :last_sync, :sync_configs, :reporter

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
          include_ids: sync_configs[:customers][:include_ids],
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

    def sync_service_ledger_entries
      main_reporter = reporter.sub_report(title: 'Import service ledger')

      sub_reporter = main_reporter.sub_report(title: 'Fetch service ledger from NAV')
      begin
        resp = client.service_ledger_entries(posting_date: last_sync)
        unless resp.ok?
          sub_reporter.error(message: resp.message)
          return
        end
        sub_reporter.finish(message: "Fetched #{resp.data.size} service ledger entries.")
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Parse fetched service ledger data')
      begin
        entries = ParseItems.new(
          data: resp.data,
          item_class: ServiceLedgerEntry,
          reporter: sub_reporter
        ).call
      rescue StandardError => e
        sub_reporter.error(message: e.message)
        return
      end

      sub_reporter = main_reporter.sub_report(title: 'Store parsed service ledger data')
      begin
        limited_entries = limit > 0 ? entries.take(limit) : entries
        ImportServiceLedgerEntries.new(
          store: store,
          entries: limited_entries,
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
          store: store,
          client: client,
          orders: nav_orders,
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
