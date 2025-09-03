class Role
  include Comparable
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def <=>(other)
    to_i <=> other.to_i
  end

  def to_i
    case value
    when "root"
      3
    when "admin"
      2
    when "report"
      1
    when "none"
      0
    else
      raise "Unknown role value: #{value.inspect}"
    end
  end
end
