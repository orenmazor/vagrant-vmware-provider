require "log4r"

module VagrantPlugins
  module VMwareProvider
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_vmware_provider::action::read_ssh_info")
        end

        def call(env)
          env[:machine_ssh_info] = read_ssh_info(env)

          @app.call(env)
        end

        def read_ssh_info(env)
          return nil if env[:machine].id.nil?

          #we should make this into a middleware that sets the machine file? maybe?
          machine_vmx_file = env[:machine].box.directory.join("packer-vmware-iso.vmx").to_s
          vmrun_results = `#{ENV['VM_RUN_PATH']} -T ws readVariable \"#{machine_vmx_file}\" guestVar ip`
          # read attribute override
          host_ip = vmrun_results.trim

          return { :host => host_ip, :port => 22 }
        end
      end
    end
  end
end
