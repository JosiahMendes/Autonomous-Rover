const http = require('http');

const host = 'localhost';
const port = 8000;

const requestListener = function(req, res) {
    res.setHeader("Content-Type", "text/csv"); // indicates that a CSV file is returned
    res.setHeader("Content-Disposition", "attachment;filename=oceanpals.csv"); // tells the browser how to display the data: this CSV file is an attachment and should be downloaded. file's name is oceanpals.csv
    res.writeHead(200);
    res.end(`id,name,email\n1,Sammy Shark,shark@ocean.com`);
};

const server = http.createServer(requestListener);
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});