module Sunspot
  module Mock
    class Server < Sunspot::Solr::Server

      #
      # Directory in which to store PID files
      #
      def pid_dir
        configuration.pid_dir || File.join(Dir.pwd, 'tmp', 'pids')
      end

      #
      # Name of the PID file
      #
      def pid_file
        "sunspot-solr-#{ENV['RACK_ENV']}.pid"
      end

      #
      # Directory to use for Solr home.
      #
      def solr_home
        File.join(configuration.solr_home)
      end

      #
      # Solr start jar
      #
      def solr_executable
        configuration.solr_executable || super
      end

      #
      # Address on which to run Solr
      #
      def bind_address
        configuration.bind_address
      end

      #
      # Port on which to run Solr
      #
      def port
        configuration.port
      end

      def log_level
        configuration.log_level
      end

      #
      # Log file for Solr. File is in the log/ directory.
      #
      def log_file
        File.join(Dir.pwd, 'log', "sunspot-solr-#{ENV['RACK_ENV']}.log")
      end

      #
      # Java heap size for Solr
      #
      def memory
        configuration.memory
      end

      def url        
         builder = configuration.scheme == 'http' ? URI::HTTP : URI::HTTPS
         builder.build(
          :host => configuration.hostname,
          :port => configuration.port,
          :path => configuration.path,
          :userinfo => configuration.userinfo
        ).to_s
      end


      private

      #
      # access to the Sunspot::Mock::Configuration, defined in
      # sunspot.yml. Use Sunspot::Mock.configuration if you want
      # to access the configuration directly.
      #
      # ==== returns
      #
      # Sunspot::Mock::Configuration:: configuration
      #
      def configuration
        @configuration ||= Sunspot::Mock::Configuration.new
      end
    end
  end
end
