import React from 'react';
import '../../App.css';
import PowerSection from '../PowerSection';

export default function Power({batteryLevel}) {
    return (
        <>
            <PowerSection batteryLevel={batteryLevel}/>
        </>
    )
}