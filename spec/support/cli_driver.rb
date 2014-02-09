module CLIDriver
  def quay(args)
    lib = File.expand_path('../../../lib', __FILE__)
    bin = File.expand_path('../../../bin/quay', __FILE__)
    %x[ruby -I #{lib} #{bin} #{args} 2>&1]
  end
end
