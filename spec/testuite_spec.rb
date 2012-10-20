require File.join(File.dirname(__FILE__),'spec_helper.rb')

describe "Virtualmster sensu handler testsuite" do 
  describe "#config_files inherited from Sensu:Handler" do 
    subject{VirtualmasterHandler.new.config_files.first}

    it "should return array with test config file path" do
       subject{VirtualmasterHandler.new.config_files.first}
       subject.should include("virtualmaster.json")
    end
  end
  
  describe "#settings" do
    subject {VirtualmasterHandler.new.settings}
    it {subject.keys.should include("virtualmaster")}
    it "contains global config" do 
      subject.keys.should include("api")
    end
  end
end
