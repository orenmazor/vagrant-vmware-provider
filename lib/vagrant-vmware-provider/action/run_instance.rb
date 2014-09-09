require "log4r"
require 'securerandom'

module VagrantPlugins
  module VMwareProvider
    module Action
      class RunInstance
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_vmware_provider::action::run_instance")
        end

        def call(env)
          config = env[:machine].provider_config
          
          vmpath = env[:machine].box.directory
          vmpath = vmpath.join("packer-vmware-iso.vmxf").to_s

          env[:ui].info("trying to load *#{vmpath}*")
          result = system("#{ENV['VM_RUN_PATH']} -T ws start \"#{vmpath}\"")

          if result
            env[:machine].id = SecureRandom.uuid
          end



          # Terminate the instance if we were interrupted
          terminate(env) if env[:interrupted]
          @app.call(env)
        end

        private 

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Action.action_destroy, destroy_env)
        end

      end
    end
  end
end
