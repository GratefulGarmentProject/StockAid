module NetSuiteIntegration
  EXPORT_QUEUED_EXTERNAL_ID = -1
  EXPORT_IN_PROGRESS_EXTERNAL_ID = -2
  EXPORT_FAILED_EXTERNAL_ID = -3

  def self.host
    "#{NetSuite::Configuration.account}.app.netsuite.com"
  end

  def self.path(object)
    case object
    when Order
      "https://#{host}/app/accounting/transactions/custinvc.nl?id=#{object.external_id}"
    when Donation
      "https://#{host}/app/accounting/transactions/cashsale.nl?id=#{object.external_id}"
    when Purchase
      "https://#{host}/app/accounting/transactions/vendbill.nl?id=#{object.external_id}"
    when Donor
      if NetSuiteIntegration::DonorExporter.person_type?(object.external_type)
        "https://#{host}/app/common/entity/contact.nl?id=#{object.external_id}"
      else
        "https://#{host}/app/common/entity/custjob.nl?id=#{object.external_id}"
      end
    when Organization
      "https://#{host}/app/common/entity/custjob.nl?id=#{object.external_id}"
    when Vendor
      "https://#{host}/app/common/entity/vendor.nl?id=#{object.external_id}"
    end
  end

  def self.external_id_or_status_text(object)
    return unless object.external_id

    if export_queued?(object)
      "Export queued"
    elsif export_in_progress?(object)
      "Export in progress"
    elsif export_failed?(object)
      "Export failed!"
    else
      object.external_id
    end
  end

  def self.export_queued(object)
    object.external_id = NetSuiteIntegration::EXPORT_QUEUED_EXTERNAL_ID
    object.save!
  end

  def self.export_queued?(object)
    object.external_id == NetSuiteIntegration::EXPORT_QUEUED_EXTERNAL_ID
  end

  def self.export_in_progress(object)
    object.external_id = NetSuiteIntegration::EXPORT_IN_PROGRESS_EXTERNAL_ID
    object.save!
  end

  def self.export_in_progress?(object)
    object.external_id == NetSuiteIntegration::EXPORT_IN_PROGRESS_EXTERNAL_ID
  end

  def self.export_failed(object)
    object.external_id = NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID
    object.save!
  end

  def self.export_failed?(object)
    object.external_id == NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID
  end

  def self.exported_successfully?(object)
    object.external_id && object.external_id > 0
  end
end
