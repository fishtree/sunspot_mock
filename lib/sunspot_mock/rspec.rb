require 'sunspot_mock'

RSpec.configure do |c|

  # It is needed to add
  # c.add_setting :clazz

  c.before(:all) do
    SunspotMock.stub
  end
  
  c.before(:all, :solr => true) do
    SunspotMock.setup_solr
    Sunspot.remove_all! 
  end

  c.after(:all, :solr => true) do 	
    Sunspot.remove_all! 
  end

end