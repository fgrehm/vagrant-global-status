module VagrantPlugins
  module GlobalStatus
    class GlobalEnvironment
      attr_reader :path

      RUBY_VERSION_MANAGERS = [ /\/\.rbenv\//, /\/\.rvm\// ]

      def initialize(path, data)
        @path = Pathname(path)
        @machine_names = Array(data['machines']).map{|machine| machine['name']}
        @created_at = {} 
        data['machines'].each do |machine|
          ctime = machine['created_at']
          if ctime =~ /[\d]+/
            ctime = Time.at(ctime.to_i).to_s
          end
          @created_at.store(machine['name'], ctime) 
        end
      end

      # REFACTOR: Extract a machine class
      def status(all = false)
        return "  Not found!" unless File.exists?(@path)

        matches = vagrant_status.scan(/(\w[\w-]+)\s+(\w[\w\s]+)\s+\((\w+)\)/)
        matches.map do |vm, status, provider|
          if all || (@machine_names.include?(vm) and status == "running")
            provider = "(#{provider})"
            "  #{vm.ljust(12)} #{status_line(status, 12)} #{provider.ljust(14)} #{@created_at[vm]}"
          end
        end.compact.join("\n")
      end

      def status_line(status, length)
        case status
        when "running" then
          color = 32 # green
        when "not running", "poweroff" then
          color = 33 # yellow
        when "not created" then
          color = 34 # blue
        else
          return status.ljust(length)
        end
        sprintf("\e[%dm%s\e[m", color, status.ljust(length))
      end

      def vagrant_status
        return @vagrant_status if @vagrant_status

        # Plugins development
        if defined?(::Bundler)
          if plugin_sources?
            Bundler.with_clean_env do
              @vagrant_status = run_vagrant_status
            end
          else
            Bundler.with_clean_env do
              with_clean_ruby_env(RUBY_VERSION_MANAGERS) do
                @vagrant_status = run_vagrant_status
              end
            end
          end

        # Vagrant installer
        else
          if plugin_sources?
            with_clean_vagrant_env do
              @vagrant_status = run_vagrant_status
            end
          else
            @vagrant_status = run_vagrant_status
          end
        end
      end

      ORIGINAL_ENV = ENV.to_hash
      def with_original_env
        yield
      ensure
        ENV.replace(ORIGINAL_ENV)
      end

      def with_clean_vagrant_env
        with_clean_ruby_env(/\/vagrant\//) do
          yield
        end
      end

      def with_clean_ruby_env(regex)
        with_original_env do
          Array(regex).each do |reg|
            ENV['PATH'] = remove_from_path(reg)
          end
          ENV.delete('GEM_HOME')
          ENV.delete('GEM_PATH')
          yield
        end
      end

      def remove_from_path(regex)
        ENV['PATH'].split(':').
                    reject{ |p| p =~ regex  }.
                    join(':')
      end

      def run_vagrant_status
        if File.exists?(@path)
          cmd = "cd #{@path} && "
          if plugin_sources?
            cmd << "bundle exec "
          end
          cmd << "vagrant status"
          `#{cmd}`
        else
          `echo ""`
        end
      end

      def plugin_sources?
        return @plugin_sources if defined?(@plugin_sources)

        gemfile_dir = @path
        gemfile     = gemfile_dir.join('Gemfile')

        # If the parent is the same dir, we reached the root dir
        while !gemfile.file? && gemfile_dir.parent != gemfile_dir
          gemfile_dir = gemfile_dir.parent
          gemfile     = gemfile_dir.join('Gemfile')
        end

        @plugin_sources = gemfile.file? ? gemfile.read =~ /gem\s+['"]vagrant['"]/ : false
      end
    end
  end
end
