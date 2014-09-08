require "vagrant"

module VagrantPlugins
  module VMwareProvider
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :memsize, :numvcpus, :vmpcenable, :corespersocket, :displayname, :guestos

      def initialize(region_specific=false)
        @memsize = UNSET_VALUE
        @numvcpus = UNSET_VALUE
        @vmpcenable = UNSET_VALUE
        @corespersocket = UNSET_VALUE
        @displayname = UNSET_VALUE
        @guestos = UNSET_VALUE
      end

      def merge(other)
        super.tap do |result|
        end
      end

      def finalize!
        @memsize = system_memory / 2 unless @memsize
        @numvcpus = system_cores unless @numvcpus  
        @vmpcenable = "TRUE" unless @vmpcenable
        @corespersocket = system_cores unless @corespersocket
      end

      def validate(machine)
        raise "who needs errors?"
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
