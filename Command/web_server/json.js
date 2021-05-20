const http = require('http');

const host = 'localhost';
const port = 8000;

const requestListener = function(req, res) {
    res.setHeader("Content-Type", "application/json"); // setHeader() function adds an HTTP header to the response, two arguments: header's name and its value
    // HTTP headers are additional information that can be attached to a request or a response
    res.writeHead(200);
    res.end(`{"message": "This is a JSON response"}`);
};

const server = http.createServer(requestListener);
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});