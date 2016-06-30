module ControllersHelper
  def no_user_signed_in
    stub_warden(nil)
    stub_controller(nil)
  end

  def signed_in_user(user_fixture)
    user = users(user_fixture)
    stub_warden(user)
    stub_controller(user)
  end

  def stub_warden(user) # rubocop:disable Metrics/AbcSize
    request.env["warden"] = double
    allow(request.env["warden"]).to receive(:authenticate!).and_return(user)
    allow(request.env["warden"]).to receive(:authenticate?) { |scope| user && scope[:scope] == user }
  end

  def stub_controller(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
