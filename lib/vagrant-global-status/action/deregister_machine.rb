require_relative '../global_registry'

module VagrantPlugins
  module GlobalStatus
    module Action
      class DeregisterMachine
        def initialize(app, env)
          @app = app
        end

        def call(env)
          @app.call(env)
          if env[:machine].provider.state.id == :not_created
            GlobalRegistry.deregister(
              home_path:    env[:home_path],
              machine_name: env[:machine].name,
              root_path:    env[:root_path]
            )
          end
        end
      end
    end
  end
end
