import io from 'socket.io-client';

const socket = io.connect('http://localhost:4000', {}); //Here I setup the socket for the client to connect to port 4000 of localhost 

export default socket;
