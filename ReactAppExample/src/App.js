import React, {Component} from 'react';//import react library
import * as utils from './read-along'//use some stuff from a js project I found online
import AppBar from '@material-ui/core/AppBar';// import the AppBar from material-ui which allows to make a pretty website
import socket from './socket'//import socket, really important to ensure good comms between server and client
import Tab from '@material-ui/core/Tab';//import tab from material-ui, search it up to see how they look
import { TabPanel } from '@material-ui/lab';
import TabContext from '@material-ui/lab/TabContext';

import TabList from '@material-ui/lab/TabList';
import { makeStyles } from '@material-ui/core/styles';
import Container from '@material-ui/core/Container';
import ToggleButton from '@material-ui/lab/ToggleButton';
import ToggleButtonGroup from '@material-ui/lab/ToggleButtonGroup';
import { styled } from '@material-ui/core/styles';
import ChromeReaderModeIcon from '@material-ui/icons/ChromeReaderMode';
import EditIcon from '@material-ui/icons/Edit';
import Box from '@material-ui/core/Box';

import { DataGrid } from '@material-ui/data-grid';
import Grid from '@material-ui/core/Grid';
import { Button } from '@material-ui/core';






const columns =[ //collumn names to be used for a table
	{field: 'id', headerName: 'ID', width : 70},
	{field: 'user', headerName: 'USER', width : 140},
	{field: 'date', headerName: 'DATE', width : 200 , type: 'date'}
];


const DOWNSAMPLING_WORKER = './downsampling_worker.js';//not important 

//set how the AppBar will look like
const MyAppBar = styled(AppBar)({
	background: 'linear-gradient(45deg,  #3498db  30%, #2874a6 90%)',
	border: 0,
	borderRadius: 0,
	boxShadow: '0 3px 5px 2px rgba(255, 105, 135, .3)',
	color: 'white',
	height: 48,
	padding: '0 30px',
  });
  //set how the GroupButton will look
  const MyToggleButtonGroup = styled(ToggleButtonGroup)({
	background: ' #5dade2 ',
	border: 1000,
	borderRadius: 3,
	boxShadow: '0 3px 5px 2px rgba(255, 105, 135, .3)',
	color: 'black',
	height: 48,
	position: 'sticky',
	flexFlow: 'row',
	alignContent: 'right'
  });
/*important. Think of the website having compnents as an object with a state. The state has many variables that will allow you to know what is happening
https://reactjs.org/docs/react-component.html This is a good doc to see the strucure of a component
*/
class App extends Component {
	constructor(props) {
		super(props);
		this.state = {//These are the initial values for the state variables
			connected: true,
			recording: false,
			recordingStart: 0,
			recordingTime: 0,
			recognitionOutput: [],
			Passage: null,
			selectOptions : [],
			audio: '',
			tab_value: "0",
			tool_used: '0',
			recording_button: '0',
			activeEdit: false,
			Passagetext: null,
			firstWord: -1,
			secondWord: -1,
			first_passage: true,
			words: [],
			rows:[],
			id_name:[],
			recognition_id: 0,
			audio_name: '',
			transcript: null,
			server_finished: true
		};
	}
	
	componentDidMount() {
		
		let recognitionCount = 0;
		
		this.socket = socket;
		let count = 0;
		
		this.socket.emit('inside app',this.props.location.state.user);//if this line i executed then the user has been authenticated
		console.log(this.props.location.state.user);//This is passed from the authentication code
		
		
		this.socket.on('server_finished', ()=> {//this is triggered when the server has finished processing data and is ready to start processing again
			this.setState({server_finished: true});
		});
		this.socket.on('connect', () => {
			console.log('socket connected');
			this.setState({connected: true});
			this.socket.emit('wav');
		});
		
		this.socket.on('disconnect', () => {
			console.log('socket disconnected');
			this.setState({connected: false});
			this.stopRecording();
		});
		
		this.socket.on('recognize', (results) => {
			console.log('recognized:', results);
			//this is a way of updating the state of the compoenent
			const {recognitionOutput} = this.state; 
			results.id = recognitionCount;
			recognitionOutput[recognitionOutput.length -1] = results; //this process updates the last element of the array with the results from the server
			count = 0;
			this.setState({recognitionOutput});//update the state
			recognitionCount++;
		});
		this.socket.on('partial', (results) => { //not important
			
			const {recognitionOutput} = this.state;
			if(count === 0)
			{
				recognitionOutput.push('');
			}
			results.id = recognitionCount;
			recognitionOutput[recognitionOutput.length -1]=results;
			this.setState({recognitionOutput});
			count++;
		});
		this.socket.on('list_json',(list) =>{//this updates the rows of a table to be displayed
			
			this.setState({rows : []});
			
			for(let i = 0; i<list.length;++i)
			{
				
				var d = new Date(list[i].reg_date).toLocaleString();
				
				list[i].reg_date = d;
			}
			this.setState({id_name: list.map(item => ({
				id: item.id, name: item.name
			}))});
			console.log(list);
			this.setState({rows: list.map(item => (
				{
				id : item.id, 
				user: item.users, 
				date: item.reg_date
			}))});
			
			console.log(this.state.rows);
			console.log(this.state.id_name);
		});
		this.socket.on('text', (text)=>{
			var {Passage} = this.state;
			
			Passage  = text.map((item) => 
				
			<span key={item.id} data-begin={item.begin} data-dur={item.dur}  data-index={item.id}>{item.word} </span> 
		
			 );
			this.setState({Passage});
			this.setState({Passagetext: document.getElementById('passage-text')});
			let word_els= this.state.Passagetext.querySelectorAll('[data-begin]');
			this.setState({words:Array.prototype.map.call(word_els, function (word_el, index) {
				var word = {
					'begin': parseFloat(word_el.dataset.begin),
					'dur': parseFloat(word_el.dataset.dur),
					'element': word_el
				};
				word_el.tabIndex = 0; // to make it focusable/interactive
				word.index = index;
				word.end = word.begin + word.dur;
				word_el.dataset.index = word.index;
				return word;
			})});
			this.setState({firstWord:-1,secondWord:this.state.words.length});
			this.setState({transcript: text});
			if(this.state.first_passage)
			{
				this.addEventListeners();
				this.setState({first_passage: false});
			}
			if(this.state.tool_used == '0')
			{
				this.initialiseReadAlong();
			}
			else
			{
				this.initialiseCut();
			}
			this.setState({audio: this.state.audio}, function() {
				this.refs.audio.load();
			});
			
		});
	}
	//this function is continuously run and it is the one that renders the page
	render() {
		
		return (
			
				<Container maxWidth="xl">
				<div  className="App">
					<meta http-equiv="Content-Type" content="text/html; charset=utf-8"></meta>
					{this.renderTabs()}
					
				</div>
				</Container>
			
			
	);
	}
	/*This is the syntax for multiple components to be displayed. It will be different based on what stuff you use (buttons,tables, video) and it is a mix of HTML and Javascript.
	Any javascript is between {}
	look at the onChange and onClick functions which are in charge of what happens when you change tabs or click buttons
	*/
	renderTabs(){
		return(
			<TabContext value={this.state.tab_value}>
				<MyAppBar position = "relative" >
				<TabList onChange={this.handleChange_tab.bind(this)} aria-label="simple tabs example"> 
					<Tab label="Real Time Recording" value="0" />
					<Tab label="Audio File Edit" value="1"  />
				</TabList>
				</MyAppBar>
				<TabPanel value="0">
				<div>
					<MyToggleButtonGroup
						value={this.state.recording_button}
						exclusive
						onChange={this.handleRecordingButton.bind(this)}
						aria-label="text alignment"
					>
						
						<ToggleButton value="0" onClick={this.startRecording} disabled={!this.state.connected || this.state.recording || !this.state.server_finished } >
							Start Recording
						</ToggleButton>
						
						<ToggleButton value="1" onClick={this.stopRecording}  disabled={!this.state.recording} >
							Stop Recording
						</ToggleButton>
					</MyToggleButtonGroup>
					
					
					{this.renderTime()}
					{this.renderRecognitionOutput()}
				</div>
				</TabPanel>
				<TabPanel value="1">	
				<div>
				
					<Grid container spacing = {2}  direction={'column'} >
						<Grid container item xs spacing = {1} direction={'row'}>
						<Grid item xs>
						<MyToggleButtonGroup
							value={this.state.tool_used}
							exclusive
							onChange={this.handleToolButton.bind(this)}
							aria-label="text alignment"
						>
							
							<ToggleButton value="0" onClick={this.initialiseReadAlong.bind(this)}  >
								<ChromeReaderModeIcon/>
							</ToggleButton>
							
							<ToggleButton value="1" onClick={this.initialiseCut.bind(this)}   >
								<EditIcon/>
							</ToggleButton>
							

						</MyToggleButtonGroup>
						</Grid>
						<Grid item xs>
						
						
						</Grid>
						</Grid>
						<Grid container item xs spacing = {3}>
						<Grid item xs={12}>
							<div style={{ height: 400, width: '100%' }}>
								<DataGrid  rows={this.state.rows} columns={columns} pageSize={5} onRowClick = {this.rowHandle.bind(this)} />
							</div>
							</Grid>
							<Grid item xs={12}>
							<div>
							
							{this.renderAudio()}
		
							<p class="passage-audio-unavailable" hidden>
								<em class="error"><strong>Error:</strong> You will not be able to do the read-along audio because your browser is not able to play MP3, Ogg, or WAV audio formats.</em>
							</p>
							</div>
							<div id = "passage">
							<Box  border={1} visibility={this.state.Passage==null?"hidden":"visible"}>
							<div id ='passage-text'>
								{this.state.Passage}
							</div>
							
						</Box>
						
					</div>
					<Button  variant="outlined" size="large" disabled = {!this.state.activeEdit} onClick={this.handleCut.bind(this)}> Cut</Button>
					</Grid>
						</Grid>
						</Grid>
						
					
					
					</div>
					
					
				</TabPanel>
			</TabContext>
		);
		
	}
	//All these functions are triggered based on button clicking or pressing a row in a table. I would not focus so much on the content of the functions but rather look at the syntax and data flow
	handleCut()
	{
		
		if(this.state.secondWord<this.state.words.length)
		{
			let initial_time = this.state.transcript[this.state.firstWord].begin; 
			let cut_transcript = [];
			let count = 0;
			for(let i =this.state.firstWord; i<=this.state.secondWord ;++i)
			{
				cut_transcript.push(this.state.transcript[i]);
				cut_transcript[count].begin = cut_transcript[count].begin - initial_time;
				count++;
			}
			
			socket.emit('Cut Wav',this.state.audio_name,this.state.words[this.state.firstWord].begin,this.state.words[this.state.secondWord].begin+this.state.words[this.state.secondWord].dur + 0.2,cut_transcript,this.props.location.state.user);
		}
	}
	rowHandle(table,e)
	{
		let selected_name = this.state.id_name.find(item => {
			return item.id === table.row.id;
		}) 
		console.log(selected_name);
		this.setState({audio_name: selected_name.name});
		let audio_temp ='audio/'+ selected_name.name + '.wav';
		this.setState({audio: audio_temp}, function() {
			this.refs.audio.load();
		});
		this.socket.emit("json_read",selected_name.name);
	}
	initialiseCut()
	{
		document.body.classList.remove('initialized');
		utils.ReadAlong.setActive(false);
		console.log(this.state.activeEdit);
		this.setState({activeEdit: true});
		this.removeWordSelection();
		this.state.Passagetext.classList.add('initialized');
		
	}
	addEventListeners()
	{
		document.getElementById('passage-text').addEventListener('click', this.on_select_word_el.bind(this), false);
	}
	removeWordSelection(){
        // There should only be one element with .speaking, but selecting all for good measure
        var spoken_word_els = document.getElementById('passage-text').querySelectorAll('span[data-begin].speaking');
        Array.prototype.forEach.call(spoken_word_els, function (spoken_word_el) {
            spoken_word_el.classList.remove('speaking');
        });
	}
	on_select_word_el(e) {
		if(this.state.activeEdit){
		
		
		
		
		if (!e.target.dataset.begin) {
			return;
		}
		e.preventDefault();

		let i = e.target.dataset.index;
		if(this.state.firstWord === -1){
			this.setState({firstWord: i});
			this.state.words[i].element.classList.add('speaking');
			this.state.words[i].element.focus();
		}
		else if (this.state.firstWord < i && i< this.state.secondWord)
		{
			this.setState({secondWord: i});
			this.removeWordSelection();
			var j;
			for(j = this.state.firstWord; j <= i; ++j )
			{
				this.state.words[j].element.classList.add('speaking');
				this.state.words[j].element.focus();
			}
		}
		else if (i < this.state.firstWord)
		{
			this.removeWordSelection();
			this.setState({firstWord: i});
			this.state.words[i].element.classList.add('speaking');
			this.state.words[i].element.focus();
		}
		 
		 
	}
	}
	initialiseReadAlong()
	{
		this.setState({activeEdit: false});
		document.body.classList.remove('initialized');
		this.removeWordSelection();
		
			if(this.state.Passage!=null)
			{
				var args = {
					text_element: document.getElementById('passage-text'),
					audio_element: document.getElementById('passage-audio'),
					active: true,
					autofocus_current_word: true
				};
				utils.ReadAlong.init(args);
				document.body.classList.add('initialized');
			}
			
			
			
	}
	handleRecordingButton(e,newButton){
		this.setState({recording_button:newButton});
	}
	handleToolButton(e,newTool){
		this.setState({tool_used:newTool});
	}
	handleChange_tab(e, New_value){
		
		this.setState({tab_value:New_value});
		
	}
	renderTime() {
		return (<span border='3'>
			{(Math.round(this.state.recordingTime / 100) / 10).toFixed(1)}s
		</span>);
	}
	renderAudio(){
	
		if(this.state.audio === '') return;
		
		return(
				
		<audio id="passage-audio"  controls ref="audio">
			<source src={this.state.audio} type = 'audio/wav'></source>
		</audio>
		
		 )
		
	}
	renderRecognitionOutput() {
		
		return (<ul id = {this.state.recognition_id}>
			{this.state.recognitionOutput.map((r) => {
				return (<li key={r.id}>{r.text}</li>);
			})}
		</ul>)
	}
	
	createAudioProcessor(audioContext, audioSource) {
		let processor = audioContext.createScriptProcessor(4096, 1, 1);
		
		const sampleRate = audioSource.context.sampleRate;
		this.socket.emit('rate',sampleRate);
		let downsampler = new Worker(DOWNSAMPLING_WORKER);
		downsampler.postMessage({command: "init", inputSampleRate: sampleRate});
		downsampler.onmessage = (e) => {
			if (this.socket.connected) {
				this.socket.emit('stream-data', e.data.buffer , this.socket.id);
			}
		};
		
		processor.onaudioprocess = (event) => {
			var data = event.inputBuffer.getChannelData(0);
			downsampler.postMessage({command: "process", inputFrame: data});
		};
		
		processor.shutdown = () => {
			processor.disconnect();
			this.onaudioprocess = null;
		};
		
		processor.connect(audioContext.destination);
		
		return processor;
	}
	
	startRecording = e => {
		this.socket.emit("initialise-stream");
		this.setState({server_finished: false});
		if (!this.state.recording) {
			this.recordingInterval = setInterval(() => {
				let recordingTime = new Date().getTime() - this.state.recordingStart;
				this.setState({recordingTime});
			}, 100);
			
			this.setState({
				recording: true,
				recordingStart: new Date().getTime(),
				recordingTime: 0
			}, () => {
				this.startMicrophone();
			});
			
		}
	};
	
	startMicrophone() {
		this.audioContext = new AudioContext();
		
		const success = (stream) => {
			console.log('started recording');
			this.mediaStream = stream;
			this.mediaStreamSource = this.audioContext.createMediaStreamSource(stream);
			this.processor = this.createAudioProcessor(this.audioContext, this.mediaStreamSource);
			this.mediaStreamSource.connect(this.processor);
		};
		
		const fail = (e) => {
			console.error('recording failure', e);
		};
		
		if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
			navigator.mediaDevices.getUserMedia({
				video: false,
				audio: true
			})
			.then(success)
			.catch(fail);
		}
		else {
			navigator.getUserMedia({
				video: false,
				audio: true
			}, success, fail);
		}
	}
	
	stopRecording = e => {
		if (this.state.recording) {
			if (this.socket.connected) {
				this.socket.emit('stream-reset',this.props.location.state.user);
			}
			clearInterval(this.recordingInterval);
			this.setState({
				recording: false
			}, () => {
				this.stopMicrophone();
			});

		}
	};
	
	stopMicrophone() {
		if (this.mediaStream) {
			this.mediaStream.getTracks()[0].stop();
		}
		if (this.mediaStreamSource) {
			this.mediaStreamSource.disconnect();
		}
		if (this.processor) {
			this.processor.shutdown();
		}
		if (this.audioContext) {
			this.audioContext.close();
		}
	}
	handleChange(e){
		let audio_temp ='audio/'+ e.label + '.wav';
		this.setState({audio: audio_temp}, function() {
			this.refs.audio.load();
		});
		this.socket.emit("json_read",e.label);
		
	}
}
function a11yProps(index) {
  return {
    id: `simple-tab-${index}`,
    'aria-controls': `simple-tabpanel-${index}`,
  };
}
export default App;
