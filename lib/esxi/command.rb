require "vagrant"

module VagrantPlugins
  module ESXi
    class Command < Vagrant.plugin("2", :command)

      include SSHHelper

      def initialize(app, env)
          @app = app
      end

      def self.synopsis
        'finds IP address of current VM'
      end

      def execute(env)
        env[:machine_ssh_info] = get_ssh_info(env[:esxi_connection], env[:machine])

        @app.call env
      end

      private

      def get_ssh_info(connection, machine)

        config = machine.provider_config

        o, s = Open3.capture2("ssh #{config.user}@#{config.host} vim-cmd vmsvc/get.guest '[#{config.dstds}]\\ #{config.name}/#{machine.config.vm.box}.vmx'")
        m = /^   ipAddress = "(.*?)"/m.match(o)
        return nil if m.nil?

        return {
          :host => m[1],
          :port => 22
        }
      end

    end # Command
  end # Exec
end # VagrantPlugins