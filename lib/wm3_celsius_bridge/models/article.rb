# frozen_string_literal: true

module Wm3CelsiusBridge
  # The Article Class wraps the SOAP
  # response into something simpler.
  class Article < Dry::Struct
    # General
    attribute :no, Types::NonBlankStrippedString # No blanks.
    attribute :description, Types::StrippedString

    attribute :shelf_no, Types::StrippedString # Lots of blanks
    attribute :item_category_code, Types::StrippedString # ["ARBETSTID", "EJ VARUGRP", "TILLBEHÖR", "ÖVR RES_DL", "INST.MTRL", "CT RES_DL", "RESERVDEL", "FÖRBR.MTRL", "MHI RES_DL", "VERKTYG", "AGGREGAT", "TK RES_DL", "ZAN RES_DL"]. Two blanks: No="F-", "M-TJJ119A250".
    attribute :search_description, Types::StrippedString
    attribute :last_date_modified, Types::Strict::Date # One blank: No="F-".
    attribute :stockout_warning, Types::Form::Bool # ["0", "1"]. No blanks.
    attribute :prevent_negative_inventory, Types::Form::Bool # ["0", "1"]. No blanks.
    attribute :costing_method, Types::Coercible::Int # ["0", "3"]. No blanks.
    attribute :costis_adjusted, Types::Strict::Bool # [true, false]. No blanks.
    attribute :costis_postedto_gl, Types::Strict::Bool # [true]. No blanks.
    attribute :last_direct_cost, Types::Coercible::Float # Decimal point string. No blanks.
    attribute :price_profit_calculation, Types::Coercible::Int # # ["0"]. No blanks.
    attribute :uni_t_price, Types::Coercible::Float # Decimal point string. No blanks.
    attribute :gen_prod_posting_group, Types::Strict::String # ["ARBETSTID", "VAROR", "AGGREGAT", "FRAKT"]. One blank: No="F-".
    attribute :vat_prod_posting_group, Types::Strict::String # ["TORED", "VORED" "ORED"]. Two blanks: No="F-", "ANK00003".
    attribute :inventory_posting_group, Types::Coercible::String # ["LAGER", nil]. Lots of blanks.
    attribute :allow_invoice_disc, Types::Strict::Bool # [true]. No blanks.
    attribute :sales_unitof_measure, Types::Strict::String # ["TIM", "ST", "MILT", "SET", "MIL", "M", "PAR", "PCS", "KG", "LTR", "PKT"]. One blank: No="F-".
    attribute :model, Types::Coercible::Int.optional # # ["3"]. Lots of blanks (only two non-blanks).
    attribute :coolants_type_id, Types::Coercible::String # [nil]. Only blanks.
    attribute :coolants_volume, Types::Coercible::Float # ["0.00"]. Decimal point string. No blanks.
  end
end
