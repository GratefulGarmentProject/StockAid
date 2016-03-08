module ItemsHelper
  def user_name(value)
    return "System" unless value
    User.find(value).name
  end
end
