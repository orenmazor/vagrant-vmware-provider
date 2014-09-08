require "vagrant"

module VagrantPlugins
  module VMWare
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
      #-------------------------------------------------------------------
      # Internal methods.
      #-------------------------------------------------------------------

      def merge(other)
        super.tap do |result|
          raise "do we need the merge function?"
        end
      end

      def finalize!
        raise "do we need the finalize function?"
      end

      def validate(machine)
        raise "who needs errors?"
      end
    end
  end
end
