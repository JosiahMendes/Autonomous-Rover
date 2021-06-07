import React from 'react';
import './Battery.css';

export const Battery = ({children, value}) => {
    const battery_number = parseInt(value, 10);
    var batteryLevel = 'unknown';
    switch(Math.ceil(battery_number/10)*10) {
        case 0:
            batteryLevel = 'zero';
            break
        case 10:
            batteryLevel = 'ten';
            break
        case 20:
            batteryLevel = 'twenty';
            break
        case 30:
            batteryLevel = 'thirty';
            break
        case 40:
            batteryLevel = 'fourty';
            break
        case 50:
            batteryLevel = 'fifty';
            break
        case 60:
            batteryLevel = 'sixty';
            break
        case 70:
            batteryLevel = 'seventy';
            break
        case 80:
            batteryLevel = 'eighty';
            break
        case 90:
            batteryLevel = 'ninety';
            break
        case 100:
            batteryLevel = 'hundred';
            break
        default:
            batteryLevel = 'unknown';
    }
    return (
        <>
            <nav className='batteryform'>
                <div className='battery-container'>
                    <div className='status'>
                        <div className='statusinfo'>
                            <div className={`battery ${batteryLevel}`}></div>
                            <div className='batteryValue'>
                                Battery: {children}%
                            </div>
                        </div>
                    </div>
                </div>
            </nav>
        </>
    )
}