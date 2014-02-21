module Quay
  class Config
    def self.eval_from_path(custom_path)
      evaluate(File.read(determine_path(custom_path)))
    end

    def self.determine_path(custom_path)
      custom_path || ENV["QUAYFILE"] || "Quayfile"
    end

    def self.evaluate(contents)
      config = self.new
      config.instance_eval(contents)
      config
    end

    attr_reader :services, :tasks

    def initialize
      @services = {}
      @tasks = {}
    end

    def service(name, options={})
      @services[name] = options
    end

    def task(name, options={})
      @tasks[name] = options
    end
  end
end
