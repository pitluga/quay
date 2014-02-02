module Quay
  module Commands
    class Deps < Thor
      desc "list", "lists dependencies and their statuses"
      def list
        config = Quay::Config.eval_from_path(options[:config])
        state = Quay::State.new
        lines = config.deps.keys.sort.map do |dep|
          id = state.containers[dep]
          if id
            container = Docker::Container.get(id)
            [dep, container.id[0...12]]
          else
            [dep, nil]
          end
        end
        puts "DEPENDENCY CONTAINER_ID"
        puts lines.map{|col| col.join(" ") }.join("\n")
      end

      desc "start [DEPENDENCY]", "start a given dependency"
      def start(name=nil)
        config = Quay::Config.eval_from_path(options[:config])

        if name.nil?
          config.deps.keys.each do |dep_name|
            start(dep_name)
          end
        else
          dependency = config.deps[name]

          container = Docker::Container.create('Image' => dependency[:image])
          container.start

          state = Quay::State.new
          state.save_container(name, container.id)

          puts "Started #{name} #{container.id[0...12]}"
        end
      end

      desc "stop [DEPENDENCY]", "stop a given dependency"
      def stop(name=nil)
        config = Quay::Config.eval_from_path(options[:config])

        if name.nil?
          config.deps.keys.each do |dep_name|
            stop(dep_name)
          end
        else
          dependency = config.deps[name]
          state = Quay::State.new
          id = state.containers[name]

          if id.nil?
            puts "Skipping #{name}"
          else
            container = Docker::Container.get(id)
            container.stop

            state.remove_container(name)

            puts "Stopped #{name} #{id[0...12]}"
          end
        end
      end

      # default_task :list
    end
  end
end
