namespace :sunspot do
  namespace :solr do
    desc 'stub: Start the Solr instance'
    task :start do
      # case RUBY_PLATFORM
      # when /w(in)?32$/, /java$/
      #   abort("This command is not supported on #{RUBY_PLATFORM}. " +
      #         "Use rake sunspot:solr:run to run Solr in the foreground.")
      # end
      # # server.start
      # puts 'Successfully started Solr ...'
    end

    desc 'stub: Run the Solr instance in the foreground'
    task :run do
      # server.run
    end

    desc 'stub: Stop the Solr instance'
    task :stop  do
      # server.stop
      # puts 'Successfully stopped Solr ...'
    end

    desc 'stub: Restart the Solr instance'
    task :restart do
      # Rake::Task['sunspot:solr:stop'].invoke if File.exist?(server.pid_path)
      # Rake::Task['sunspot:solr:start'].invoke
    end

    # for backwards compatibility
    # task :reindex, [:batch_size, :models, :silence] => :"sunspot:reindex"

    # def server
      

    #   if defined?(Sunspot::Mock::Server)
    #     Sunspot::Mock::Server.new
    #   else
    #     Sunspot::Solr::Server.new
    #   end
    # end
  end
end
