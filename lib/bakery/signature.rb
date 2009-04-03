# utility class to construct and validate signatures
require 'base64'

module Bakery
  class Signature
    DEFAULT_EXPIRY = 3600 # 1 hour!
    
    attr_reader :request, :secret_access_key, :options
    
    def initialize(request, secret_access_key, options = {})
      @request, @secret_access_key = request, secret_access_key
      @options = options
    end

    def self.generate_encoded_canonical(method, path, expires, url_encode = false)
      canonical_string = "#{Configuration.api_access_key}--#{method.to_s.upcase}--#{path}--#{expires}"   
      digest   = OpenSSL::Digest::Digest.new('sha1')
      b64_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, Configuration.api_access_key, canonical_string)).strip
      url_encode ? CGI.escape(b64_hmac) : b64_hmac
    end

    def signature
      @signature ||= encoded_canonical
    end

    # returns either the expiration time specified by the options or
    # the expiration time specified in the request or
    # default expiration time of 5 minutes from now
    # (in seconds since the epoch)
    def expires
      @expires ||= options[:expires] || request.parameters[:expires] || Time.now.to_i + DEFAULT_EXPIRY
      @expires.to_i
    end
    
    # validates this generated signature against what's in the request params
    def valid?
      signature == request.parameters[:signature]
    end
    
    # returns true if this signature has aleady expired
    def expired?
      Time.now.to_i > expires
    end
    
    private
    
    def canonical_string            
      "#{secret_access_key}--#{request.method.to_s.upcase}--#{request.path}--#{expires}"      
    end

    def encoded_canonical
      digest   = OpenSSL::Digest::Digest.new('sha1')
      b64_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, secret_access_key, canonical_string)).strip
      url_encode? ? CGI.escape(b64_hmac) : b64_hmac
    end
    
    def url_encode?
      !@options[:url_encode].nil?
    end
    
  end
end