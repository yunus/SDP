require "rubygems"
require "scd/version"
require "logger"
require "scd/icmpv6lib/icmpv6"
require "scd/publisher/publish"
require "scd/listener/listen"
require "scd/listener/cacher"
require "scd/listener/responder"

module Scd
  Log = Logger.new(STDOUT)
  # Your code goes here...
end
