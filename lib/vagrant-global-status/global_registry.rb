require_relative 'global_environment'

module VagrantPlugins
  module GlobalStatus
    class GlobalRegistry
      def self.register(params)
        statefile = params.fetch(:home_path).join('machine-environments.json')
        new(statefile).register(
          params.fetch(:machine_name).to_s,
          params.fetch(:root_path).to_s
        )
      end

      def self.deregister(params)
        statefile = params.fetch(:home_path).join('machine-environments.json')
        new(statefile).deregister(
          params.fetch(:machine_name).to_s,
          params.fetch(:root_path).to_s
        )
      end

      def initialize(statefile)
        @statefile = statefile
        if @statefile.file?
          @current_state = JSON.parse(@statefile.read(:encoding => Encoding::UTF_8))
          fix_current_status
        else
          { 'environments' => {} }
        end
      end

      def environments
        @environments ||= @current_state['environments'].each_with_object({}) do |(env, data), hash|
          hash[env] = GlobalEnvironment.new(env, data)
        end

        @environments.values
      end

      def register(machine_name, root_path)
        @current_state['environments'][root_path] ||= { 'machines' => [] }

        global_environment = @current_state['environments'][root_path]
        machine = { 'name' => machine_name }
        unless global_environment['machines'].include?(machine)
          global_environment['machines'] << {'name' => machine_name}
        end

        write_statefile
      end

      def deregister(machine_name, root_path)
        @current_state['environments'][root_path] ||= { 'machines' => [] }

        global_environment = @current_state['environments'][root_path]
        global_environment['machines'].delete({'name' => machine_name})

        write_statefile
      end

      def fix_current_status 
        @current_state['environments'].each_with_object({}) do |(env, data), hash|
          if not File.exist? env or not File.exist? env + "/Vagrantfile" 
            @current_state['environments'].delete(env)
          end
        end
        write_statefile
      end

      private

      def write_statefile
        @statefile.open("w+") do |f|
          f.write(JSON.dump(@current_state))
        end
      end
    end
  end
end
