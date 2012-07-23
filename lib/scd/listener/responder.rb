
require 'linkeddata'
require 'sparql'

module Scd
  module Responder
    # This method should make the necessary inference and query, then should
    # return the result with a unicast message to the destination.
    def self.solicitation(packet,address, service_description_file,mtu=1500)
      Log.info "INCOMING SOLICITATION MESSAGE from #{address}"
      now = Time.now
      solicitation_packet =  Racket::L4::ICMPv6CapabilitySolicitation.new packet
      raise "solicitation packet should be just one package." if solicitation_packet.total > 1
      parser = SPARQL.parse(solicitation_packet.payload)
      samsung_graph = RDF::Graph.load(service_description_file, :format=> :n3)

      result = parser.execute samsung_graph

       #TODO: Some inference will go in here
      Scd::Publisher.pub_message(result.to_s, address, Scd::ICMPv6::Advertisement, mtu)
      Log.info "REPLY to SOLICITATION MESSAGE from #{address}, took #{(Time.now() - now) * 1000.0} ms"

    end
  end
end