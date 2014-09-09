require "pathname"

require "vagrant/action/builder"

ENV['VM_RUN_PATH'] = "/Applications/VMware\\ Fusion.app/Contents/Library/vmrun"

module VagrantPlugins
  module VMwareProvider
    module Action
      # Include the built-in modules so we can use them as top-level things.
      include Vagrant::Action::Builtin

      # This action is called to halt the remote machine.
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use StopInstance
            b2.use Call, GracefulHalt, :poweroff, :running do |env2, b3|
              if !env2[:result]
                b3.use ForcedHalt
              end
            end
          end
        end
      end

      # This action is called to terminate the remote machine.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, DestroyConfirm do |env, b2|
            if env[:result]
              b2.use ConfigValidate
              b.use Call, IsCreated do |env2, b3|
                if !env2[:result]
                  b3.use MessageNotCreated
                  next
                end
              end
              b2.use ProvisionerCleanup if defined?(ProvisionerCleanup)
            else
              b2.use MessageWillNotDestroy
            end
          end
        end
      end

      # This action is called when `vagrant provision` is called.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Provision
          end
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ReadSSHInfo
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ReadState
        end
      end

      # This action is called to SSH into the machine.
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHExec
          end
        end
      end

      def self.action_ssh_run
        raise "not yet implemented"
      end

      def self.action_prepare_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use Provision
          b.use SyncedFolders
          b.use SetHostname 
          # b.use SyncedFolderCleanup 
        end
      end

      # This action is called to bring the box up from nothing.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|

          #this downloads the box
          b.use HandleBox
          b.use ConfigValidate
          b.use Call, IsCreated do |env1, b1|
            if env1[:result]
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result]
                  b2.use action_prepare_boot
                  b2.use RunInstance # launch a new instance
                else
                  b2.use MessageAlreadyCreated # TODO write a better message
                end
              end
            else
              b1.use action_prepare_boot
              b1.use RunInstance # launch a new instance
            end
          end
        end
      end

      def self.action_reload
        env[:ui].info "not implemented. do vagrant halt; vagrant up manually"
      end

      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :IsCreated, action_root.join("is_created")
      autoload :IsStopped, action_root.join("is_stopped")
      autoload :MessageNotCreated, action_root.join("message_not_created")
      autoload :ReadSSHInfo, action_root.join("read_ssh_info")
      autoload :ReadState, action_root.join("read_state")
      autoload :RunInstance, action_root.join("run_instance")
      autoload :StopInstance, action_root.join("stop_instance")
    end
  end
end
