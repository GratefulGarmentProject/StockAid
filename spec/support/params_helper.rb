module ParamsHelper
  def params(hash)
    ActionController::Parameters.new(hash)
  end
end
