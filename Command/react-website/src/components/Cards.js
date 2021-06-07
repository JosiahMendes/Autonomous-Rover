import React from 'react';
import CardItem from './CardItem';
import './Cards.css';
import {Battery} from './Battery';

function Cards({batteryLevel}) {
    return (
        <div className='cards'>
            <h1>Check out what's happening!</h1>
            <div className='cards__container'>
                <ul className='cards__items'>
                    <CardItem
                    item={<Battery children={batteryLevel} value={batteryLevel}/>}
                    src='noImage'
                    text='Current power status of the rover'
                    label='Power'
                    path='/power'
                    />
                    <CardItem 
                    src='mars_nasa_map.jpeg'
                    text="A real-time map constructed through communication with the rover"
                    label='Map'
                    path='/view'
                    />
                </ul>
            </div>
        </div>
    )
}

export default Cards;