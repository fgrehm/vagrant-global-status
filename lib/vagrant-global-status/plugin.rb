require "vagrant"

require_relative "version"

module VagrantPlugins
  module GlobalStatus
    class Plugin < Vagrant.plugin("2")
      name "Vagrant Global Status"
      description 'Find out the status of all of the Vagrant VMs you manage'

      # TODO: This should be generic, we don't want to hard code every single
      #       possible provider action class that Vagrant might have
      register_machine = lambda do |hook|
        require_relative "action/register_machine"
        hook.before VagrantPlugins::ProviderVirtualBox::Action::Boot, Action::RegisterMachine

        if defined?(Vagrant::LXC)
          # TODO: Require just the boot action file once its "require dependencies" are sorted out
          require 'vagrant-lxc/action'
          hook.before Vagrant::LXC::Action::Boot, Action::RegisterMachine
        end
      end
      action_hook 'register-machine-on-up',     :machine_action_up,     &register_machine
      action_hook 'register-machine-on-reload', :machine_action_reload, &register_machine

      deregister_machine = lambda do |hook|
        require_relative "action/deregister_machine"
        hook.before VagrantPlugins::ProviderVirtualBox::Action::Destroy, Action::DeregisterMachine

        if defined?(Vagrant::LXC)
          # TODO: Require just the boot action file once its "require dependencies" are sorted out
          require 'vagrant-lxc/action'
          hook.before Vagrant::LXC::Action::Destroy, Action::DeregisterMachine
        end
      end
      action_hook 'deregister-machine-on-destroy', :machine_action_destroy, &deregister_machine

      command('global-status') do
        require_relative 'command'
        Command
      end
    end
  end
end
