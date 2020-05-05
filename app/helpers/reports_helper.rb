module ReportsHelper
  def net_suite_export_select_options
    [
      ["NetSuite Donations Export", :donations],
      ["NetSuite Donors Export", :donors],
      ["NetSuite Orders Export", :orders],
      ["NetSuite Organizations Export", :organizations]
    ]
  end
end
