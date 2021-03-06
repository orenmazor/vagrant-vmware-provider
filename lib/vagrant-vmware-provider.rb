require "pathname"

require "vagrant-vmware-provider/plugin"
#using vagrant-aws as a template for this
module VagrantPlugins
  module VMwareProvider
    lib_path = Pathname.new(File.expand_path("../vagrant-vmware-provider", __FILE__))
    autoload :Action, lib_path.join("action")

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
  end
end
