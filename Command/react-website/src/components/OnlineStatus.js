import React from 'react';
import onlinestatus_raw from '../onlinestatus.txt';

export const OnlineStatus = ({file}) => {
    var status;
    fetch(file)
        .then(r => r.text())
        .then(text => {
            status = text;
        })
    return (
        <div>Connection status: {status}</div>
    )
}