module NetSuiteIntegration
  EXPORT_QUEUED_EXTERNAL_ID = -1
  EXPORT_IN_PROGRESS_EXTERNAL_ID = -2
  EXPORT_FAILED_EXTERNAL_ID = -3
  EXPORT_NOT_APPLICABLE_EXTERNAL_ID = -4

  def self.host
    "#{NetSuite::Configuration.account}.app.netsuite.com"
  end

  def self.path(object, prefix: nil) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    case object
    when Order
      "https://#{host}/app/accounting/transactions/custinvc.nl?id=#{external_id_for(object, prefix: prefix)}"
    when Donation
      "https://#{host}/app/accounting/transactions/cashsale.nl?id=#{external_id_for(object, prefix: prefix)}"
    when Purchase
      if prefix == :variance
        "https://#{host}/app/accounting/transactions/journal.nl?id=#{external_id_for(object, prefix: prefix)}"
      else
        "https://#{host}/app/accounting/transactions/vendbill.nl?id=#{external_id_for(object, prefix: prefix)}"
      end
    when Donor
      if NetSuiteIntegration::DonorExporter.person_type?(object.external_type)
        "https://#{host}/app/common/entity/contact.nl?id=#{external_id_for(object, prefix: prefix)}"
      else
        "https://#{host}/app/common/entity/custjob.nl?id=#{external_id_for(object, prefix: prefix)}"
      end
    when Organization
      "https://#{host}/app/common/entity/custjob.nl?id=#{external_id_for(object, prefix: prefix)}"
    when Vendor
      "https://#{host}/app/common/entity/vendor.nl?id=#{external_id_for(object, prefix: prefix)}"
    end
  end

  def self.external_id_or_status_text(object, prefix: nil)
    return unless external_id_for(object, prefix: prefix)

    if export_queued?(object, prefix: prefix)
      "Export queued"
    elsif export_in_progress?(object, prefix: prefix)
      "Export in progress"
    elsif export_failed?(object, prefix: prefix)
      "Export failed!"
    elsif export_not_applicable?(object, prefix: prefix)
      "N/A"
    else
      external_id_for(object, prefix: prefix)
    end
  end

  def self.export_queued(object, prefix: nil)
    assign_external_id(object, NetSuiteIntegration::EXPORT_QUEUED_EXTERNAL_ID, prefix: prefix)
    object.save!
  end

  def self.export_queued?(object, prefix: nil)
    external_id_for(object, prefix: prefix) == NetSuiteIntegration::EXPORT_QUEUED_EXTERNAL_ID
  end

  def self.export_in_progress(object, prefix: nil)
    assign_external_id(object, NetSuiteIntegration::EXPORT_IN_PROGRESS_EXTERNAL_ID, prefix: prefix)
    object.save!
  end

  def self.export_in_progress?(object, prefix: nil)
    external_id_for(object, prefix: prefix) == NetSuiteIntegration::EXPORT_IN_PROGRESS_EXTERNAL_ID
  end

  def self.export_failed(object, prefix: nil)
    assign_external_id(object, NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID, prefix: prefix)
    object.save!
  end

  def self.export_failed?(object, prefix: nil)
    external_id_for(object, prefix: prefix) == NetSuiteIntegration::EXPORT_FAILED_EXTERNAL_ID
  end

  def self.export_not_applicable(object, prefix: nil)
    assign_external_id(object, NetSuiteIntegration::EXPORT_NOT_APPLICABLE_EXTERNAL_ID, prefix: prefix)
    object.save!
  end

  def self.export_not_applicable?(object, prefix: nil)
    external_id_for(object, prefix: prefix) == NetSuiteIntegration::EXPORT_NOT_APPLICABLE_EXTERNAL_ID
  end

  def self.exported_successfully?(object, prefix: nil)
    external_id = external_id_for(object, prefix: prefix)
    external_id && (external_id > 0 || external_id == NetSuiteIntegration::EXPORT_NOT_APPLICABLE_EXTERNAL_ID)
  end

  def self.external_id_for(object, prefix: nil)
    if prefix
      object.public_send("#{prefix}_external_id")
    else
      object.external_id
    end
  end

  def self.assign_external_id(object, value, prefix: nil)
    if prefix
      object.public_send("#{prefix}_external_id=", value)
    else
      object.external_id = value
    end
  end
end
