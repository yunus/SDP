#!/usr/bin/env ruby

require "thor"
require_relative  '../lib/scd'

class Server < Thor
  desc "listen MULTICAST_GROUP_ADDRESS", "Listens for the incoming SCD packets. Advertisement packets are cached and Solicitation packets are replied."
  method_option :profile, :required=>true, :aliases => "-p",:type => :string,
    :desc => "The advertisement profile file of the device. It includes all the device, service and social network information"
  method_option :max_transmission_unit, :default => 1500, :type => :numeric,
    :aliases => "-m", :desc => "Depending on the interface type different MTU values are required."
  method_option :cache_path, :default => "./", :type => :string, :aliases => "-c",
    :desc => "The advertisements of the devices are cached in the given directory."
  method_option :log_file, :default => "STDOUT", :aliases => "-l",
    :desc=> "The name of the log file"
  method_option :debug, :boolean=>true,:aliases => "-d", :desc => "Log level is set to debug, otherwise production mode."
  def listen(multicast_group_address)

    Scd.const_set(:Log, Logger.new(options[:log_file] == "STDOUT" ? STDOUT : options[:log_file]) )
    Scd::Log.level =  options[:debug] ? Logger::DEBUG : Logger::ERROR

    Scd::Listener.listen_advertisements(multicast_group_address, 
      options[:cache_path], options[:profile],options[:max_transmission_unit])
    
  end


end

Server.start