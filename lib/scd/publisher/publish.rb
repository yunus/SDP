require 'securerandom'

module Scd

  # Takes the filename, destination address, and may be interface
  # then fragments the input filename into pieces with size MTU.
  # For each fragment a separate advertisement message has been sent with
  # sequence number.
  module Publisher
    def self.pub_file(filename,destination_address,type_class = Scd::ICMPv6::Advertisement,mtu=1500,sleep_time=0,tlvs)
      pub(destination_address,type_class,mtu,sleep_time,nil,tlvs) do
        begin
          f= File.open(filename, 'r')
        rescue IOError,Errno::ENOENT => err
          Log.error "File could not be sent, #{err.inspect}"
          return 
        end
        f
      end
    end

    def self.pub_message(message,destination_address,type_class = Scd::ICMPv6::Advertisement,mtu=1500,sleep_time=0,tlvs)
      pub(destination_address,type_class,mtu,sleep_time,StringIO.new(message),tlvs)
    end


   # Accepts an IO object. Or send a block which returns the io object
    def self.pub(destination_address,type_class = Scd::ICMPv6::Advertisement,mtu=1500,sleep_time=0,io = nil,tlvs={})
      #TODO: discover the real header size and decrease it in here. 
      # wireshark tells that it is 66 byte
      mtu -= 100
      io = yield if block_given?

      number_of_packets = (io.size / Float(mtu)).ceil
      Log.debug " Number of packets:#{number_of_packets}"
      i = 0
      icmpv6_socket = type_class.new(destination_address)
      #ID field to distinguish the packets
      nonce = tlvs[:NONCE_TYPE] || SecureRandom.random_number(10000)
      leg_url = Scd::Legacy::LegacyURLs.instance

      Log.info "Sending packet  id: #{nonce} tlvs = #{tlvs.inspect} start: #{Time.now().strftime("%M:%S:%L")}"
      
      while buffer = io.read(mtu)
        i+=1
        # icmpv6 packet is generated
        icmpv6_socket.build(buffer) do |adv|
      
          adv.sequence = i
          adv.total = number_of_packets
          #adv.id = nonce
          adv.add_option(Scd::ICMPv6::TLV_TYPES[:NONCE_TYPE],nonce.to_s)
          # Legacy support related TLVs should exist only in the first packet
          if i == 1
            # if SLP url matches the request than send whole URL as reply
            adv.add_option(Scd::ICMPv6::TLV_TYPES[:SLP_SRVRPLY],leg_url.slp_url) if 
              type_class == Scd::ICMPv6::Advertisement and leg_url.slp_enabled? and leg_url.slp_matches?(tlvs[:SLP_SRVRQST])
            adv.add_option(Scd::ICMPv6::TLV_TYPES[:SLP_SRVRQST],tlvs[:SLP_SRVRQST]) if 
              type_class == Scd::ICMPv6::Solicitation and tlvs[:SLP_SRVRQST]

          end
          
        end
        icmpv6_socket.publish!
        sleep sleep_time
      end
      icmpv6_socket.destroy

      

    end
  end
end