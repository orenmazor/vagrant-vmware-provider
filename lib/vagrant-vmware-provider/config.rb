require "vagrant"

module VagrantPlugins
  module VMwareProvider
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :memsize, :number_of_virtual_cpus, :vm_pc_enable, :cores_per_socket, :display_name, :guest_os

      def initialize()
      end

      def merge(other)
        super.tap do |result|
        end
      end

      def finalize!
        @memsize = system_memory / 2 unless @memsize
        @number_of_virtual_cpus = system_cores unless @number_of_virtual_cpus  
        @vm_pc_enable = "TRUE" unless @vm_pc_enable
        @cores_per_socket = system_cores unless @cores_per_socket

        true
      end

      def validate(machine)
        {"VMware Provider" => _detected_errors}
      end
      
      private
     
      def system_memory
        if windows?
          `systeminfo`[/Physical Memory: (.*)\sMB/,1].strip.gsub(/,/,'').to_i
        elsif darwin?
          `sysctl -n hw.memsize`.chomp.to_i / 1024 / 1024
        else
          `awk '/MemTotal/ { print $2 }' /proc/meminfo`.strip.to_i / 1024
        end
      end

      def system_cores
        if windows?
          `wmic cpu get NumberOfCores`.split[1].to_i
        elsif darwin?
          `sysctl -n hw.physicalcpu`.chomp.to_i
        else
          `nproc`
        end
      end
    end
  end
end
