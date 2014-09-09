require "log4r"

module VagrantPlugins
  module VMwareProvider
    module Action
      # This action reads the state of the machine and puts it in the
      # `:machine_state_id` key in the environment.
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_vmware_provider::action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env)

          @app.call(env)
        end

        def read_state(env)
          return :not_created if env[:machine].id.nil?

          machine_vmx_file = env[:machine].box.directory.join("packer-vmware-iso.vmx").to_s
          # Find the machine
          vmrun_results = `#{ENV['VM_RUN_PATH']} list`

          machine_running = vmrun_results.gsub("\n","").include?(machine_vmx_file)

          return :stopped unless machine_running 
          return :running if machine_running
        end
      end
    end
  end
end
