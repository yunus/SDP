module Scd
  module Responder
    # This method should make the necessary inference and query, then should
    # return the result with a unicast message to the destination.
    def self.solicitation(packet,address,mtu=1500)
      solicitation_packet =  Racket::L4::ICMPv6CapabilitySolicitation.new packet
       #TODO: Some inference will go in here
      Scd::Publisher.pub_message("This is an solicitation reply message", address, Scd::ICMPv6::Solicitation, mtu)


    end
  end
end