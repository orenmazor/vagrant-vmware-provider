require "log4r"

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
          
          env[:ui].info("HELLO! current box id is *#{env[:machine].id}*")
          env[:ui].info("HELLO! current box directory is *#{env[:machine].box.directory}*")
          vmx_file = env[:machine].box.directory.join("").to_s

          # Terminate the instance if we were interrupted
          env[:ui].info("WARNING: interrupted") if env[:interrupted]
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
