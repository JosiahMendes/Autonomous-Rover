import React from 'react';
import '../../App.css';
import ViewSection from '../ViewSection';
import Socket from '../Socket';

export default function View({pixels}) {
    return (
        <>
            <ViewSection pixels={pixels}/>
        </>
    )
}