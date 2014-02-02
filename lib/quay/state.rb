module Quay
  class State
    def initialize(file = ".quay.yml")
      @file = file
    end

    def containers
      _state["containers"]
    end

    def save_container(name, id)
      containers[name] = id
      _save
    end

    def remove_container(name)
      containers.delete(name)
      _save
    end

    def _state
      _load if @state.nil?
      @state
    end

    def _save
      File.open(@file, "w") do |file|
        YAML.dump(@state, file)
      end
    end

    def _load
      if File.exists?(@file)
        @state = YAML.load_file(@file)
      else
        @state = {}
      end
      @state.default_proc = proc { |hash, key| hash[key] = {} }
      @state
    end
  end
end
