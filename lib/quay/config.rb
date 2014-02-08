module Quay
  class Config
    def self.eval_from_path(path)
      path ||= "Quayfile"
      evaluate(File.read(path))
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
