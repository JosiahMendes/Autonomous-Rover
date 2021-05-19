const fs = require('fs'); //filesystem library used for paths etc.
const http = require('http'); // http library to intialise server
const socketIO = require('socket.io');// websocket library to send and receive data from clients
const DeepSpeech = require('deepspeech'); //Mozilla library for Speech To Text
const WavFileWriter = require('wav').FileWriter; //instantiate FileWriter function of wav library which is used for audio processing
const { v4: uuidv4 } = require('uuid'); // library to generate random character sequences(good when you want to save a big amount of files)
const mysql = require('mysql');// mysql library for database
const {spawn} = require('child_process');//library that allows to execute external programs such as python programs
const VAD = require('node-vad');//audio processing library



let DEEPSPEECH_MODEL = __dirname + '/output_graph'; // path to deepspeech model

let SILENCE_THRESHOLD = 500; // how many milliseconds of inactivity before processing the audio

const SERVER_PORT = 4000; // websocket server port

// const VAD_MODE = VAD.Mode.NORMAL;
// const VAD_MODE = VAD.Mode.LOW_BITRATE;
// const VAD_MODE = VAD.Mode.AGGRESSIVE;
const VAD_MODE = VAD.Mode.AGGRESSIVE;
const vad = new VAD(VAD_MODE);

//not important. Instantiates a Speech to Text model to be used
function createModel(modelDir) { 
	let modelPath = modelDir + '.pbmm';
	let scorerPath = 'kenlm.scorer';
	let model = new DeepSpeech.Model(modelPath);
	model.enableExternalScorer(scorerPath);
	return model;
}

//important. Accesses database to be used later.
let connection = mysql.createConnection({
    host: 'localhost', // where the database is located. in this case, this code is executed on the same machine as the database is stored so it is localhost
    user: 'root', 
    password: 'indigital123', 
    database: 'indigital'
});
/* in javascript you can run a function of an object in this case connection.connect and immediately use the output of it to do stuff like ensuring a connection with the database  using this structure: 
object.method( function(output1,output2,...){
	do stuff with the outputs based on what they are
});
*/
connection.connect(function(err) { 
	if (err) {
	  return console.error('error: ' + err.message);
	}
  
	console.log('Connected to the MySQL server.');
  });
//initialise some variables
let greekModel = createModel(DEEPSPEECH_MODEL);
let modelStream;
let start_time = 0;
let recordedChunks = 0;
let silenceStart = null;
let recordedAudioLength = 0;
let chunkslength =0;
let endTimeout = null;
let silenceBuffers = [];
let whole_data = [];
let i = 0;
let size = 0;
//not important function declarations to process microphone data. the socketid is to differentiate between different clients but I do not think we need multiple clients.
function processAudioStream(data, socketid, callback) {
       
	vad.processAudio(data, 16000).then((res) => {
		switch (res) {
			case VAD.Event.ERROR:
				console.log("VAD ERROR");
				break;
			case VAD.Event.NOISE:
				console.log("VAD NOISE");
				break;
			case VAD.Event.SILENCE:
				processSilence(data, socketid, callback);
				break;
			case VAD.Event.VOICE:
				processVoice(data, socketid);
				break;
			default:
				console.log('default', res);
				
		}
	});
	
	// timeout after 1s of inactivity
	clearTimeout(endTimeout);
	endTimeout = setTimeout(function() {
		console.log('timeout');
		resetAudioStream();
	},1000);
}

function endAudioStream(callback) {
	console.log('[end]');
	let results = intermediateDecode();
	if (results) {
		if (callback) {
			callback(results);
		}
	}
}

function resetAudioStream() {
	clearTimeout(endTimeout);
	console.log('[reset]');
	intermediateDecode(); // ignore results
	recordedChunks = 0;
	silenceStart = null;
}

function processSilence(data, socketid, callback) {
	if (recordedChunks > 0) { // recording is on
		process.stdout.write('-'); // silence detected while recording
		
		feedAudioContent(data,socketid);
		
		if (silenceStart === null) {
			silenceStart = new Date().getTime();
		}
		else {
			let now = new Date().getTime();
			if (now - silenceStart > SILENCE_THRESHOLD) {
				silenceStart = null;
				console.log('[end]');
				let results = intermediateDecode();
				if (results) {
					if (callback) {
						callback(results);
					}
				}
				
			}
		}
	}
	else {
		process.stdout.write('.'); // silence detected while not recording
		bufferSilence(data);
	}
}

function bufferSilence(data) {
	// VAD has a tendency to cut the first bit of audio data from the start of a recording
	// so keep a buffer of that first bit of audio and in addBufferedSilence() reattach it to the beginning of the recording
	silenceBuffers.push(data);
	if (silenceBuffers.length >= 4) {
		silenceBuffers.shift();
	}
}

function addBufferedSilence(data) {
	let audioBuffer;
	if (silenceBuffers.length) {
		silenceBuffers.push(data);
		let length = 0;
		silenceBuffers.forEach(function (buf) {
			length += buf.length;
		});
		audioBuffer = Buffer.concat(silenceBuffers, length);
		silenceBuffers = [];
	}
	else audioBuffer = data;
	return audioBuffer;
}

function processVoice(data, socketid) {
	silenceStart = null;
        
	if (recordedChunks === 0) {
		console.log('');
		process.stdout.write('[start]'); // recording started
		start_time = new Date();
	}
	else {
		process.stdout.write('='); // still recording
	}
	recordedChunks++;
	
	data = addBufferedSilence(data);
	feedAudioContent(data, socketid);
}

function createStream() {
	modelStream = greekModel.createStream();
	recordedChunks = 0;
	recordedAudioLength = 0;
}

function finishStream() {
	if (modelStream) {
		let start = new Date();
		let text = modelStream.finishStream();
		if (text) {
			console.log('');
			console.log('Recognized Text:', text);
			let recogTime = new Date().getTime() - start.getTime();
			return {
				text,
				recogTime,
				audioLength: Math.round(recordedAudioLength)
			};
		}
	}
	silenceBuffers = [];
	modelStream = null;
}

function intermediateDecode() {
	let results = finishStream();
	createStream();
	return results;
}


//important instantiation of websocket of the server
const app = http.createServer(function (req, res) {
	res.writeHead(200,{
		'Access-Control-Allow-Origin' : '*' 
	});
	res.write('web-microphone-websocket');
	res.end();
});

const io = socketIO(app, {});// object that handles socket requests
io.set('origins', '*:*');
/* the .on function is triggered when a client emmits a request. Each request has a string to differentiate from one another. 
For example here the function is triggered for the 'connection' request from a client which returns a unique socket object to be used for this client
*/
io.on('connection', function(socket) {
	let id;
	let outputFileStream = null;
	
	console.log('client connected'); // when the connection is triggered then we know that a client connected

	
	socket.once('disconnect', () => {
		console.log('client disconnected');
	});
	
	createStream();
	/*
	For this app I had a login page and when the user was verified I redirected him to the app page so I had an 'inside app' trigger that was emitted by the client when he is verified.
	This allowed me to know when the client is at a specific part of the page or does a specific thing
	*/
	socket.on('inside app', (user) =>{
		console.log("inside app");
		let sql = `SELECT * FROM AudioFiles`; // a string that is basically a MYSQL command that sellects * (every) row from the table AudioFiles


		/*
		using the connection object previously instantiated and by running the query with input sql and outputs error,results,fields
		I get the results object which has the structure of a json file and I emit it to the client using socket.emit which is to be used by the client to display a table of audio files
		*/
		connection.query(sql, (error, results, fields) => { 
							if (error) {
							  	return console.error(error.message);
							}
		socket.emit('list_json',(results));
		console.log(user);//debugging statement to see if I emitted to the correct user

		});
	})
	/* 
	authentication process. There is no encryption so do not judge me on that plz
	This process is triggered when the client emits an 'authentication' request which comes with a data object which has the username and password typed on the login page. 
	The client side is explained on the App.js file in src folder
	*/
	socket.on('authentication',function(data){
			let sql = `SELECT * FROM USERS WHERE username = '${data.user}' AND pass_word = '${data.pass}' `; //From the USERS table select all the entries that have the same username and password (I assume there is only 1 such entry)

			connection.query(sql, function (err, result, fields) {
				console.log(result);
				if (err) throw err;
				if(result.length > 0)//if there is a single entry on the table then the user is authenticated
					socket.emit("authenticated","true");
				else //if not then the user is not authenticated
					socket.emit("authenticated","false");
			  });
	})
	//When the user starts talking to the microphone then the client emits a stream-data request that comes with the mic data and the socketid
	socket.on('stream-data', function(data, socketid) {
		try{
			if (outputFileStream) {
				outputFileStream.write(data);
			}
			processAudioStream(data,socketid, (results) => {
				socket.emit('recognize', results);//emit the results of the Speech to Text model to the client to be displayed
			});
		}
		catch(e){
			if(e.code == "ENOENT")
				console.log("ignore error, you removed the file (stream)");
			else {
					console.log("dont ignore error" + e.code);
				}
		}
	});
	//not important. Initialise a wav file to save the mic data to be transmitted
	socket.on('initialise-stream',function(){
		try{
			id = uuidv4();
			outputFileStream  =  new WavFileWriter(`./audio/${id}.wav`, {
			   sampleRate: 16000,
			   bitDepth: 16,
			   channels: 1
			 });
		   
		}
		catch(e){
			if(e.code == "ENOENT")
				console.log("ignore error, you removed the file (stream)");
			else {
					console.log("dont ignore error" + e.code);
				}

		}
	
	});

	/*This is triggered when the client stops recording. It basically saves the wav file locally to the server and inserts useful data to the database such as text recognised and wav filename
	Here I use a python script to process the wav file and get some results back
	*/
	socket.on('stream-reset', function(user) {

		try{
			resetAudioStream();
			if (outputFileStream) {
				outputFileStream.end();
				outputFileStream = null;
				
			  }
			fs.lstatSync(`audio/${id}.wav`).isDirectory()
			fs.copyFile( `audio/${id}.wav`,`public/audio/${id}.wav`, () => { 
				outputFileStream = null;

				const python = spawn('python', ['jsonnn.py','--audio',`audio/${id}.wav`]);
				python.stderr.on('data', (data) => {

					console.log(data.toString());
				});
				python.on('close', (code) => {
					let raw_passage = fs.readFileSync(`json/audio/${id}.json`);
						let passage = JSON.parse(raw_passage);
						let sql = `INSERT INTO AudioFiles(name,transcript,users) VALUES('${id}','${JSON.stringify(passage)}','${user}')` ;

						connection.query(sql);
						sql = `SELECT * FROM AudioFiles`;
						connection.query(sql, (error, results, fields) => {
							if (error) {
							  return console.error(error.message);
							}
							socket.emit('list_json',(results));
					console.log(`child process close all stdio with code ${code}`);
					
				});
						console.log("\nFile Renamed!\n"); 
						socket.emit("server_finished");//emit to the client when the server has finished executing yhr python script. Useful so that the client may know when data is ready to be accessed
						  });
						
					
					});
				
				}catch(e){
				// Handle error
				if(e.code == 'ENOENT'){
					console.log("ignore error, you removed the file");
				}else {
					console.log("dont ignore error" + e.code);
				}
			}
		
	  });

	socket.on('rate', function(rate) {
		console.log(rate);
	});
	//request some data from the database. Specifically this is used to display the text recognised by previous recordings.
	socket.on('json_read',function(json_name){
		let sql = "SELECT transcript FROM AudioFiles WHERE name = '"+json_name+"'";
		connection.query(sql, function (err, result, fields) {
			if (err) throw err;
			console.log(result);
		    let passage = JSON.parse(result[0].transcript);
		    socket.emit('text' , passage);
		  });
		
		
	});
	//Not important. Some ffmpeg processing to cut some audio files
	socket.on('Cut Wav',function(audio_name,begin,end,audio_transcript,client_user){
		console.log('in')
		let dur = parseFloat(end) - parseFloat(begin);
		id = uuidv4();
		
		const ffmpeg = spawn('ffmpeg', [
			'-i',
			`./public/audio/${audio_name}.wav`,
			'-acodec',
			'copy',
			'-ss',
			begin,
			'-t',
			dur,
			`./public/audio/${id}.wav`
		  ], { shell: true });
		  ffmpeg.on('uncaughtException', function (data) {

			console.log(data.toString());
		});
		  ffmpeg.on('exit', (code, signal) => {
			console.log(`ffmpeg exited with code ${code} and signal ${signal}`);
			
			let sql = `INSERT INTO AudioFiles(name,transcript,users) VALUES('${id}','${JSON.stringify(audio_transcript)}','${client_user}')` ;

						connection.query(sql);
						sql = `SELECT * FROM AudioFiles`;
						connection.query(sql, (error, results, fields) => {
							if (error) {
							  return console.error(error.message);
							}
							socket.emit('list_json',(results));
						});

			
		});
	});
	
});
//important This is where we initialise to which port the websocket is working at. This must be the same port that the client is sending data otherwise the socket will never receive it
app.listen(SERVER_PORT, "0.0.0.0", () => {
	console.log('Socket server listening on:', SERVER_PORT);
});
//Not important. Some audio processing
function feedAudioContent(chunk, socketid) {
        let curr_time = new Date();
	recordedAudioLength += (chunk.length / 2) * (1 / 16000) * 1000;
	modelStream.feedAudioContent(chunk);
        if( curr_time.getTime() - start_time.getTime() > 50 )
	{
		if (modelStream) {
			let start = new Date();
			let text = modelStream.intermediateDecode();
			if (text) {
				let recogTime = new Date().getTime() - start.getTime();
				let results = {
					text,
					recogTime,
					audioLength: Math.round(recordedAudioLength)
				};
				io.to(socketid).emit('partial' , results);
				start_time = new Date();
			
			}
		}
	}
		
}
// I have uploaded the whole porject folder to see a little bit the structure of it. The other important code to see is on the src folder.
module.exports = app;
