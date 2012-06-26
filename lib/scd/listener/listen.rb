module Scd
  module Listener

    def self.listen_advertisements(multicast_address, storage_path)

      connection = Scd::ICMPv6::Advertisement.new(multicast_address, 1)
      connection.subscribe_to_address!

      dispatcher = Scd::Cacher::Dispatcher.new(storage_path)

      begin
        loop do
          message, sender_addrinfo = connection.socket.recvmsg()
          #Log.debug "message: #{message.inspect}, sender address: #{sender_addrinfo.inspect}"
          dispatcher << {:message => message,:address => sender_addrinfo.ip_address}
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