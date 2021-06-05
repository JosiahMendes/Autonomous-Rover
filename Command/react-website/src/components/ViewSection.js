import React, {useEffect, useState} from 'react';
import '../App.css';
import './ViewSection.css';
import Canvas from './Canvas';
import Map from './Map';

const canvasWidth = 90;
const canvasHeight = 50;

function ViewSection({pixels}) {
    return (
        <div className='view-container'>
            <h1>Welcome to the View page!</h1>
            <div className='mapping'>
                <Map />
            </div>
        </div>
    );
};

export default ViewSection;