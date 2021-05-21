import socket
import threading

class ServerConsole():
    
    #Initialisation for Server
    def __init__(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) #begin TCP connection
        self.addressport = ("0.0.0.0", 1800) #define server host and port
        self.buffersize = 1024 #message size (in characters) when receiving messages from client
        self.sock.bind(self.addressport) #binding TCP server to host and port
        self.sock.listen() #listening for new client connections 
        self.connection, self.port = self.sock.accept() #accepting client connection
    
    #Creating two threads: one which sends of commands, one which receives commands
    def TCPthread(self):
        t1 = threading.Thread(target=self.TCPsend)
        t2 = threading.Thread(target=self.TCPreceive)
        t1.start()
        t2.start()

    #TCPsend loop which waits for input in terminal and then sends it to client
    def TCPsend(self):
        while True:
            inputtxt = str.encode(input())
            self.connection.sendall(inputtxt)
            print ("Sent <-> " , inputtxt)

    #TCPreceive loop which collects all messages from clients and displays in terminal
    def TCPreceive(self):
        while True:
            msgfromclient = self.connection.recv(self.buffersize)
            msg = repr(msgfromclient)
            if(msg != "b\'\'"):
                print("Received <-> " ,msg)
    
    #Connect function which starts the threads
    def TCPconnect(self):
        print("Device connected from: ", self.connection)
        self.TCPthread()

if __name__ == '__main__':
    client = ServerConsole()
    client.TCPconnect()
