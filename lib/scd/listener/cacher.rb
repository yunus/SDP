
module Scd
  module Cacher

    class Dispatcher

      attr_accessor :peers,:storage_path


      def initialize(storage_path)
        @storage_path = storage_path
        @peers = {}
      end

      def <<(opts)
        opts[:message]
        opts[:address]

        adv = Racket::L4::ICMPv6CapabilityAdvertisement.new(opts[:message])
        
        hashid = Peer.hash(opts[:address], adv.id)
        Log.debug "hash:#{hashid.inspect},   #{adv.pretty},  #{@peers.has_key?(hashid).inspect} "
        @peers.has_key?(hashid) ?
          @peers[hashid] << adv :
          @peers[hashid]= Peer.new(adv, opts[:address])

        if @peers[hashid].is_complete?
          sio = (@peers.delete(hashid)).flush
          File.open("#{@storage_path}/#{opts[:address]}.rdf", "w") { |i| i.write sio.string  }
        end


      end


    end

    class Peer
      attr_accessor :id,:address,:total_size,:counter
      attr_accessor :buffer


      def initialize(packet,sender_address)
        @id = packet.id
        @address = sender_address
        @total_size = @counter = packet.total
        @options = []
        @buffer = {}
        @start = Time.now
        Log.info "Incoming packet from #{pretty_print} start: #{time_print(@start)}"
        Log.debug "New peer initialized. #{pretty_print}"
        self << packet
        
      end

      def <<(packet)
        @options << packet.get_options
        

        @buffer[packet.sequence] = packet.payload
        decrement_counter
        Log.debug "Packet added to peer. #{pretty_print} - seq: #{packet.sequence}"
      end

      def hash
        self.hash(@address,@id)
      end

      def self.hash(address,id)
        "#{address}-#{id}".hash
      end

      def flush
        now = Time.now()
        Log.info "End of incoming packet from #{pretty_print} took #{(now - @start)* 1000.0 } ms END time: #{time_print(now)}"
        sio = StringIO.new("", 'a')
        (1..@total_size).each {|i|
          sio.write(@buffer[i])
        }
        sio.flush

      end


      def is_complete?
        @counter == 0
      end

      private
      #In case of multi-threaded app below method should be synchronized
      def decrement_counter
        @counter -= 1
      end

      def pretty_print
        "Address:#{@address} - id:#{@id} \n    rate: #{@counter}/#{@total_size}\n    options:  #{@options.inspect} \n"

      end

      def time_print(time)
        # print the minute of hour : second of minute : milliseconds
        time.strftime("%M:%S:%L")
      end

    end

  end
end