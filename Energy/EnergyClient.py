import serial
import socket

class EnergyClientConsole():
    #Initialisation for Client
    def __init__(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) #begin TCP connection
        self.addressport = ("192.168.1.12", 1800) #define server host and port
        try:
            self.arduino = serial.Serial( port = '/dev/cu.usbmodem14401', baudrate = 38400) #connecting serially to arduino
        except:
            print("Please check the port")

    #TCPsend loop which waits for input in serial and then sends it to client
    def TCPsend(self):
        while True:
            inputdata = self.arduino.readline()
            self.sock.send(inputdata)
            print ("Sent <-> " , inputdata)
    
    #Connect function which starts the loop
    def TCPconnect(self):
        self.sock.connect(self.addressport)
        self.TCPsend()

if __name__ == '__main__':
    client = EnergyClientConsole()
    client.TCPconnect()