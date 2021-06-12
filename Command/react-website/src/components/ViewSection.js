import React from 'react';
import '../App.css';
import './ViewSection.css';
import Map from './Map';


function ViewSection({path, pos}) {
    return (
        <div className='view-container'>
            <h1>Welcome to the View page</h1>
            <div className='mapping'>
                <Map roverPath={path} pos={pos}/>
            </div>
        </div>
    );
};

export default ViewSection;