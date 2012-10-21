require File.join(File.dirname(__FILE__),'..','spec_helper.rb')

message = "Hip hip"

describe Error do
  describe "instance" do 
    subject{Error.new(message)}
    it{should respond_to(:message)}
  end

  describe "#new" do 
    it "should set :message attr" do 
      e = Error.new(message)
      e.message.should eq(message)
    end

    it "shuold call :notify" do 
      Error.any_instance.should_receive(:notify)
      Error.new(message)
    end 
  end
  
  describe "#notify" do 
    it "should send loud notification"
  end
end
