require "i18n"
require "open3"

module VagrantPlugins
  module ESXi
    module Action
      class Create

        def initialize(app, env)
          @app = app
        end

        def call(env)
          config = env[:machine].provider_config

          src = env[:machine].config.vm.box
          dst = config.name

          # Removing ability to download and ovf extract using VMWare Fusion - MAC Only
          #env[:ui].info(I18n.t("vagrant_esxi.copying"))
          #system("'/Applications/VMware Fusion.app/Contents/Library/VMware OVF Tool/ovftool' --diskMode=seSparse --name=#{src} --net:'nat=VM Network' --noSSLVerify --overwrite ~/.vagrant.d/boxes/#{src}/vmware_desktop/packer-vmware.vmx vi://#{config.user}:#{config.password}@#{config.host}") unless system("ssh #{config.user}@#{config.host} test -e /vmfs/volumes/#{config.datastore}/#{src}")

          # Instead check if a clonable VM exists on the ESXi - needs fix
          env[:ui].info(I18n.t("vagrant_esxi.checking"))
          raise Error::ESXiError, :message => "#{src} does not exist!" if system("ssh #{config.user}@#{config.host} test ! -e /vmfs/volumes/#{config.srcds}/#{src}")
 
          env[:ui].info(I18n.t("vagrant_esxi.creating"))
          raise Error::ESXiError, :message => "#{dst} exists!" if system("ssh #{config.user}@#{config.host} test -e /vmfs/volumes/#{config.dstds}/#{dst}")

          cmd = [
                 "mkdir -p /vmfs/volumes/#{config.dstds}/#{dst}",
                 # We need to filter both ISO and VMDK as the VMDK will not be copied but will be copied via vmkfstools
                 "'find /vmfs/volumes/#{config.srcds}/#{src} -type f \\! -name \\*.iso \\! -name \\*.vmdk -exec cp \\{\\} /vmfs/volumes/#{config.dstds}/#{dst}/ \\;'",
                 # Use vmkfstools to copy
                 "'find /vmfs/volumes/#{config.srcds}/#{src} -type f \\! -name \\*flat\\* -name \\*.vmdk -exec vmkfstools -i \\{\\} /vmfs/volumes/#{config.dstds}/#{dst}/#{src}.vmdk -d thin -a lsilogic \\;'",
                 "'cd /vmfs/volumes/#{config.dstds}/#{dst}'",
                 "'find /vmfs/volumes/#{config.srcds}/#{src} -type f -name \\*.iso -exec ln -s \\{\\} \\;'",
                 "mv /vmfs/volumes/#{config.dstds}/#{dst}/#{src}.vmx /vmfs/volumes/#{config.dstds}/#{dst}/#{src}.vmx.bak",
                 "grep -v -e '^uuid.location' -e '^uuid.bios' -e '^vc.uuid' /vmfs/volumes/#{config.dstds}/#{dst}/#{src}.vmx.bak '>' /vmfs/volumes/#{config.dstds}/#{dst}/#{src}.vmx",
                 "rm /vmfs/volumes/#{config.dstds}/#{dst}/#{src}.vmx.bak",
                 "chmod +x /vmfs/volumes/#{config.dstds}/#{dst}/#{src}.vmx",
                ]
          system("ssh #{config.user}@#{config.host} " + cmd.join(" '&&' "))

          env[:ui].info(I18n.t("vagrant_esxi.registering"))
          o, s = Open3.capture2("ssh #{config.user}@#{config.host} vim-cmd solo/registervm '/vmfs/volumes/#{config.dstds}/#{dst}/#{src}.vmx' #{dst}")

          env[:machine].id = "#{config.host}:#{o.chomp}"
            
          @app.call env
        end
      end
    end
  end
end
