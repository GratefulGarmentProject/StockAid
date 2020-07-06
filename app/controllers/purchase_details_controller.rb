class PurchaseDetailsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    pd = PurchaseDetail.find_by(id: params[:id])
    @old_id = pd.destroy!.id
  end
end
