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
          container = Dependency.start(name, config.deps[name])
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
          container = Dependency.stop(name, dependency)
          if container.nil?
            puts "Skipping #{name}"
          else
            puts "Stopped #{name} #{container.id[0...12]}"
          end
        end
      end
    end
  end
end
