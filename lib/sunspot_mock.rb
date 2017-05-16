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
      # unstub
      init_session
      start_sunspot_server
    end

    def server
      @server ||= Sunspot::Mock::Server.new
    end

    def init_session

        config = Sunspot::Configuration.build                
        config.solr.url =  server.url
        # config.solr.read_timeout = server.read_timeout
        # config.solr.open_timeout = server.open_timeout
        # config.solr.proxy = server.proxy

        original_sunspot_session #As prevention that this is the first test (so original version will be saved for later stubs)
        Sunspot.session =  Sunspot::SessionProxy::ThreadLocalSessionProxy.new(config)
        @session_stubbed = false
    end

    def start_sunspot_server
      
      unless solr_running?
      
        pid_start = fork do      
          $stderr.reopen("/dev/null", "w")
          $stdout.reopen("/dev/null", "w")
          server.start
        end
      
        at_exit do 

          Process.kill("TERM", pid_start)      

          pid_stop = fork do      
            $stderr.reopen("/dev/null", "w")
            $stdout.reopen("/dev/null", "w")
            server.stop
          end
          sleep(3)

          Process.kill("TERM", pid_stop)      
          # TODO :should we remove the bootstrapped solr folder??
          FileUtils.rm_r( server.solr_home ) if File.exist?(server.solr_home) and server.solr_home != "/"

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
        solr_ping_uri = URI.parse("#{Sunspot.session.config.solr.url}/ping")
        Net::HTTP.get(solr_ping_uri)
        true # Solr Running
      rescue
        false # Solr Not Running
      end
    end
  end
end
