require "rubygems"
require_relative "sdp/version"
require "logger"
require_relative "sdp/icmpv6lib/icmpv6"
require_relative "sdp/publisher/publish"
require_relative "sdp/listener/listen"
require_relative "sdp/listener/cacher"
require_relative "sdp/listener/responder"
require_relative "sdp/legacy/legacy"

module Sdp
  Log =  Logger.new STDOUT
  
  
  # Your code goes here...
end
