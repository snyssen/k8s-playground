> Source: https://www.freecodecamp.org/news/osi-model-networking-layers-explained-in-plain-english/

# Common Networking Terms
- Nodes = physical electronic device hooked up to a network, capable of sending and/or receiving information over said network.
- Links = connection between nodes
- Protocol = mutually agreed set of rules that allow communication between nodes
- Network = group of devices that want to share data
- Topology = How nodes and links are setup together
![[Pasted image 20231114135956.png]]

# What is the OSI Model ?
The OSI model consists of **7 layers**, which are a way of categorizing and grouping functionality and behavior on and of a network. They are ranked from the most tangible and most physical, to less physical but closer to the end user:
1. **P**hysical Layer
2. **D**ata Link Layer
3. **N**etwork Layer
4. **T**ransport Layer
5. **S**ession Layer
6. **P**resentation Layer
7. **A**pplication Layer
They can be remembered with: **P**lease **D**o **N**ot **T**ell (the) **S**ecret **P**assword (to) **A**nyone.

## 1. Physical Layer
This is the very physical things that permits networking: network devices, cables, how they hook up to the devices, signal types and transmission methods, etc.

Example categories: nodes hardware components (hubs, repeaters, routers, NICs, antennas, etc.), device interface mechanics (RJ45, RJ11, coax, etc.), functional and procedural logic (function of pins in connectors, sequence of events for connection), cabling protocols and specifications (Ethernet (CAT), USB, DSL, etc.), sable types (shielded/unshielded, twisted/untwisted pairs, coax, etc.), signal types (baseband/brodband), signal transmission (electrical, light, radio waves)

Layer 1 data unit: **bit** (0 or 1).
## 2. Data Link Layer
Defines how data is formatted for transmission, how much of it can flow between nodes, for how long, and what to do when errors are detected. It has three components:
- Line discipline = who should talk and for how long
- Flow control = How much data should be transmitted
- Error control - detection and correction = Layer 2 is mostly concerned with detection rather than correction though
2 Sublayers are found in layer 2:
- Media Access Control (MAC) = MAC addresses, used by switches to keep track of devices in network.
- Logical Link Control (LLC) = framing addressing and flow control => achievable speed

Layer 2 data unit: **frame**

A frame has:
- A header = MAC addresses of source and destination nodes
- A body = Bits being transmitted
- A trailer = error detection information

## 3. Network Layer
Layer used for communication between and across networks (using routers) => Not limited to nod-to-node communication (contrary to previous 2 layers). Routers use routing tables to store all addressing and routing information.

Layer 3 data unit: **data packet**

Data packets encapsulate `frames` and add an IP address information. Data being transmitted is called the payload. Layer 3 does not include any error detection or correction Layer 3 uses IP addresses for routing; IP addresses are associated with MAC addresses using the Address Resolution Protocol (ARP), which resolves MAC addresses to the node's corresponding IP address. ARP is conventionnally part of layer 2, but is also part of layer 3 since IP addresses don't exist in layer 2.

## 4. Transport Layer
Layer 4 builds upon the functions of layer 2 (line discipline, flow control and error control) to handle connections between nodes, as well as provide data packet segmentation (how data packets are broken up and sent over the network). Unlike the previous layer, layer 4 has an understanding of the whole message, not just individual data packets. This allows it to manage network congestion by not sending all the packets at once.

Layer 4 data unit: **packet** for TCP, **datagram** for UDP

TCP is connection oriented and prioritizes data quality over speed. It requires a handshake between source and destination nodes, which confirms that data was received. If  the destination does not receive all of the data, TCP asks for a retry. TCP also ensure packets order.

UDP is connectionless and prioritizes speed over data quality. Datagrams may contain sequence numbers to ensure correct order, but this is not mandatory.

TCP¨and UDP both targets specific ports on network devices. The combination of IP address + port number is called a socket.

## 5. Session Layer
Layer 5 establishes, maintains and terminates sessions between network applications (not nodes!). It requires two important concepts:
- Client/Server model
- Request/Response model
Examples of protocols on layer 5: NetBIOS, RPC, etc.

## 6. Presentation Layer
Layer 6 is responsible for data formatting (character encoding and conversions) and data encryption. The OS that hosts end-user applications is typically involved in this layer.
- Formatting methods: ASCII, EBDCIC, Unicode
- Encryption: SSL, TLS

## 7. Application Layer
Layer 7 is responsible for supporting services used by end-user applications. Many protocols arte found at this layer:
- FTP
- SSH
- SMTP
- IMAP
- DNS
- HTTP
- etc.