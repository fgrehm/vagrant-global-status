require_relative 'global_registry'

module VagrantPlugins
  module GlobalStatus
    class Command < Vagrant.plugin("2", :command)
      def execute
        options = {}

        opts = OptionParser.new do |o|
          o.banner = "Usage: vagrant global-status [--all]"

          o.on("-a", "--all", "Displays information about all machines (instead of just the active ones)") do |f|
            options[:all] = true
          end
        end

        @argv = parse_options(opts)
        return if !@argv

        registry = GlobalRegistry.new(@env.home_path.join('machine-environments.json'))
        registry.environments.each do |env|
          status = "#{env.status(options[:all])}"
          if options[:all] == true or not status == ""
            @env.ui.info "\n#{env.path}"
            @env.ui.info status 
          end
        end

        0
      end
    end
  end
end
