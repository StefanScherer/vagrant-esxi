module VagrantPlugins
  module ESXi
    module Action
      class Suspend

        def initialize(app, env)
          @app = app
        end

        def call(env)

          config = env[:machine].provider_config

          env[:ui].info I18n.t("vagrant_esxi.suspending")
          system("ssh #{config.user}@#{config.host} vim-cmd vmsvc/power.suspend '[#{config.dstds}]\\ #{config.name}/#{env[:machine].config.vm.box}.vmx' > /dev/null")

          @app.call env
        end
      end
    end
  end
end
