import socket
from struct import *
import struct
import os

 

class McastSocket(socket.socket):
  def __init__(self, local_port, reuse=False):
    socket.socket.__init__(self, socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
    if(reuse):
      self.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
      if hasattr(socket, "SO_REUSEPORT"):
        self.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
    self.bind(('', local_port))
  def mcast_add(self, addr, iface):
    self.setsockopt(
        socket.IPPROTO_IP,
        socket.IP_ADD_MEMBERSHIP,
        socket.inet_aton(addr) + socket.inet_aton(iface))


 
#sock = socket.socket( socket.AF_INET, # Internet
   #                    socket.SOCK_DGRAM ) # UDP
#sock.bind( (UDP_IP,UDP_PORT) )

#sock = McastSocket(local_port=4242, reuse=1)
#sock.mcast_add('224.0.0.42', '127.0.0.1')

#while True:
    #os.system("clear")
    #data, addr = sock.recvfrom( 512 ) # buffer size is 1024 bytes
    #trackingData = unpack('ddddddddddddddddddd', data)
    #print "yaw:", trackingData[16] #  unpack('hhl', data)
    #print "pitch:", trackingData[17]
    #print "roll:", trackingData[18]
    #sleep(0.01)
    #print sock.recvfrom(65565)


