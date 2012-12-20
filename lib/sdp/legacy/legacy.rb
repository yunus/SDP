require 'singleton'


module Sdp

  # Responsible for the legacy support of the discovery
# the APIs of legacy systems are called in here.
# the simple text representations are stored in here
  module Legacy
    
  SLP_URL = :slp_url

  class LegacyURLs

    include Singleton

    attr_accessor :slp_url #dns_srv, ssdp others will be implemented

    
   # Enter the URL service definitions of the legacy systems
    def assign_urls(urls = {})
      @slp_url = urls[SLP_URL]
    end


    def slp_enabled?
      defined? @slp_url and !@slp_url.nil?
    end

    #Calls external library
    # since we are using RUBY 1.9.3 (asof december 2012)
    # we are not able to call Java directly as in jruby (still has no support for ICMPv6)
    def slp_matches?(match_string = nil)
      return false if match_string.nil? or !slp_enabled?
      

      bin = File.join(File.dirname(__FILE__),"..","..","..","bin")
      
      result = `java  -cp #{bin}/jslp-1.0.0.RC3.jar:#{bin} Match '#{@slp_url}' '#{match_string}'`
      Log.debug "SLP service url comparison with java library: #{result}"
      return true if result.casecmp('true') == 0
      return false if result.casecmp('false') == 0
      
      Log.info(" SLP URL comparison has an exception: #{result} ")
      return false



    end

  end
  end
end
