import React, {useState} from 'react';
import '../App.css';
import {Button} from './Button';
import {Textbox} from './Textbox';
import './CommandSection.css';
import {OnlineStatus} from './OnlineStatus';
import {Battery} from './Battery';

const BatteryValue = '59';

function CommandSection() {
    return (
        <div className='command-container'>
            <h1>Welcome to the Command page</h1>
            <OnlineStatus file='../onlinestatus.txt'>status</OnlineStatus>
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
                    <Textbox id='angle' name='angle' className='angle'>Angle (in degrees): </Textbox>
                    <Textbox id='distance' name='distance' className='distance'>Distance (in centimeters): </Textbox>
                    <input type='submit' value='send' className='submitbutton'></input>
                </form>
            </div>
            <div className='command-battery'>
                <Battery value={BatteryValue}>
                    {BatteryValue}
                </Battery>
            </div>
        </div>
    );
};

export default CommandSection;