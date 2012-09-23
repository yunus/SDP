require "rubygems"
require_relative "scd/version"
require "logger"
require_relative "scd/icmpv6lib/icmpv6"
require_relative "scd/publisher/publish"
require_relative "scd/listener/listen"
#require_relative "scd/listener/cacher"
require_relative "scd/listener/responder"

module Scd
  Log =  Logger.new STDOUT
  
  
  # Your code goes here...
end
