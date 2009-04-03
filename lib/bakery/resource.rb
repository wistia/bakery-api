module Bakery

  # gets info about Media from the Bakery @ unraw
  class Resource < ActiveResource::Base
    # configured by Configuration
    
    # reasonably low timeout so we don't hose our mongrels here
    self.timeout = 5
  end
  
end