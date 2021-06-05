import React from 'react';
import '../../App.css';
import HeroSection from '../HeroSection';
import Cards from '../Cards';
import Socket from '../Socket';

function Home() {
    return (
        <>
            <HeroSection />
            <Cards />
        </>
    );
};

export default Home;