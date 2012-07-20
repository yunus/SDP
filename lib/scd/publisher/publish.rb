require 'securerandom'

module Scd

  # Takes the filename, destination address, and may be interface
  # then fragments the input filename into pieces with size MTU.
  # For each fragment a separate advertisement message has been sent with
  # sequence number.
  module Publisher
    def self.pub_file(filename,destination_address,type_class = Scd::ICMPv6::Advertisement,mtu=1500)
      pub(destination_address,type_class,mtu) do
        begin
          f= File.open(filename, 'r')
        rescue IOError,Errno::ENOENT => err
          Log.error "File could not be sent, #{err.inspect}"
          return 
        end
        f
      end
    end

    def self.pub_message(message,destination_address,type_class = Scd::ICMPv6::Advertisement,mtu=1500)
      pub(destination_address,type_class,mtu,StringIO.new(message))
    end


   # Accepts an IO object. Or send a block which returns the io object
    def self.pub(destination_address,type_class = Scd::ICMPv6::Advertisement,mtu=1500,io = nil)
      #TODO: discover the real header size and decrease it in here. 
      # wireshark tells that it is 66 byte
      mtu -= 100
      io = yield if block_given?

      number_of_packets = (io.size / Float(mtu)).ceil
      Log.debug " Number of packets:#{number_of_packets}"
      i = 0
      icmpv6_socket = type_class.new(destination_address)
      #ID field to distinguish the packets
      nonce = SecureRandom.random_number(10000)
      while buffer = io.read(mtu)
        i+=1
        # icmpv6 packet is generated
        icmpv6_socket.build(buffer) do |adv|
      
          adv.sequence = i
          adv.total = number_of_packets
          adv.id = nonce
          #adv.add_option(Scd::ICMPv6::NONCE_TYPE,nonce)
        end
        icmpv6_socket.publish!
      end
      icmpv6_socket.destroy

      

    end
  end
end