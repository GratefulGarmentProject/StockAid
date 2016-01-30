class PermissionError < StandardError
  def initialize(msg = "You do not have proper permission!")
    super msg
  end

  class << self
    def check(user, *options)
      return check_all(user, options) if options.size > 1
      return check_single(user, options.first) if options.first.is_a?(Symbol)
      return check_any(user, options.first[:one_of]) if options.first.is_a?(Hash) && options.first[:one_of]
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
