module NetSuiteIntegration
  EXPORT_QUEUED_EXTERNAL_ID = -1
  EXPORT_IN_PROGRESS_EXTERNAL_ID = -2
  EXPORT_FAILED_EXTERNAL_ID = -3

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
end
