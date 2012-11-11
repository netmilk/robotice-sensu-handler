class ErrorHandler
  attr_reader :error 
  
  def initialize(err)
    @error = err
    self.handle
  end
  
  def handle
    #TODO log, notify
    debug self.error
    debug self.error.backtrace
  end
end
