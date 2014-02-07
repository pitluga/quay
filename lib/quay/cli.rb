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

      container = Docker::Container.create(
        'Image' => task[:image],
        'Cmd' => task[:cmd]
      )
      container.start

      state = Quay::State.new
      state.save_container(name, container.id)

      puts "Started #{name} #{container.id[0...12]}"
      container.attach do |stream, chunk|
        puts "#{stream}: #{chunk}"
      end
    end


    desc "deps [list,start,stop]", "Manage dependencies"
    subcommand "deps", Commands::Deps
  end
end
