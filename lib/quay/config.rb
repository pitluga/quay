module Quay
  class Config
    def self.eval_from_path(path)
      evaluate(File.read(path))
    end

    def self.evaluate(contents)
      config = self.new
      config.instance_eval(contents)
      config
    end

    attr_reader :deps

    def dep(name, options={})
      @deps ||= {}
      @deps[name] = options
    end
  end
end
