require File.join(File.dirname(__FILE__),'..','spec_helper.rb')

error = StandardError.new

describe ErrorHandler do
  describe "instance" do 
    subject{ErrorHandler.new(error)}
    it{should respond_to(:error)}
  end

  describe "#new" do 
    it "should set :error attr" do 
      e = ErrorHandler.new(error)
      e.error.should eq(error)
    end

    it "shuold call :handle" do 
      ErrorHandler.any_instance.should_receive(:handle)
      ErrorHandler.new(error)
    end 
  end
  
  describe "#notify" do 
    it "should send loud notification"
    it "should log somewhere in GELF format"
  end
end
