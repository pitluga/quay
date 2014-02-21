module Quay
  class CLI < Thor
    include Thor::Actions

    class_option :config, type: :string
    source_root File.expand_path("../templates", __FILE__)

    def self.exit_on_failure?
      true
    end

    desc "version", "Prints version and exits"
    def version
      puts "Quay Version #{VERSION}"
    end

    desc "init [dir]", "create a new Quayfile"
    def init(dir=nil)
      target = dir ? File.join(dir, 'Quayfile') : 'Quayfile'
      copy_file('Quayfile', target)
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
      raise Thor::Error.new("unknown task #{name.inspect}") if task.nil?

      Array(task[:depends]).each do |dependency|
        puts "starting #{dependency}"
        Container.start(dependency, config.services[dependency])
      end

      container = Container.start(name, task)

      puts "Started #{name} #{container.id[0...12]}"
      container.attach do |stream, chunk|
        puts "#{stream}: #{chunk}"
      end
      exit_code = container.wait(10000)["StatusCode"]

      Array(task[:depends]).each do |dependency|
        puts "stopping #{dependency}"
        Container.stop(dependency, config.services[dependency])
      end

      exit exit_code
    end

    desc "services", "lists available services"
    def services
      config = Quay::Config.eval_from_path(options[:config])
      state = Quay::State.new
      lines = config.services.keys.sort.map do |service|
        id = state.containers[service]
        if id
          container = Docker::Container.get(id)
          [service, container.id[0...12]]
        else
          [service, nil]
        end
      end
      puts "DEPENDENCY CONTAINER_ID"
      puts lines.map{|col| col.join(" ") }.join("\n")
    end

    desc "start SERVICE", "start a SERVICE"
    def start(name)
      config = Quay::Config.eval_from_path(options[:config])
      service = config.services[name]

      raise Thor::Error.new("unknown service #{name.inspect}") if service.nil?

      container = Container.start(name, service)
      puts "Started #{name} #{container.id[0...12]}"
    end

    desc "stop SERVICE", "stop a SERVICE"
    def stop(name)
      config = Quay::Config.eval_from_path(options[:config])
      service = config.services[name]

      raise Thor::Error.new("unknown service #{name.inspect}") if service.nil?

      container = Container.stop(name, service)
      if container.nil?
        puts "Skipping #{name}"
      else
        puts "Stopped #{name} #{container.id[0...12]}"
      end
    end
  end
end
