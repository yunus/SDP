require 'securerandom'

module Scd

  # Takes the filename, destination address, and may be interface
  # then fragments the input filename into pieces with size MTU.
  # For each fragment a separate advertisement message has been sent with
  # sequence number.
  module Publisher
    def self.pub_file(filename,destination_address,type_class = Scd::ICMPv6::Advertisement)
      pub(destination_address,type_class) do
        begin
          f= File.open(filename, 'r')
        rescue IOError,Errno::ENOENT => err
          Log.error "File could not be sent, #{err.inspect}"
          return 
        end
        f
      end
    end

    def self.pub_message(message,destination_address,type_class = Scd::ICMPv6::Advertisement)
      pub(destination_address,type_class,StringIO.new(message))
    end


   # Accepts an IO object. Or send a block which returns the io object
    def self.pub(destination_address,type_class = Scd::ICMPv6::Advertisement,io = nil)
    
     
      io = yield if block_given?

      icmpv6_socket = type_class.new(destination_address)
      #ID field to distinguish the packets
      nonce = SecureRandom.random_number(10000)
      Log.info "Sending packet  start: #{Time.now().strftime("%M:%S:%L")}"
      
        # icmpv6 packet is generated
        icmpv6_socket.build(io.read(100000)) do |adv|
      
          #adv.sequence = i
          #adv.total = number_of_packets
          adv.id = nonce
          #adv.add_option(Scd::ICMPv6::NONCE_TYPE,nonce)
        end
        icmpv6_socket.publish!
      
      icmpv6_socket.destroy

      

    end
  end
end