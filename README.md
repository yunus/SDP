# Smart Discovery Protocol (SDP)


Smart Discovery Protocol is a service discovery protocol which carries the information of the service, the device and the owner.
The information is represented and queried in ontologies like OWL and SPARQL. 

The protocol can be considered as an addon to the Neighbor Discovery Protocol of IPv6  standard. Two new messages are defined,
Smart Solicitation and Smart Advertisement. These messages are ICMPv6 messages and they carry semantic information in their 
payloads. 

The type-length-value (TLV) options of the ICMPv6 standard are used to carry the simple URL representations of the services
in legacy standards. For the time being only TLV for SLP is added. 

This is the proof of concept implementation of the protocol in RUBY. Not in production quality.
There is no event machine integration or any other performance improvement. 
RAW sockets are used therefore require root permission. 

For SLP integration, i needed to use parsing and matching methods for SLP URLs. 
In order to show that existing APIs can be used, I have placed jSLP jar (RC3) (not uploaded) and call it as a separate process.
If you download jSLP and put it in the bin directory it works. But it was just for demonstration.





## Installation

Although I have implemented SDP  as a gem I have never tried to use it as a gem.

What I do is:

1. Download the source, git clone ...
2. use ruby >1.9.3, (advised to use RVM) other libraries including jruby does not have FULL support for ICMPv6
3. bundle install, for dependencies.
		Among the dependencies 'racket' plugin is directed to the one that I have changed. 
		You may need to create its gem file by yourself. To do that also download it (my version) run rake build.
		Then gem install LOCAL_PATH/racket/racket...gem 
4.  Well thats it you have installed it
 

## Usage

As I said I have never tried it as a gem. Instead I have created thor scripts.
Under the bin directory, you can find explorer.rb. 
If you run 'ruby bin/explorer.rb' it explains you the usage. I hope you can understand whats going on from there.

## Contributing

So what is the point of making this code open?



