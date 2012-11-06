require File.join(File.dirname(__FILE__),'..','spec_helper.rb')

message = "Hip hip"

describe ErrorHandler do
  describe "instance" do 
    subject{ErrorHandler.new(message)}
    it{should respond_to(:message)}
  end

  describe "#new" do 
    it "should set :message attr" do 
      e = ErrorHandler.new(message)
      e.message.should eq(message)
    end

    it "shuold call :handle" do 
      ErrorHandler.any_instance.should_receive(:handle)
      ErrorHandler.new(message)
    end 
  end
  
  describe "#notify" do 
    it "should send loud notification"
  end
end
