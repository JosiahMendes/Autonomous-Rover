import React, {useEffect, useState} from 'react';
import '../App.css';
import {Button} from './Button';
import {Textbox} from './Textbox';
import './CommandSection.css';
import {Battery} from './Battery';
import Socket from './Socket';

function CommandSection({BatLevel}) {
    const [angle, setAngle] = useState(0);
    const [distance, setDistance] = useState(0);

    function setAngleBox() {
        setAngle(document.getElementById('angle').value);
    }

    function setDistanceBox() {
        setDistance(document.getElementById('distance').value);
    }

    function sendData() {
        Socket.emit("AngleDistance", [angle, distance]);
        alert('Data sent');
    }

    return (
        <div className='command-container'>
            <h1>Welcome to the Command page</h1>
            <div className='command-btns'>
                <form method="post" className="form">
                    <Button type="submit" name="button" value="1" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium'>
                        Command 1
                    </Button>
                    <Button type="submit" name="button" value="2" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium'>
                        Command 2
                    </Button>
                    <Button type="submit" name="button" value="3" className='btns' buttonStyle='btn-outline' buttonSize='btn--medium'>
                        Command 3
                    </Button>
                </form>
                <form method='post' className='form'>
                    <Textbox id='angle' name='angle' className='angle' onChange={setAngleBox}>Angle (in degrees): </Textbox>
                    <Textbox id='distance' name='distance' className='distance' onChange={setDistanceBox}>Distance (in centimeters): </Textbox>
                    <input id='driveData' type='button' value='send' className='submitbutton' onClick={sendData}></input>
                </form>
            </div>
            <div className='command-battery'>
                <Battery value={BatLevel}>
                    {BatLevel}
                </Battery>
            </div>
        </div>
    );
};

export default CommandSection;