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
          
          dump_config(env, config)

          raise env[:machine].inspect
          vmx_file = env[:machine].box.directory.join("").to_s

          # Terminate the instance if we were interrupted
          terminate(env) if env[:interrupted]
          @app.call(env)
        end

        private 

        def dump_config(env, config)
          config.each_pairs do |k,v|
            env[:ui].info("#{k} -- #{v}")
          end
        end

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
