require 'sunspot_solr'
require "sunspot_mock/version"
require "sunspot_mock/server"
require "sunspot_mock/stub_session_proxy"
require "sunspot_mock/configuration"
require 'net/http'


module SunspotMock
class TimeOutError < StandardError; end;
  class << self

    attr_writer :solr_startup_timeout
    attr_writer :server

    def solr_startup_timeout
      @solr_startup_timeout || 15
    end

    def setup_solr
      unstub
      start_sunspot_server
    end

    def server
      @server ||= Sunspot::Mock::Server.new
    end

    def init

        config = Sunspot::Configuration.build                
        builder = server.scheme == 'http' ? URI::HTTP : URI::HTTPS
        config.solr.url = builder.build(
          :host => server.hostname,
          :port => server.port,
          :path => server.path,
          :userinfo => server.userinfo
        ).to_s
        # config.solr.read_timeout = server.read_timeout
        # config.solr.open_timeout = server.open_timeout
        # config.solr.proxy = server.proxy
        # config.solr.url = server.hostname

        puts "server  -> #{server.to_s}"
        puts "config.solr.url  -> #{config.solr.url}"

        puts "PRE Sunspot.Session -> #{Sunspot.session.to_s}"
        Sunspot.session =  Sunspot::SessionProxy::ThreadLocalSessionProxy.new(config)
        puts "POST Sunspot.Session -> #{Sunspot.session.to_s}"

    end

    def start_sunspot_server
      
      puts "solr_running? -> #{solr_running?}"
      unless solr_running?
      
        # puts "Starting solr instance for #{ENV['RACK_ENV']} environment..."
        pid = fork do      
          $stderr.reopen("/dev/null", "w")
          $stdout.reopen("/dev/null", "w")
          server.run
        end

        puts "pid  -> #{pid}"

        init
        
        at_exit do 

          Process.kill("TERM", pid)          
        #   if File.exist?(server.solr_home) and server.port
			       stop_solr_command = "solr stop -p #{server.port}"
        #   	 log_file = "./#{ENV['RACK_ENV']}/data/tlog/sunspot_mock.log"
		  	   #   FileUtils.cd( server.solr_home )  { exec ("#{stop_solr_command} >> #{log_file}") }
          FileUtils.cd( server.solr_home )  { exec ("#{stop_solr_command}") }
		  	   #   # TODO :should we remove the bootstrapped solr folder
		  	   #   # exec ("rm -rf #{server.solr_home}") if File.exist?(server.solr_home) 
		      # end

        end

        wait_until_solr_starts 
         
      end
    end

    # Stubs Sunspot calls to Solr server
    def stub
      unless @session_stubbed
        Sunspot.session = Sunspot::Mock::StubSessionProxy.new(original_sunspot_session)
        @session_stubbed = true
      end
    end

    # Resets Sunspot to call Solr server, opposite of stub
    def unstub
      if @session_stubbed
        Sunspot.session = original_sunspot_session
        @session_stubbed = false
      end
    end

    private

    def original_sunspot_session
      @original_sunspot_session ||= Sunspot.session
    end

    def wait_until_solr_starts
      (solr_startup_timeout * 10).times do
        break if solr_running?
        sleep(0.1)
      end
      raise TimeOutError, "Solr failed to start after #{solr_startup_timeout} seconds" unless solr_running?
      sleep(2) # wait a bit untill the server starts up
    end

    def solr_running?
      begin
        puts "Solr Url -> #{Sunspot.session.config.solr.url}"
        solr_ping_uri = URI.parse("#{Sunspot.session.config.solr.url}/ping")
        Net::HTTP.get(solr_ping_uri)
        true # Solr Running
      rescue
        false # Solr Not Running
      end
    end
  end
end
