module Users
  module DonorManipulator
    extend ActiveSupport::Concern

    def can_create_donors?
      super_admin?
    end

    def can_update_donors?
      super_admin?
    end

    def can_view_donors?
      super_admin?
    end

    def can_delete_and_restore_donors?
      super_admin?
    end

    def create_donor(params)
      raise PermissionError unless can_create_donors?
      donor_params = params.require(:donor)
      donor_params[:addresses_attributes].select! { |_, h| h[:address].present? }
      Donor.create! donor_params.permit(:name, :external_id, :email, :phone_number, addresses_attributes: [:address, :id])
    end

    def update_donor(params) # rubocop:disable Metrics/AbcSize
      raise PermissionError unless can_update_donors?

      transaction do
        donor = Donor.includes(:addresses).find(params[:id])
        donor_params = params.require(:donor)
        donor_params[:addresses_attributes].select! { |_, h| h[:address].present? }
        permitted_params = [:name, :external_id, :email, :phone_number, addresses_attributes: [:address, :id]]
        donor.update! donor_params.permit(permitted_params)
      end
    end
  end
end
