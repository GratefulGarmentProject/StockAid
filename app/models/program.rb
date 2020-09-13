class Program
  attr_reader :name, :external_id

  def initialize(name, external_id)
    @name = name
    @external_id = external_id
  end
end
