module Bakery
  
  # Configuration for using the Bakery
  # valid options include: 
  #   :api_scheme           what protocol to use when interacting with the api (http/https)
  #   :api_host             host for the api (e.g. wistia.bakery.net)
  #   :api_user             user name for accessing the api
  #   :api_password         password for accessing the api
  #   :api_access_key       api access key
  #   :http_delivery_host   where is the http content being served from (e.g. media.wistia.com)
  #   :https_delivery_host  where is the ssl content being served from (e.g. secure.media.wistia.com)
  #   :use_https_delivery   use https delivery by default? true or false
  
  class Configuration
    cattr_accessor :config
    
    def self.initialize
      self.config = {}
    end
    
    class << self
  
      def method_missing(m, *args)
        key = m.to_sym
        if valid_keys.include?(key)
          config && config[m.to_sym]
        else
          super
        end
      end
  
      def api_url_root(options = {})
        "#{options[:scheme] || api_scheme}://#{options[:host] || api_host}"
      end
      
      # returns the delivery url root based on the current configuration and
      # the supplied options
      #
      # e.g. Bakery::Configuration.delivery_url_root #=> "http://account.media.unraw.net"
      def delivery_url_root(options = {})
        https = options[:use_https_delivery] || use_https_delivery
        scheme = https ? 'https' : 'http'
        host = options[:host] || (https ? https_delivery_host : http_delivery_host)
        
        "#{scheme}://#{host}"
      end
      
      def valid_keys
        [ :api_scheme, :api_host, :api_user, :api_password, :api_access_key,
          :http_delivery_host, :https_delivery_host, :use_https_delivery ]
      end
      
      # takes a hash of options and merges them with the current settings
      def configure!(raw_options)
        options = raw_options.symbolize_keys
        options.assert_valid_keys(valid_keys)
        
        self.config.merge!(options)
        
        Resource.site = api_url_root
        Resource.site.user = URI.escape(api_user)
        Resource.site.password = URI.escape(api_password)
        
        self
      end

      # reset the config!
      def reset!
        self.config = {}
      end
      
    end
    
  end
end