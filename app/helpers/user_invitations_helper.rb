module UserInvitationsHelper
  def nearby_expiration_class(date)
    distance = (Time.zone.now - date).abs

    if distance <= 1.day.to_f
      "text-danger"
    elsif distance <= 3.days.to_f
      "text-warning"
    end
  end

  def row_color_class(invite)
    if invite.expired?
      "text-danger"
    elsif invite.expires_at < Time.zone.now + 1.day
      "danger"
    elsif invite.expires_at < Time.zone.now + 5.day
      "warning"
    end
  end
end
