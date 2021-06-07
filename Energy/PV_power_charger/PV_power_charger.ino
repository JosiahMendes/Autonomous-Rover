/*
 * Code used to charge 4 battery cells in series
 * 
 * Code written by Edvard J. S. Holen (edvard.holen19@imperial.ac.uk)
 * Inspired by "Battery_Charge_Cycle_Logged_V1.1" by Phil Clemow
 * 
 * Start date: 27th May 2021
 */

//Include relevant libraries
#include <Wire.h> //Used for current sensor
#include <INA219_WE.h> //Used for current sensor
#include <SPI.h> //Used for current sensor
#include <SD.h>  //Used for SD card logging

INA219_WE ina219; // this is the instantiation of the library for the current sensor

//Set up variables using the SD utility library functions:
Sd2Card card;
SdVolume volume;
SdFile root;


//Declare global variables
unsigned int loop_trigger; //variable which triggers main loop
unsigned int int_count = 0; //counts the number of loops
unsigned long cycle_count = 0; //counts how many 1 Hz cycles we have passed through since program started
unsigned long decrease_index = 0; //indicates last time power point was decreased
unsigned int cell_count = 1; //decides which cell we should measure voltage of
int num_cells = 4; //Define number of cells in circuit

int state_num = 0; //current state of state machine
int next_state; //state of state machine after next interupt

boolean input_switch; //value of CL/OL switch CL = true, OL = false

float voltage_ref = 0; //Used to set the desired voltage at the output
float current_ref = 0; //Used to set the desired current at the output
float current_sum = 0; //used to calculate the average output current in the given cycle
float ref_sum = 0; //used to calculate the average reference output current in the given cycle
float power_sum = 0; //used to calculate the average power in the given cycle

float I_out; //output current at a given time instance
float V_out; //output voltage at a given time instance
float I_bat; //current flowing through batteries
float I_in; //Input current
float I_setpoint = 0; //Value of desired current in balancing state
float V_cell[4]; //Cell voltages of each battery cell
float SOH[5]; //Array used for storing SOH data
unsigned long energy_lookup[600]; //Lookup table for how much energy is left based on SOC
float min_cell; //Mininmum cell voltage
float max_cell; //Maximum cell voltage
    
int dig_order[4] = {20, 21, 3, 9}; //Gives the digital output number for each of the rly input
int dis_order[4] = {4, 5, 8, 7}; //Gives the digital output number for each of the dis inputs

float u0i, u1i, delta_ui, e0i, e1i, e2i; // Internal values for the current controller
float ui_max = 1, ui_min = 0; //anti-windup limitation
float kpi = 0.0506, kii = 20.4, kdi = 0; // current pid gains
//float kpi = 0.02512, kii = 45, kdi = 0; // current pid gains

float Ts = 0.002; //500 Hz control frequency.
float standard_current = 250; //the output current during normal operation

float error_amps; // current control
float error_volts; //voltage control
float duty_cycle; //duty cycle of SMPS

char* dataChars; //Array of characters used for reading in data from SD card
String dataString; //string used for data logging and printing to serial
const int chipSelect = 10; //constant used for SD card


unsigned long max_power = 4.6 * 1000 * 1000; //Maximum power under current conditions [uW]


//------------- SETUP -------------//

void setup() {
  
  Wire.begin(); // We need this for the i2c comms for the current sensor
  Wire.setClock(700000); // set the comms speed for i2c
  ina219.init(); // this initiates the current sensor
  Serial.begin(38400); // USB Communications

  
  //Check for the SD Card
  Serial.println("\nInitializing SD card...");
  if (!SD.begin(chipSelect)) {
    Serial.println("* is a card inserted?");
    while (true) {} //It will stick here FOREVER if no SD is in on boot
  } else {
    Serial.println("Wiring is correct and a card is present.");
  }
  
  // Wipe the datalog when starting
  if (SD.exists("BatCharg.csv")) {
    SD.remove("BatCharg.csv");
  }
  

 //Get old SOH/SOC data
  File SOHFile = SD.open("StateOfH.csv",FILE_READ); //Open the state of health data
  dataChars = "";


  for (int i = 0; i < 5; i++){
    String entry = SOHFile.readStringUntil(',');
    SOH[i] = entry.toFloat();
    Serial.print(entry + " , ");
  }
    
  Serial.print('\n');

  //Get energy look-up table
  File EnergyFile = SD.open("EnergyLU.csv",FILE_READ); //Open the energy look-up data

  dataString = "";

  for (int i = 0; i < 600; i++){
    while(EnergyFile.available()){
      if(char(EnergyFile.peek()) != ','){
        dataString += char(EnergyFile.read());
      }else{
        EnergyFile.read();
        energy_lookup[i] = strtoul(dataString.c_str(), NULL, 10);
        Serial.print(String(energy_lookup[i]) + " , ");
        dataString = "";
        break;
      }
    }
  }

  Serial.print('\n');



  noInterrupts(); //disable all interrupts
  analogReference(EXTERNAL); // We are using an external analogue reference for the ADC

  //------------ PIN DECLARATIONS ------------// 

  //SMPS Pins
  pinMode(2, INPUT_PULLUP); // Pin 2 is the input from the CL/OL switch
  pinMode(6, OUTPUT); // This is the PWM Pin


  //Analogue measurements
  pinMode(A0, INPUT); //Measure Vpd ( = V_out/5)
  pinMode(A1, INPUT); //Measures cell voltages

  ///5V supply for op-amp
  pinMode(17, OUTPUT);
  digitalWrite(17,true);
  

  //Pins used to control battery boards
  pinMode(4, OUTPUT); //Dis cell1
  pinMode(20, OUTPUT); //Rly cell1

  pinMode(5, OUTPUT); //Dis cell2
  pinMode(21, OUTPUT); //Rly cell2

  pinMode(8, OUTPUT); //Dis cell3
  pinMode(3, OUTPUT); //Rly cell3

  pinMode(7, OUTPUT); //Dis cell4
  pinMode(9, OUTPUT); //Rly cell4

  
  //------------ TIMING ------------/

  // TimerA0 initialization for 500 Hz control-loop interrupt.
  TCA0.SINGLE.PER = 1999; //
  TCA0.SINGLE.CMP1 = 1999; //
  TCA0.SINGLE.CTRLA = TCA_SINGLE_CLKSEL_DIV16_gc | TCA_SINGLE_ENABLE_bm; //16 prescaler, 1M.
  TCA0.SINGLE.INTCTRL = TCA_SINGLE_CMP1_bm;

  // TimerB0 initialization for PWM output
  TCB0.CTRLA = TCB_CLKSEL_CLKDIV1_gc | TCB_ENABLE_bm; //62.5kHz

  interrupts();  //enable interrupts.
  analogWrite(6, 120); //just a default state to start with

}


//------------ MAIN LOOP -------------//

void loop() {
  if (loop_trigger == 1){ // FAST LOOP (500 Hz)
      
      loop_trigger = 0; //reset the trigger and move on with life
      int_count++; //count how many interrupts since last reset
      state_num = next_state; //state transition

      //Sample output and currents 
      I_in =  (ina219.getCurrent_mA()); //Measure input current [mA]
      V_out = analogRead(A0)*(4096/1023.0)*5/1.08; //Calculate output voltage [mV]
      I_out = -I_in * (1 - duty_cycle); //Calculate output current [mA]
      I_bat = I_out - float(V_out/(300*4)); //Calculate current through batteries [mA], the factor of 4 was to make observation fit with measurements
      
      
      //Check whether we should enter an error state
      check_for_errors();

      current_sum += I_bat/500; //Calculate the average battery current for the cycle
      ref_sum += current_ref/500; //Calculate the average reference current for the cycle
      power_sum += 0.001*I_bat*float(V_out/500); //Calculate the average power usage for the current cycle, only used during discharge

      //--------- PID CONTROL FOR SMPS ------------//
      
      if(state_num == 0 || state_num == 3 || state_num == 4){ //If in idle error PID is based on I_out
        error_amps = (current_ref - I_out) / 1000; //PID error calculation
        duty_cycle = pidi(error_amps); //Perform the PID controller calculation
      }else { //Otherwise is set by current through batteries
        error_amps = (current_ref - I_bat) / 1000; //PID error calculation
        duty_cycle = pidi(error_amps); //Perform the PID controller calculation
      }

      duty_cycle = saturation(duty_cycle, 0.99, 0.01); //duty_cycle saturation //Saturation is done within each pid controller so don't need to do it here as well
      analogWrite(6, (int)(duty_cycle * 255)); // write it out (non-inverting for Boost)


      switch (int_count){

        //----------- CELL VOLTAGE MEASUREMENT -----------//
        case 6:{ //Switch relay on
          digitalWrite(dig_order[cell_count - 1],true);
          break;
        }
           
        case 17:{ //Check voltage some time after relay is switched so measurement is stable
           V_cell[cell_count - 1] = analogRead(A1)*float(4096/1023)/1.012; //Get the cell voltage [mV]
           break;
        }
  
        case 18:{ //Switch relay off after measurement
          digitalWrite(dig_order[cell_count - 1],false);
          cell_count = (cell_count % 4) + 1;
          break;
        }

        case 50:{
          cycle_count++;

          if(state_num == 1 or state_num == 2){ //If we are in non-CV part of charging, do power point stuff
            if(duty_cycle == 0.99){ //Check if current power reference is too high, if so, decrease it
              power_point(false);
              reset_pid();
              decrease_index = cycle_count;
            }else if(cycle_count - decrease_index > 60){ //A minute after power point has been reduced we try to find higher power point
              power_point(true);
            }
          }

          break;
        }

        case 100:{
          if(cycle_count % 4 == 0){
            
            Serial.println(dataString); // send it to serial as well in case a computer is connected
            File dataFile = SD.open("BatCharg.csv", FILE_WRITE); // open our CSV file
            if (dataFile){ //If we succeeded (usually this fails if the SD card is out)
              dataFile.println(dataString); // print the data
            } else {
              Serial.println("File not open"); //otherwise print an error
            }
            dataFile.close(); // close the file
          }
          break;
        }

        case 200:{//Writing of SOC/SOH data is staggered from other logging to get better timing constraints

          if(cycle_count % 64 == 0 and cycle_count > 60){
            
            //Delete old SOH data:
            if (SD.exists("StateOfH.csv")) {
              SD.remove("StateOfH.csv");
            }
  
            //Write new SOH data
            File SOHFile = SD.open("StateOfH.csv", FILE_WRITE); //Open the state of health data
            
            dataString = "";
            for (int i = 0; i < 5; i++){
              dataString += String(SOH[i]);
              dataString += ",";
            }
  
            SOHFile.println(dataString); //Write new SOH data to file 
            Serial.println(dataString); //For ease, serial print the data as well
  
            SOHFile.close(); //Close the file
          }
          
          break;
        }



        case 500:{

          //Data logging
          dataString = String(state_num) +  "," + String(ref_sum) + "," + String(current_sum) + "," +String(I_out) + "," + String(I_in) + "," + String(V_out) + "," + String(V_cell[0]) + "," + String(V_cell[1]) + "," + String(V_cell[2]) + "," + String(V_cell[3]) + "," + String(max_power) + "," + String(duty_cycle); //build a datastring for the CSV file
          //Calculate new SOH and SOC data
          SOH[0] += current_sum; //How much capacity we have used so far
          //SOH[1] = SOH[1] //If we need to change number of cycles, it is not done here, so don't change it
          //SOH[2] = SOH[2] //If we need to change current capacity, it is not done here, so don't change it
          //SOH[3] = SOH[3] //Initial capacity is a constant so don't change it
          SOH[4] -= power_sum; //How much energy has been used so far




          //---------- STATE MACHINE -----------//

          int_count = 0; // reset the interrupt count so we dont come back here for 1000ms
          input_switch = digitalRead(2); //get the OL/CL switch status
    
    
          //This can be done on different int_count value
          //Find max and min cell voltage
          min_cell = V_cell[0]; //Mininmum cell voltage
          max_cell = V_cell[0]; //Maximum cell voltage
        
          //Find lowest and highest cell voltage
          for (int i = 1; i < 4; i++){
            if(V_cell[i] < min_cell){
              min_cell = V_cell[i];
            }else if(V_cell[i] > max_cell){
              max_cell = V_cell[i];
            }
          }
    
         
          switch (state_num) { // STATE MACHINE (see diagram)
            
            case 0:{ // Start state
              if (input_switch == 1) { // if switch, move to charge
                next_state = 1;
              } else { // otherwise stay put
                next_state = 0;
              }
              break;
            }
            
            case 1:{ // Charge state, constant current
              if(250 > max_power / V_out){
                standard_current = max_power / V_out;
              }else{
                standard_current = 250;
              }
              
              if(input_switch == 0){ //If the switch = 0, then go back to start
                next_state = 0;
              }else if (max_cell < 3600) { // if not charged, stay put
                next_state = 1;      
              } else { //Once one of the cells reaches 3600 mV we go into the balancing state
                I_setpoint = 0.9*ref_sum*485/500; //current setpoint during balancing
                next_state = 2;
              }
              
              break;
            }
    
            case 2:{ // Balancing state
              if(input_switch == 0){ //If the switch = 0, then go back to start
                next_state = 0;
              }else if(min_cell < 3600 or I_setpoint > 30){ //If not done balancing stay in balancing state
                next_state = 2;
                if (max_cell > 3630 and I_setpoint > 0 or I_setpoint > max_power / V_out){
                  I_setpoint -= 0.5;
                }else if(max_cell < 3600 and I_setpoint < 250 and I_setpoint < max_power / V_out){
                  I_setpoint += 0.5;
                }
              }else{ //If done balancing move to charge rest
                next_state = 3; //Go to charge rest
                SOH[1]++;//We have now finished a charge cycle so add 1 to SOH[1], could have done this in state 5 as well
                SOH[0] = 0; //At this point no charged has been used so reset SOH[0] 
                SOH[4] = 0; //At this point no energy has been expended so reset SOH[4]     
              }
              
              break;
            }
            
            case 3:{ // Charge Rest, no current, here we need to exchange solar panels for 10 ohm resistor
              if (input_switch == 1) { // if switch, stay put
                next_state = 3;
              } else { // otherwise go to idle state
                next_state = 0;
              }
              break;      
            }
            
            case 4: { // ERROR state, no current
              next_state = 4; // Always stay here
              if(input_switch == 0){ //UNLESS the switch = 0, then go back to start
                next_state = 0;
              }
              break;
            }
      
            default :{ // Should not end up here ....
              Serial.println("Boop");
              next_state = 4; // So if we are here, we go to error
              break;
            }
          }
        
          current_sum = 0; //reset the current sum so it is ready for the next cycle.
          ref_sum = 0;  //resets the average reference current so it is ready for the next cycle
          power_sum = 0; //Resets the average power so it is ready for the next cycle
          
          break;   
        }
        
      }
   
  
    //Output
    switch (state_num) { // STATE OUTPUT
  
      case 0: { //Start state, no current, no leds
        current_ref = 0;
        break;
      }
  
      case 1: { //Constant current charging state, pulse charging
  
        //Turn current ref to 0 before measuring so output voltage does not spike
        if (int_count > 20){
          current_ref = standard_current * 500 / 480;
        }else{
          current_ref = 0;
        }
  
        break;
      }

      case 2: { //Balancing state
        
        if (int_count > 20){
          current_ref = I_setpoint * 500 / 480;
        }else{
          current_ref = 0;
        }
        
        if(int_count == 25){ //Once a second do balancing stuff, only done once a second due to low update frequency of cell voltages
          balancing();
        }
  
        break;
      }

  
      case 3: { //Charge rest, no LEDS, no current
        current_ref = 0;
        break;
      }
  
      case 4: { //Error state RED LED and set voltage to 0.
        current_ref = 0;  
        break;
      }     
    }
    
  }
}

//----------- FUNCTIONS -------------//

//Balances the cell voltages
void balancing(){

  //If cell voltage is more than 50 mV larger than cell_min we turn on dis
  for(int i = 0; i < 4; i++){
    if(V_cell[i] > 3600){
      digitalWrite(dis_order[i],true); //Turn on dis
    }else{
      digitalWrite(dis_order[i],false); //Turn off dis
    }
  }
}


void check_for_errors(){ //Check whether we should enter an error state

  //---------- CHECKING FOR ERROR STATES ----------//

   //Checking that the cell voltages are in an acceptable range
  for (int i = 0; i < 4; i++){
    if((V_cell[i] > 3700 || V_cell[i] < 2400)){
      state_num = 4; //go directly to jail
      next_state = 4; // stay in jail
    }
  }

  //Checking for excessive output voltage and current
  if (I_out > 650 || V_out > 18000 || I_in < -2000){
    Serial.print(String(I_out) + " , " + String(V_out) + " , " + String(I_in));
    state_num = 4; //go directly to jail
    next_state = 4; // stay in jail
  }

}

// Timer A CMP1 interrupt. Every 4000us the program enters this interrupt. This is the fast 250 Hz loop
ISR(TCA0_CMP1_vect) {
  loop_trigger = 1; //trigger the loop when we are back in normal flow
  TCA0.SINGLE.INTFLAGS |= TCA_SINGLE_CMP1_bm; //clear interrupt flag
}


float saturation( float sat_input, float uplim, float lowlim) { // Saturation function
  if (sat_input > uplim) sat_input = uplim;
  else if (sat_input < lowlim ) sat_input = lowlim;
  else;
  return sat_input;
}


//----------- PID CONTROLLERS --------------//

//PID controller for current
float pidi(float pid_input) { // discrete PID function
  float e_integration;
  e0i = pid_input;
  e_integration = e0i;

  //anti-windup
  if (u1i >= ui_max) {
    e_integration = 0;
  } else if (u1i <= ui_min) {
    e_integration = 0;
  }

  delta_ui = kpi * (e0i - e1i) + kii * Ts * e_integration + kdi / Ts * (e0i - 2 * e1i + e2i); //incremental PID programming avoids integrations.
  u0i = u1i + delta_ui;  //this time's control output

  //output limitation
  saturation(u0i, ui_max, ui_min);

  u1i = u0i; //update last time's control output
  e2i = e1i; //update last last time's error
  e1i = e0i; // update last time's error
  return u0i;
}


void reset_pid(){  
  u1i = 0; //reset last time's control output
  e2i = 0; //reset last last time's error
  e1i = 0; //reset last time's error
}


void power_point(bool up_down){ //up_down == false, means we were not able to operate at given power, true means we will try to find higher power point, run with true if we are not working at full power

  if(up_down and max_power < 4.6 * 1000 * 1000){ //Power is limited at 4.6 W, which is the maximum rated power of the solar panels and more power than one will ever need to draw
    max_power += 0.1*1000*1000;  //If power point is too low, increase it by 100 mW. 
  }else if(!up_down and max_power > 0){
    max_power -= 0.1*1000*1000; //If power point is too high, decrease it by 100 mW
  }

  if(max_power <= 0){ // If the maximum power reaches 0, then we are not able to charge under the current conditions and we go to the error state
    state_num = 4;
    next_state = 4;
  }
  
}
