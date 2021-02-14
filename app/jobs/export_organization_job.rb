class ExportOrganizationJob < ApplicationJob
  queue_as :default

  def perform(organization_id)
    organization = Organization.find(organization_id)

    begin
      NetSuiteIntegration.export_in_progress(organization)
      NetSuiteIntegration::OrganizationExporter.new(organization).export
    rescue => e
      NetSuiteIntegration.export_failed(organization)
      Rails.logger.error("Error exporting organization #{organization.id}: #{ErrorUtil.error_details(e)}")
    end
  end
end
