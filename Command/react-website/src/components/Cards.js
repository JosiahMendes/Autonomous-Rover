import React from 'react';
import CardItem from './CardItem';
import './Cards.css';

function Cards() {
    return (
        <div className='cards'>
            <h1>Check out these EPIC drinks!</h1>
            <div className='cards__container'>
                <ul className='cards__items'>
                    <CardItem 
                    src='taro-milk-tea.jpeg'
                    text='Rich, creamy and undeniably delicious Taro Milk Tea with tapioca pearls'
                    label='Milk tea'
                    path='/services'
                    />
                    <CardItem 
                    src='sakura-frappuccino.jpeg'
                    text='A sakura strawberry sauce into the classic milk base'
                    label='Frappuccino'
                    path='/services'
                    />
                </ul>
            </div>
        </div>
    )
}

export default Cards;