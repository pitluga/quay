module Quay
  class Dependency
    def self.start(name, dependency)
      container = Docker::Container.create('Image' => dependency[:image])
      container.start

      state = Quay::State.new
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
