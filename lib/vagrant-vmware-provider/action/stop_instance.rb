require "log4r"

module VagrantPlugins
  module VMwareProvider
    module Action
      # This stops the running instance.
      class StopInstance
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_vmware_provider::action::stop_instance")
        end

        def call(env)
          if env[:machine].state.id == :stopped
            env[:ui].info(I18n.t("vagrant_vmware_provider.already_status", :status => env[:machine].state.id))
          else
            env[:ui].info(I18n.t("vagrant_vmware_provider.stopping"))

            vmpath = env[:machine].box.directory
            vmpath = vmpath.join("packer-vmware-iso.vmxf").to_s
            system("#{ENV['VM_RUN_PATH']} -T ws start \"#{vmpath}\"")
          end

          @app.call(env)
        end
      end
    end
  end
end
