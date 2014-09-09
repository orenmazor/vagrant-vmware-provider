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
          env[:machine_state_id] = read_state(env[:machine])

          @app.call(env)
        end

        def read_state(machine)
          return :not_created if machine.id.nil?

          # Find the machine
          vmrun_results = exec("ENV['VM_RUN_CMD'] list")
          raise vmrun_results


          #now what?
          # if server.nil? || [:"shutting-down", :terminated].include?(server.state.to_sym)
          #   # The machine can't be found
          #   @logger.info("Machine not found or terminated, assuming it got destroyed.")
          #   machine.id = nil
          #   return :not_created
          # end

          # Return the state
          return server.state.to_sym
        end
      end
    end
  end
end
