module ControllersHelper
  def signed_in_user(user_fixture)
    user = users(user_fixture)
    stub_warden(user)
    stub_controller(user)
  end

  def stub_warden(user)
    request.env["warden"] = double
    allow(request.env["warden"]).to receive(:authenticate!).and_return(user)
  end

  def stub_controller(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
