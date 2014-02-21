module WithEnv
  def with_env(key, value, &block)
    old_env = ENV[key]
    ENV[key] = value
    block.call
    ENV[key] = old_env
  end
end
