import React from 'react';
import '../App.css';
import {Button} from './Button';
import './CommandSection.css';

function CommandSection() {
    return (
        <div className='command-container'>
            <h1>Welcome to the Command page</h1>
            <h3>Connection status: </h3>
            <div className='command-btns'>
                <Button className='btns' buttonStyle='btn-outline' buttonSize='btn--medium'>
                    Command 1
                </Button>
                <Button className='btns' buttonStyle='btn-outline' buttonSize='btn--medium'>
                    Command 2
                </Button>
                <Button className='btns' buttonStyle='btn-outline' buttonSize='btn--medium'>
                    Command 3
                </Button>
            </div>
        </div>
    );
};

export default CommandSection;