require 'socket'
require 'ipaddr'
require 'racket'

module Scd
  module ICMPv6

    class ICMPv6Generic
      attr_accessor :multicast_address
      attr_reader   :socket
      attr_reader   :packet

      def initialize(multicast_address, multicast_hops = 10)
        @multicast_address = multicast_address
        @socket = Socket.open(Socket::PF_INET6, Socket::SOCK_RAW,Socket::IPPROTO_ICMPV6)
        @socket.setsockopt(Socket::IPPROTO_IPV6,Socket::IPV6_MULTICAST_HOPS,
          [multicast_hops].pack('i'))
        Log.debug "RAW socket #{@socket.inspect} is created"
      end

      def destroy
        @socket.close()
        Log.debug "Socket #{@socket.inspect} has been closed"
      end

      def build
        raise "override build method"
      end

      def publish(icmpv6_packet)
        saddr = Socket.pack_sockaddr_in(0, @multicast_address)
        @socket.send(icmpv6_packet, 0, saddr) # Send the message
      end

      def publish!
        publish(@packet)
      end

    end

    class Advertisement < ICMPv6Generic

      def build(payload='',sequence=1,total=1)
       
        @packet = Racket::L4::ICMPv6CapabilityAdvertisement.new()
        @packet.sequence = sequence
        @packet.payload =  payload
        @packet.total = total
        #sequence and payload should be able to changed inside the caller
        yield @packet if block_given?
         
        
        # TODO: fix the source address
        @packet.fix!( Racket::L3::Misc.ipv62long("0"),
          Racket::L3::Misc.ipv62long(@multicast_address))
        Log.debug "Advertisement packet in build : #{@packet.pretty}"
        @packet
      end


      def build_and_publish(payload='',sequence=1)
        publish(build payload,sequence)
      end


      def subscribe_to_address!
        optval = IPAddr.new(@multicast_address).hton + IPAddr.new(Socket::INADDR_ANY,Socket::AF_INET6).hton
        @socket.setsockopt(Socket::IPPROTO_IPV6,Socket::IPV6_JOIN_GROUP,optval)
        #@socket.ipv6only!
      end

    end

    class Solicitation < ICMPv6Generic

      def build(payload='',sequence=1,total=1)

        @packet = Racket::L4::ICMPv6CapabilitySolicitation.new()
        @packet.sequence = sequence
        @packet.payload =  payload
        @packet.total = total
        #sequence and payload should be able to changed inside the caller
        yield @packet if block_given?


        # TODO: fix the source address
        @packet.fix!( Racket::L3::Misc.ipv62long("0"),
          Racket::L3::Misc.ipv62long(@multicast_address))
        Log.debug "Solicitation packet in build : #{@packet.pretty}"
        @packet
      end    

      def build_and_publish(payload='',sequence=1)
        publish(build payload,sequence)
      end

    
    end
  end
end