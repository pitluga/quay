module CLIDriver
  def quay(args)
    %x[ruby -I lib bin/quay #{args} 2>&1]
  end
end
