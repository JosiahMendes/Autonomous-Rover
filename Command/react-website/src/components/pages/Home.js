import React from 'react';
import '../../App.css';
import HeroSection from '../HeroSection';
import Cards from '../Cards';

function Home({batteryLevel}) {
    return (
        <>
            <HeroSection />
            <Cards batteryLevel={batteryLevel}/>
        </>
    );
};

export default Home;