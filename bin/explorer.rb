#!/usr/bin/env ruby

require "thor"
begin
	require "sdp"
rescue LoadError => le
	puts le.message
	require_relative  '../lib/sdp'
end


class Explorer < Thor
  desc "listen MULTICAST_GROUP_ADDRESS ('ff15::114')", "Listens for the incoming SDP packets.
        Advertisement packets are cached and Solicitation packets are replied."
  method_option :profile, :required=>true, :aliases => "-p",:type => :string,
    :desc => "The absolute address of advertisement profile file of the device. It includes all the device, service and social network information"
  method_option :max_transmission_unit, :default => 1500, :type => :numeric,
    :aliases => "-n", :desc => "Depending on the interface type different MTU values are required."
  method_option :cache_path, :default => "./", :type => :string, :aliases => "-c",
    :desc => "The advertisements of the devices are cached in the given directory."
  method_option :slp_url, :default => nil, :type => :string,
    :desc => "The URL representation of the service in Service Location Protocol"
  method_option :log_file, :default => "STDOUT", :aliases => "-l",
    :desc=> "The name of the log file"
  method_option :debug, :boolean=>true,:aliases => "-d", :desc => "Log level is set to DEBUG, otherwise production mode."
  method_option :info, :boolean=>true,:aliases => "-i", :desc => "Log level is set to INFO, otherwise production mode."
  def listen(multicast_group_address)

    Sdp.const_set(:Log, Logger.new(options[:log_file] == "STDOUT" ? STDOUT : options[:log_file]) )
    log_level(options)
    
    legacy_urls =  {Sdp::Legacy::SLP_URL => options[:slp_url]}

    Sdp::Listener.listen_advertisements(multicast_group_address, 
      options[:cache_path], options[:profile],Float(options[:max_transmission_unit]), legacy_urls)
    
  end


  desc "publish MULTICAST_GROUP_ADDRESS", "sends a solicitation/advertisement message to the
        multicast group. Either a file or a message can be sent."
  method_option :file, :aliases => "-f", :type => :string,
    :desc => "Absolute file address that contains the message."
  method_option :message, :aliases => "-m", :type => :string,
    :desc => "Message to be sent. "
  method_option :solicitation, :boolean => false, :aliases => "-s",
    :desc => "Message type is set to solicitation. Otherwise advertisement is sent."
  method_option :max_transmission_unit, :default => 1500, :type => :numeric,
    :aliases => "-n", :desc => "Depending on the interface type different MTU values are required."
  method_option :slp_srvrqst, :default => nil, :type => :string,
    :desc => "SLP service type URL for the query like 'service:test' "
  method_option :log_file, :default => "STDOUT", :aliases => "-l",
    :desc=> "The name of the log file"
  method_option :debug, :boolean => true,:aliases => "-d",
    :desc => "Log level is set to DEBUG, otherwise production mode."
  method_option :info, :boolean=>true,:aliases => "-i",
    :desc => "Log level is set to INFO, otherwise production mode."
  method_option :sleep_time, :default => 0, :type => :numeric, :aliases =>"-t",
    :desc => "Waiting time in seconds between the packets of the same message."
  def publish(multicast_group_address)
    Sdp.const_set(:Log, Logger.new(options[:log_file] == "STDOUT" ? STDOUT : options[:log_file]) )
    log_level(options)

    type_class = options[:solicitation] ? Sdp::ICMPv6::Solicitation : Sdp::ICMPv6::Advertisement
    tlvs={:SLP_SRVRQST => options[:slp_srvrqst]}

    Sdp::Publisher.pub_file(options[:file], multicast_group_address, type_class,
      Float(options[:max_transmission_unit]),options[:sleep_time],tlvs)  unless options[:file].nil?
    Sdp::Publisher.pub_message(options[:message], multicast_group_address, type_class,
      Float(options[:max_transmission_unit]),options[:sleep_time],tlvs)  unless options[:message].nil?

  end

private
def log_level(options)
  if options[:debug]
      Sdp::Log.level =  Logger::DEBUG
    elsif options[:info]
      Sdp::Log.level =   Logger::INFO
    else
       Sdp::Log.level = Logger::ERROR
    end
end


end

Explorer.start
