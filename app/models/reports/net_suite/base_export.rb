module Reports
  module NetSuite
    class BaseExport
      attr_reader :user, :report_type, :session

      def initialize(user, report_type, session)
        @user = user
        @report_type = report_type
        @session = session
      end

      def build
        case report_type
        when "donations" then build_donations_exporter
        when "donors" then build_donors_exporter
        when "orders" then build_orders_exporter
        when "organizatios" then build_organizatios_exporter
        end
      end

      def build_donations_exporter
        Reports::NetSuite::DonationExport.new(session) if user.can_view_donations?
      end

      def build_donors_exporter
        Reports::NetSuite::DonorExport.new(session) if user.can_view_donations?
      end

      def build_orders_exporter
        Reports::NetSuite::OrderExport.new(session)
      end

      def build_organizatios_exporter
        Reports::NetSuite::OrganizationExport.new(session) if user.can_create_organization?
      end
    end
  end
end
