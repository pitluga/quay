module CLIDriver
  def quay(args)
    %x[ruby -I lib bin/quay #{args}]
  end
end
