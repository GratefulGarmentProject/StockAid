module NetSuiteIntegration
  class Region
    REGION_TYPE_ID = 83

    attr_reader :county_name, :region_record

    def initialize(county_name, region_record)
      @county_name = county_name
      @region_record = region_record
    end

    def self.all
      NetSuite::Records::CustomRecord.search(
        basic: [
          {
            field: "recType",
            operator: "is",
            value: NetSuite::Records::CustomRecordRef.new(internal_id: REGION_TYPE_ID)
          }
        ]
      ).results.map do |result|
        new(result.name, result)
      end
    rescue
      []
    end

    def self.find(county_name)
      region_record = netsuite_search("#{county_name} County") if county_name.present?
      region_record ||= netsuite_search("California")
      new(county_name, region_record)
    end

    def self.find_default
      find(nil)
    end

    def self.netsuite_search(value)
      NetSuite::Records::CustomRecord.search(
        basic: [
          {
            field: "recType",
            operator: "is",
            value: NetSuite::Records::CustomRecordRef.new(internal_id: REGION_TYPE_ID)
          }, {
            field: "name",
            operator: "is",
            value: value
          }
        ]
      ).results.first
    end

    def netsuite_id
      region_record&.internal_id
    end

    def netsuite_id_int
      region_record&.internal_id.presence&.to_i
    end

    def assign_to(netsuite_record)
      return unless region_record
      netsuite_record.custom_field_list.custcol_cseg_npo_region =
        NetSuite::Records::CustomRecordRef.new(internal_id: netsuite_id, type_id: REGION_TYPE_ID)
    end

    def to_h
      {
        external_id: netsuite_id_int,
        name: county_name
      }
    end
  end
end
