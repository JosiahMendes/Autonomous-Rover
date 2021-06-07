import React from 'react';
import {Link} from 'react-router-dom';

function CardItem(props) {
    var showImage = true;
    if(props.src === 'noImage') {
        showImage = false;
    }
    return (
        <>
            <li className='cards__item'>
                <Link className='cards__item__link' to={props.path}>
                    <figure className='cards__item__pic-wrap' data-category={props.label}>
                        <div className='cards__item__img homebattery'>
                            {!(showImage) && (props.item)}
                        </div>
                        {showImage && <img src={props.src} alt='Travel' className='cards__item__img'/>}
                    </figure>
                    <div className='cards__item__info'>
                        <h5 className='cards__item__text'>{props.text}</h5>
                    </div>
                </Link>
            </li>
        </>
    )
}

export default CardItem;