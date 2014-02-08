module Quay
  class Container
    def self.start(name, container_config)
      state = Quay::State.new
      env_lookup = Quay::EnvLookup.new(state)

      env = container_config.fetch(:env, {}).map do |k,v|
        if v =~ /^\$/
          value = env_lookup.get(v)
          "#{k}=#{value}"
        else
          "#{k}=#{v}"
        end
      end

      opts = {
        'Image' => container_config[:image],
        'Cmd' => container_config[:cmd],
        'Env' => env,
      }
      container = Docker::Container.create(opts)
      container.start

      state.save_container(name, container.id)

      container
    end

    def self.stop(name, dependency)
      state = Quay::State.new
      id = state.containers[name]

      return if id.nil?

      container = Docker::Container.get(id)
      container.stop

      state.remove_container(name)

      container
    end
  end
end
