require 'securerandom'

module Scd

  # Takes the filename, destination address, and may be interface
  # then fragments the input filename into pieces with size MTU.
  # For each fragment a separate advertisement message has been sent with
  # sequence number.
  module Publisher
    def self.pub_file(filename,destination_address,type_class = Scd::ICMPv6::Advertisement,mtu=1500,sleep_time=0)
      pub(destination_address,type_class,mtu,sleep_time) do
        begin
          f= File.open(filename, 'r')
        rescue IOError,Errno::ENOENT => err
          Log.error "File could not be sent, #{err.inspect}"
          return 
        end
        f
      end
    end

    def self.pub_message(message,destination_address,type_class = Scd::ICMPv6::Advertisement,mtu=1500,sleep_time=0,nonce=nil)
      pub(destination_address,type_class,mtu,sleep_time,StringIO.new(message),nonce)
    end


   # Accepts an IO object. Or send a block which returns the io object
    def self.pub(destination_address,type_class = Scd::ICMPv6::Advertisement,mtu=1500,sleep_time=0,io = nil,nonce=nil)
      #TODO: discover the real header size and decrease it in here. 
      # wireshark tells that it is 66 byte
      mtu -= 100
      io = yield if block_given?

      number_of_packets = (io.size / Float(mtu)).ceil
      Log.debug " Number of packets:#{number_of_packets}"
      i = 0
      icmpv6_socket = type_class.new(destination_address)
      #ID field to distinguish the packets
      nonce ||= SecureRandom.random_number(10000)
      Log.info "Sending packet  id: #{nonce} start: #{Time.now().strftime("%M:%S:%L")}"
      while buffer = io.read(mtu)
        i+=1
        # icmpv6 packet is generated
        icmpv6_socket.build(buffer) do |adv|
      
          adv.sequence = i
          adv.total = number_of_packets
          #adv.id = nonce
          adv.add_option(Scd::ICMPv6::NONCE_TYPE,nonce.to_s)
        end
        icmpv6_socket.publish!
        sleep sleep_time
      end
      icmpv6_socket.destroy

      

    end
  end
end