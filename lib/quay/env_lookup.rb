module Quay
  class EnvLookup
    def initialize(state)
      @state = state
    end

    def get(value)
      name, path = value.match(/\$(\w+):(.*)/).captures
      id = @state.containers[name]
      container = Docker::Container.get(id)
      json = container.json

      path.split("/").reduce(json) do |current, key|
        current[key]
      end
    end
  end
end
