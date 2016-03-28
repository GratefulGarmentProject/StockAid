module UserInvitationsHelper
  def nearby_expiration_class(date)
    distance = (Time.zone.now - date).abs

    if distance <= 1.day.to_f
      "text-danger"
    elsif distance <= 3.days.to_f
      "text-warning"
    end
  end
end
