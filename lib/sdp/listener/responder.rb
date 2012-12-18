
require 'linkeddata'
require 'sparql'

module Sdp
  module Responder
    # This method should make the necessary inference and query, then should
    # return the result with a unicast message to the destination.
    def self.solicitation(packet,address, service_description_file,mtu=1500)
      Log.info "INCOMING SOLICITATION MESSAGE from #{address}"
      now = Time.now
      solicitation_packet =  Racket::L4::ICMPv6CapabilitySolicitation.new packet
      raise "solicitation packet should be just one package." if solicitation_packet.total > 1
      
      tlvs = Sdp::Cacher::Dispatcher.get_tlvs(solicitation_packet.get_options)
      Log.debug "Solicitation tlvs: #{tlvs.inspect}"
      
      
      #Log.debug "Solicitation packet carries: \n#{solicitation_packet.payload}"
      parser = SPARQL.parse(solicitation_packet.payload)
      samsung_graph = RDF::Graph.load(service_description_file, :format=> :n3)

      result = parser.execute samsung_graph

       #TODO: Some inference will go in here
       Sdp::Publisher.pub_message(result.to_s, address, Sdp::ICMPv6::Advertisement, mtu,0,tlvs)
      Log.info "REPLY to SOLICITATION MESSAGE from #{address}, took #{(Time.now() - now) * 1000.0} ms"

    end
  end
end
