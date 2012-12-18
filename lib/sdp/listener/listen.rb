require 'socket'

module Sdp
  module Listener

    def self.listen_advertisements(multicast_address, storage_path,own_information,mtu,legacy_urls={})

      connection = Sdp::ICMPv6::Advertisement.new(multicast_address, 1)
      connection.subscribe_to_address!

      dispatcher = Sdp::Cacher::Dispatcher.new(storage_path)

      Sdp::Legacy::LegacyURLs.instance.assign_urls legacy_urls

      
      
      begin

        # signal 2 is INT signal ctrl+c
      Signal.trap(2) do
        dispatcher.flush_all
        exit()
      end

        loop do
          message, sender_addrinfo = connection.socket.recvmsg()
         

          #Log.debug "message: #{message.inspect}, sender address: #{sender_addrinfo.inspect}"
          packet = Racket::L4::ICMPv6Generic.new message
          case packet.type
          when Racket::L4::ICMPv6Generic::ICMPv6_TYPE_CAPABILITY_SOLICITATION
            Sdp::Responder.solicitation(packet, sender_addrinfo.ip_address.split('%').first, own_information,mtu)
          when Racket::L4::ICMPv6Generic::ICMPv6_TYPE_CAPABILITY_ADVERTISEMENT
            dispatcher << {:message => message,:address => sender_addrinfo.ip_address.split('%').first}
          end          
        end
      rescue => err

        Log.debug err.to_s
        Log.error err.backtrace.join("\n")
      ensure
        connection.destroy
      end

    end

  end
end
