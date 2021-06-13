import React, {useState} from 'react';
import '../App.css';
import {Button} from './Button';
import './CommandSection.css';
import Socket from './Socket';
import {Link} from 'react-router-dom';

function CommandSection() {

    const [automated, setDrivingMethod] = useState(false);
    const [speed, setSpeed] = useState("regular");

    function sendAngle() {
        if(automated) {
            alert("The rover is in automated driving mode. Press 'Stop' to quit automated driving mode.");
        } else {
            if(document.getElementById('angle').value === '') {
                alert('please enter angle');
            } else {
                var enteredAngle = document.getElementById('angle').value;
                Socket.emit("Angle", enteredAngle);
                // eslint-disable-next-line
                alert('Angle sent.' + ' Angle: ' + enteredAngle + ' degrees');
            }
        }
    }

    function sendDistance() {
        if(automated) {
            alert("The rover is in automated driving mode. Press 'Stop' to quit automated driving mode.");
        } else {
            if(document.getElementById('distance').value === '') {
                alert('please enter distance');
            } else {
                var enteredDistance = document.getElementById('distance').value;
                Socket.emit("Distance", enteredDistance);
                // eslint-disable-next-line
                alert('Distance sent.' + 'Distance: ' + enteredDistance + ' mm');
            }
        }
    }

    // onClick functions
    function investigate() {
        setDrivingMethod(true);
        Socket.emit("Command", "investigate");
        alert("The rover will start investigating!");
    }
    function goback() {
        Socket.emit("Command", "back");
        alert("The rover will head back to the base.");
    }
    function stop() {
        Socket.emit("Command", "stop");
        setDrivingMethod(false);
        alert("The rover will stop investigating");
    }
    function veryfast() {
        if(speed !== "veryfast") {
            Socket.emit("Speed", "A");
            setSpeed("veryfast");
            alert("New speed: very fast");
        }
    }
    function fast() {
        if(speed !== "fast") {
            Socket.emit("Speed", "B");
            setSpeed("fast");
            alert("New speed: fast");
        }
    }
    function regular() {
        if(speed !== "regular") {
            Socket.emit("Speed", "C");
            setSpeed("regular");
            alert("New speed: regular");
        }
    }
    function slow() {
        if(speed !== "slow") {
            Socket.emit("Speed", "D");
            setSpeed("slow");
            alert("New speed: slow");
        }
    }
    function veryslow() {
        if(speed !== "veryslow") {
            Socket.emit("Speed", "E");
            setSpeed("veryslow");
            alert("New speed: very slow");
        }
    }

    return (
        <div className='command-container'>
            <h1>Welcome to the Command page</h1>
            <h4 className="automated header">Automated Driving</h4>
            <h4 className="manual header">Manual Driving</h4>
            <h4 className="speed header">Rover Speed</h4>
            <div className='command-btns'>
                <div className='investigate'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={investigate}>
                        Investigate!
                    </Button>
                </div>
                <div className='backtothebase'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={goback}>
                        Back to the base
                    </Button>
                </div>
                <div className='stop'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={stop}>
                        Stop
                    </Button>
                </div>
                <div className='viewmap'>
                    <Link to='/view'>
                        <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium'>
                            View the map
                        </Button>
                    </Link>
                </div>
                <label for='angle' name='angle' className='angleLabel'>Angle [degrees]: </label>
                <input type='number' id='angle' name='angle' className='angleBox'/>
                <label for='distance' name='distance' className='distanceLabel'>Distance [mm]: </label>
                <input type='number' id='distance' name='distance' className='distanceBox'/>
                <div className='sendAngle'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={sendAngle}>
                        Send
                    </Button>
                </div>
                <div className='sendDistance'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={sendDistance}>
                        Send
                    </Button>
                </div>
                <div className='veryfast'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={veryfast}>
                        Very fast
                    </Button>
                </div>
                <div className='fast'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={fast}>
                        Fast
                    </Button>
                </div>
                <div className='regular'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={regular}>
                        Regular
                    </Button>
                </div>
                <div className='slow'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={slow}>
                        Slow
                    </Button>
                </div>
                <div className='veryslow'>
                    <Button name="button" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium' onClick={veryslow}>
                        Very slow
                    </Button>
                </div>
            </div>
        </div>
    );
};

export default CommandSection;