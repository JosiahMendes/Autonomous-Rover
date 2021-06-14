import React from 'react';
import '../App.css';
import './ViewSection.css';
import Map from './Map';


function ViewSection({path, pos, obstacle, stage}) {
    return (
        <div className='view-container'>
            <h1>Welcome to the View page</h1>
            <div className='mapping'>
                <Map roverPath={path} pos={pos} obstacle={obstacle} stage={stage}/>
            </div>
        </div>
    );
};

export default ViewSection;