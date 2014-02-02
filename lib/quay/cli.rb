module Quay
  class CLI < Thor
    class_option :config, type: :string

    desc "version", "Prints version and exits"
    def version
      puts "Quay Version #{VERSION}"
    end

    desc "deps [list,start,stop]", "Manage dependencies"
    subcommand "deps", Commands::Deps
  end
end
