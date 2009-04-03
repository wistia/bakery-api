module Bakery

  class Media < Resource
  
    # A media can have one of four statuses:
    FAILED      = -1 # Failed to create, tasks failed
    QUEUED      =  0 # Queued for creation
    PROCESSING  =  1 # Currently processing
    COMPLETE    =  2 # Ready ; completed processing
    
    # find a media by its foreign id
    def self.find_by_foreign_id(fid)
      find(:first, :from => :find, :params => {:foreign_id => fid})
    end

    # find a media by its (bakery) id
    def self.find_by_id(id)
      find(id)
    end
    
    def create_derivative(options)
      Derivative.create(options.merge(:media_id => id))
    end
    
    # valid options include
    #   hashed_id
    #   format
    #   use_https_delivery
    #   host
    #   <any derivative options>
    def self.delivery_url_for(options)
      raise ArgumentError, 'Must provide hashed_id' unless hashed_id = options.delete(:hashed_id)
      format = options.delete(:format) || 'bin'
      
      https = options.delete(:use_https_delivery)
      delivery_hash = https ? { :use_https_delivery => https } : {}
      delivery_hash[:host] = options.delete(:host) if options[:host]
      
      url = Bakery::Configuration.delivery_url_root(delivery_hash) +
            "/deliveries/#{hashed_id}.#{format}"
      url << "?#{options.to_query}" unless options.empty?
      url
    end
    
    # options
    # :id
    # :format
    def self.authenticated_url_for(options)
      raise ArgumentError, 'Must provide id' unless id = options.delete(:id)
      format = options.delete(:format) || 'bin'
      
      path = "/medias/#{id}.#{format}"

      expires = options.delete(:expires) || 15.minutes.from_now.to_i
      signature = Signature.generate_encoded_canonical('GET', path, expires)

      options.merge!(
        :expires => expires,
        :signature => signature
      )
      
      "#{Bakery::Configuration.delivery_url_root}#{path}?#{options.to_query}"
    end
        
  end
    
end