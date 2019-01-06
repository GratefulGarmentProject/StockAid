require "csv"

module Reports
  class NetSuiteOrderExport
    FIELDS = %w(tranId customFormRef customerRef tranDate postingPeriodRef currencyRef exchangeRate termsRef
                leadSourceRef PO# excludeCommissions memo salesEffectiveDate toBePrinted toBeEmailed email toBeFaxed
                fax billAttention billAddressee billAddr1 billAddr2 billCity billState billZip billCountry billPhone
                shipAttention shipAddressee shipAddr1 shipAddr2 shipCity shipState shipZip shipCountry shipPhone
                shipMethodRef shipDate contractStartDate renewalDate shipCost FOB customerMessageRef salesRepRef
                departmentRef classRef locationRef isTaxable discount-discountItemRef discount-discountRate
                discount-discountTotal tax-taxItemRef tax-taxRate tax-taxTotal revRecScheduleRef revRecStartDate
                revRecEndDate itemLine_itemRef itemLine_quantity itemLine_salesPrice itemLine_amount
                itemLine_description itemLine_isTaxable itemLine_priceLevelRef itemLine_departmentRef itemLine_classRef
                itemLine_locationRef itemLine_revRecScheduleRef itemLine_revRecStartDate itemLine_revRecEndDate).freeze

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << FIELDS

        each do |row|
          csv << FIELDS.map { |field| row[field] }
        end
      end
    end

    def each
      yield Row.new
      yield Row.new
      yield Row.new
    end

    class Row
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      def [](field)
        case field
        when "tranId"
        when "customFormRef"
        when "customerRef"
        when "tranDate"
        when "postingPeriodRef"
        when "currencyRef"
        when "exchangeRate"
        when "termsRef"
        when "leadSourceRef"
        when "PO#"
        when "excludeCommissions"
        when "memo"
        when "salesEffectiveDate"
        when "toBePrinted"
        when "toBeEmailed"
        when "email"
        when "toBeFaxed"
        when "fax"
        when "billAttention"
        when "billAddressee"
        when "billAddr1"
        when "billAddr2"
        when "billCity"
        when "billState"
        when "billZip"
        when "billCountry"
        when "billPhone"
        when "shipAttention"
        when "shipAddressee"
        when "shipAddr1"
        when "shipAddr2"
        when "shipCity"
        when "shipState"
        when "shipZip"
        when "shipCountry"
        when "shipPhone"
        when "shipMethodRef"
        when "shipDate"
        when "contractStartDate"
        when "renewalDate"
        when "shipCost"
        when "FOB"
        when "customerMessageRef"
        when "salesRepRef"
        when "departmentRef"
        when "classRef"
        when "locationRef"
        when "isTaxable"
        when "discount-discountItemRef"
        when "discount-discountRate"
        when "discount-discountTotal"
        when "tax-taxItemRef"
        when "tax-taxRate"
        when "tax-taxTotal"
        when "revRecScheduleRef"
        when "revRecStartDate"
        when "revRecEndDate"
        when "itemLine_itemRef"
        when "itemLine_quantity"
        when "itemLine_salesPrice"
        when "itemLine_amount"
        when "itemLine_description"
        when "itemLine_isTaxable"
        when "itemLine_priceLevelRef"
        when "itemLine_departmentRef"
        when "itemLine_classRef"
        when "itemLine_locationRef"
        when "itemLine_revRecScheduleRef"
        when "itemLine_revRecStartDate"
        when "itemLine_revRecEndDate"
        end
      end
    end
  end
end
