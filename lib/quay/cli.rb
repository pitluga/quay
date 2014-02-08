module Quay
  class CLI < Thor
    class_option :config, type: :string

    desc "version", "Prints version and exits"
    def version
      puts "Quay Version #{VERSION}"
    end

    desc "tasks", "list available tasks"
    def tasks
      config = Quay::Config.eval_from_path(options[:config])
      config.tasks.each do |name, _|
        puts name
      end
    end

    desc "run TASK", "runs the given task"
    def run_task(name)
      config = Quay::Config.eval_from_path(options[:config])
      task = config.tasks[name]

      task.fetch(:depends, []).each do |dep|
        puts "starting #{dep}"
        Dependency.start(dep, config.deps[dep])
      end
      state = Quay::State.new
      env_lookup = Quay::EnvLookup.new(state)

      env = task.fetch(:env, {}).map do |k,v|
        if v =~ /^\$/
          value = env_lookup.get(v)
          "#{k}=#{value}"
        else
          "#{k}=#{v}"
        end
      end

      opts = {
        'Image' => task[:image],
        'Cmd' => task[:cmd],
        'Env' => env,
      }
      container = Docker::Container.create(opts)
      container.start

      state.save_container(name, container.id)

      puts "Started #{name} #{container.id[0...12]}"
      container.attach do |stream, chunk|
        puts "#{stream}: #{chunk}"
      end
      task.fetch(:depends, []).each do |dep|
        puts "stopping #{dep}"
        Dependency.stop(dep, config.deps[dep])
      end
    end

    desc "services", "lists available services"
    def services
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

    desc "start SERVICE", "start a SERVICE"
    def start(name)
      config = Quay::Config.eval_from_path(options[:config])
      container = Dependency.start(name, config.deps[name])
      puts "Started #{name} #{container.id[0...12]}"
    end

    desc "stop SERVICE", "stop a SERVICE"
    def stop(name)
      config = Quay::Config.eval_from_path(options[:config])
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
