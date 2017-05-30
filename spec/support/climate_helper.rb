module ClimateHelper
  def with_env(env, &block)
    ClimateControl.modify(env, &block)
  end
end
