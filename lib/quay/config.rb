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

    attr_reader :deps, :tasks

    def initialize
      @deps = {}
      @tasks = {}
    end

    def dep(name, options={})
      @deps[name] = options
    end

    def task(name, options={})
      @tasks[name] = options
    end
  end
end
