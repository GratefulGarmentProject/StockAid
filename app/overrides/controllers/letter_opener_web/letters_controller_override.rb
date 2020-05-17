if !Rails.env.production? && Rails.application.config.action_mailer.delivery_method == :letter_opener_web
  LetterOpenerWeb::LettersController.class_eval do
    before_action :ensure_admin!

    private

    def ensure_admin!
      raise PermissionError if current_user.nil?
      PermissionError.check(current_user, :super_admin?)
    end
  end
end
