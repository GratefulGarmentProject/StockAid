class PermissionError < StandardError
  def initialize(msg = "You do not have proper permission!")
    super
  end

  class << self
    def check(user, options)
      return check_all(user, options) if options.is_a?(Array)
      return check_single(user, options) if options.is_a?(Symbol)
      return check_any(user, options[:one_of]) if options.is_a?(Hash) && options[:one_of]
      raise ArgumentError
    end

    private

    def check_single(user, permission_method)
      raise PermissionError unless user.send(permission_method)
    end

    def check_all(user, permission_methods)
      raise PermissionError if permission_methods.any? { |x| !user.send(x) }
    end

    def check_any(user, permission_methods)
      raise PermissionError if permission_methods.none? { |x| user.send(x) }
    end
  end
end
