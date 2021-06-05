import React from 'react';
import '../../App.css';
import CommandSection from '../CommandSection';
import Socket from '../Socket';

export default function Commands({batteryLevel}) {
    return (
        <>
            <CommandSection BatLevel={batteryLevel}/>
        </>
    );
};