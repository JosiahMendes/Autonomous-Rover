import io from 'socket.io-client';

const Socket = io.connect('http://localhost:3000', {});

export default Socket;