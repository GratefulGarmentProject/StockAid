require "rails_helper"

RSpec.describe ExportDonorJob, type: :job do
  let(:donor) { donors(:picard) }

  it "exports the donor via NetSuiteIntegration" do
    exporter = instance_double(NetSuiteIntegration::DonorExporter)
    allow(NetSuiteIntegration::DonorExporter).to receive(:new).with(donor).and_return(exporter)
    allow(NetSuiteIntegration).to receive(:export_in_progress)
    allow(exporter).to receive(:export)

    ExportDonorJob.perform_now(donor.id)

    expect(NetSuiteIntegration).to have_received(:export_in_progress).with(donor)
    expect(exporter).to have_received(:export)
  end

  it "records failure and logs when export raises" do
    allow(NetSuiteIntegration).to receive(:export_in_progress)
    allow(NetSuiteIntegration::DonorExporter).to receive(:new).and_raise(RuntimeError, "NS error")
    allow(NetSuiteIntegration).to receive(:export_failed)
    allow(FailedNetSuiteExport).to receive(:record_error)

    expect { ExportDonorJob.perform_now(donor.id) }.not_to raise_error

    expect(NetSuiteIntegration).to have_received(:export_failed).with(donor)
    expect(FailedNetSuiteExport).to have_received(:record_error).with(donor, instance_of(RuntimeError))
  end
end

RSpec.describe ExportVendorJob, type: :job do
  let(:vendor) { vendors(:guinan) }

  it "exports the vendor via NetSuiteIntegration" do
    exporter = instance_double(NetSuiteIntegration::VendorExporter)
    allow(NetSuiteIntegration::VendorExporter).to receive(:new).with(vendor).and_return(exporter)
    allow(NetSuiteIntegration).to receive(:export_in_progress)
    allow(exporter).to receive(:export)

    ExportVendorJob.perform_now(vendor.id)

    expect(NetSuiteIntegration).to have_received(:export_in_progress).with(vendor)
    expect(exporter).to have_received(:export)
  end

  it "records failure and logs when export raises" do
    allow(NetSuiteIntegration).to receive(:export_in_progress)
    allow(NetSuiteIntegration::VendorExporter).to receive(:new).and_raise(RuntimeError, "NS error")
    allow(NetSuiteIntegration).to receive(:export_failed)
    allow(FailedNetSuiteExport).to receive(:record_error)

    expect { ExportVendorJob.perform_now(vendor.id) }.not_to raise_error
  end
end

RSpec.describe ExportOrganizationJob, type: :job do
  let(:org) { organizations(:acme) }

  it "exports the organization via NetSuiteIntegration" do
    exporter = instance_double(NetSuiteIntegration::OrganizationExporter)
    allow(NetSuiteIntegration::OrganizationExporter).to receive(:new).with(org).and_return(exporter)
    allow(NetSuiteIntegration).to receive(:export_in_progress)
    allow(exporter).to receive(:export)

    ExportOrganizationJob.perform_now(org.id)

    expect(NetSuiteIntegration).to have_received(:export_in_progress).with(org)
    expect(exporter).to have_received(:export)
  end

  it "records failure and logs when export raises" do
    allow(NetSuiteIntegration).to receive(:export_in_progress)
    allow(NetSuiteIntegration::OrganizationExporter).to receive(:new).and_raise(RuntimeError, "NS error")
    allow(NetSuiteIntegration).to receive(:export_failed)
    allow(FailedNetSuiteExport).to receive(:record_error)

    expect { ExportOrganizationJob.perform_now(org.id) }.not_to raise_error
  end
end
