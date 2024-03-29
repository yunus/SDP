
module Sdp
  module Cacher

    class Dispatcher

      attr_accessor :peers,:storage_path


      def initialize(storage_path)
        @storage_path = storage_path
        @peers = {}
      end

      def self.get_tlvs(options)
        inverted_types = Sdp::ICMPv6::TLV_TYPES.invert
        options.reduce({}) {|memo,opt|  memo[inverted_types[opt.first]] = opt.last if inverted_types.has_key? opt.first; memo  }
      end
      

      def <<(opts)
        opts[:message]
        opts[:address]

        adv = Racket::L4::ICMPv6CapabilityAdvertisement.new(opts[:message])
        options = adv.get_options
        #TODO: For the time being only nonce type is checked
        # we need to save legacy protocol's service definitions too
        nonce = Dispatcher.get_tlvs(options)[:NONCE_TYPE]
        
        hashid = Peer.hash(opts[:address], nonce )
        Log.debug "hash:#{hashid.inspect},   #{adv.pretty},  #{@peers.has_key?(hashid).inspect} "
        @peers.has_key?(hashid) ?
          @peers[hashid] << [adv,nonce,options] :
          @peers[hashid]= Peer.new(adv, opts[:address],nonce,options)

        if @peers[hashid].is_complete?
          sio = (@peers.delete(hashid)).flush
          File.open("#{@storage_path}/#{opts[:address]}.rdf", "w") { |i| i.write sio.string  }
        end


      end

      # Logs the rest of the peers
      def flush_all
        Log.info "******************* Dropped messages ********************"
        @peers.each do |id,p|
          Log.info "Dropped message from: #{p.address} total_size: #{p.total_size} left: #{p.counter} which: #{p.buffer.keys.sort.inspect} start: #{p.start}"
        end
      end


    end

    class Peer
      attr_accessor :nonce,:address,:total_size,:counter,:start
      attr_accessor :buffer


      def initialize(packet,sender_address,nonce,options)
        @nonce = nonce
        @address = sender_address
        @total_size = @counter = packet.total
        @options = ([] << options)
       
        @buffer = {}
        @start = Time.now
        Log.info "Incoming packet from #{pretty_print} start: #{time_print(@start)}"
        Log.debug "New peer initialized. #{pretty_print}"
        self << packet
        
      end

      def <<(packet_array)
        packet,nonce,options = packet_array
        @options << options
        

        @buffer[packet.sequence] = packet.payload
        decrement_counter
        Log.debug "Packet added to peer. #{pretty_print} - seq: #{packet.sequence}"
      end

      def hash
        self.hash(@address,@nonce)
      end

      def self.hash(address,nonce)
        "#{address}-#{nonce}".hash
      end

      def flush
        now = Time.now()
        Log.info "End of incoming packet from #{pretty_print} nonce:#{@nonce} took #{(now - @start)* 1000.0 } ms END time: #{time_print(now)}"
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
        "Address:#{@address} - nonce:#{@nonce} \n    rate: #{@counter}/#{@total_size}\n    options:  #{@options.inspect} \n"

      end

      def time_print(time)
        # print the minute of hour : second of minute : milliseconds
        time.strftime("%M:%S:%L")
      end

    end

  end
end
