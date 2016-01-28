class PermissionError < StandardError
  def initialize(msg = "You do not have proper permission!")
    super msg
  end
end
