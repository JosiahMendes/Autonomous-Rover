const http = require('http'); // http library contains the function to create the server
// host and port that the server will be bound to
const host = 'localhost'; // special private address used to refer to the computer itself, only available to the local computer
const port = 8000; // typically used as default ports in development
// the server can be reached by visiting http://localhost:8000

// request listener: handles an incoming HTTP request and return an HTTP response
const requestListener = function(req, res) {
    res.writeHead(200); // http status code 200 means request succeeded
    res.end("Welcome to the web server!\n"); // end() function returns the argument to the client
};

const server = http.createServer(requestListener); // create a server object: this server accepts HTTP requests and passes them on to requestListener function
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
}); // listen function accepts port, host, callback function that is executed when the server begins to listen
