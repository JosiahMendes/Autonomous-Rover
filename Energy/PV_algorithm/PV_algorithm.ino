


float max_power = 4 * 3.6 * 0.250;


if (pwm_out == 1){

  power_point(false);
  
}

//Check that there has been at least a minute since up_down = false until we start searching for higher power



void power_point(bool up_down){ //up_down == false, means we were not able to operate at given power, true means we will try to find higher power point, run with true if we are not working at full power

  if(up_down || max_power < 4.6){ //Power is limited at 4.6 W, which is the maximum rated power of the solar panels and more power than one will ever need to draw
    max_power += 0.1;  //If power point is too low, increase it by 100 mW. 
  }else{
    max_power -= 0.1; //If power point is too high, decrease it by 100 mW
  }

  if(max_power == 0){ // If the maximum power reaches 0, then we are not able to charge under the current conditions and we go to the error state
    state_num = 7;
    next_state = 7;
  }
  
}
