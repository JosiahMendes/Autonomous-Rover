import React from 'react';
import '../App.css';
import {Button} from './Button';
import './HeroSection.css';
import {Link} from 'react-router-dom';

function HeroSection() {
    return (
        <div className='hero-container'>
            <img src="mars_surface.jpeg" alt="test logo"></img>
            <h1>MARS ROVER PROJECT</h1>
            <p>Imperial College London</p>
            <div className="hero-btns">
                <Link to='/command'>
                    <Button className='btns' buttonStyle='btn-outline' buttonSize='btn--large'>
                        GET STARTED
                    </Button>
                </Link>
            </div>
        </div>
    );
};

export default HeroSection;