module Bakery
  
  class Derivative < Resource
    
    def self.site
      base_site = super
      base_site + "/medias/:media_id"
    end
    
  end
  
end