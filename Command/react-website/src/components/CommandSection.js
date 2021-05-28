import React, {useState} from 'react';
import '../App.css';
import {Button} from './Button';
import './CommandSection.css';

function CommandSection() {
    return (
        <div className='command-container'>
            <h1>Welcome to the Command page</h1>
            <h3>Connection status: </h3>
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
            </div>
        </div>
    );
};

export default CommandSection;