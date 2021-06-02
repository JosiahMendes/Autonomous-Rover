/*
 * Code used to charge 4 battery cells in series
 * 
 * Code written by Edvard J. S. Holen (edvard.holen19@imperial.ac.uk)
 * Start date: 27th May 2021
 * 
 * Version 2, uses switch..case rather than if..else statements
 */

//Include relevant libraries
#include <SD.h>  //Used for SD card logging


//Set up variables using the SD utility library functions:
Sd2Card card;
SdVolume volume;
SdFile root;


//Declare global variables
unsigned int loop_trigger; //variable which triggers main loop
unsigned int int_count = 0; //counts the number of loops
unsigned int cell_count = 1; //decides which cell we should measure voltage of

int state_num = 0; //current state of state machine
int next_state; //state of state machine after next interupt
unsigned int rest_timer; //used to count how long we have been in rest state

boolean input_switch; //value of CL/OL switch CL = true, OL = false

float voltage_ref = 0; //Used to set the desired voltage at the output
float current_ref = 0; //Used to set the desired current at the output
float current_sum = 0; //used to calculate the average output current in the given cycle
float ref_sum = 0; //used to calculate the average reference output current in the given cycle

float I_out; //output current at a given time instance
float V_out; //output voltage at a given time instance
float V05; //Voltage across current sensor
float V_Bat; //Voltage over the batteries (V_out - V05)
float V_Setpoint; //Value of V_Bat as we enter balancing state
float V_cell[4]; //Cell voltages of each battery cell
float SOH[8]; //Array used for storing SOH data
float min_cell; //Mininmum cell voltage
float max_cell; //Maximum cell voltage
    
int dig_order[4] = {20, 21, 3, 9}; //Gives the digital output number for each of the rly input
int dis_order[4] = {4, 5, 8, 7}; //Gives the digital output number for each of the dis inputs

float u0v, u1v, delta_uv, e0v, e1v, e2v; // Internal values for the voltage controller
float uv_max = 1, uv_min = 0; //anti-windup limitation
float u0i, u1i, delta_ui, e0i, e1i, e2i; // Internal values for the current controller
float ui_max = 1, ui_min = 0; //anti-windup limitation
float kpv=0.05024,kiv=15.78,kdv=0; // voltage pid gains
//float kpi = 0.02512, kii = 39.4, kdi = 0; // current pid gains
float kpi = 0.02512, kii = 45, kdi = 0; // current pid gains

float Ts = 0.002; //500 Hz control frequency.
float standard_current = 250; //the output current during normal operation
//float standard_current = 62.5; //the output current during normal operation

float error_amps; // current control
float error_volts; //voltage control
float pwm_out;  //duty cycle of SMPS

//char* dataString; //string used for data logging and printing to serial
char* dataChars; //Array of characters used for reading in data from SD card
String dataString; //string used for data logging and printing to serial
const int chipSelect = 10; //constant used for SD card

//battery and pulse charging parameters
int num_cells = 4; //Define number of cells in circuit
int pulse_period = 500; //Should be a factor in 500, given in number of loop_triggers
float duty_cycle = 0.5; //Duty cycle of pulse charging, max 0.9


//------------- SETUP -------------//

void setup() {

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
  
  for (int i = 0; i < 8; i++){
    while(SOHFile.available()){
      if(SOHFile.peek() != ','){
        dataChars += SOHFile.read();
      }else{
        SOHFile.read();
        SOH[i] = atof(dataChars);
        dataChars = "";
        break;
      }
    }
  }

  
  noInterrupts(); //disable all interrupts
  analogReference(EXTERNAL); // We are using an external analogue reference for the ADC

  //------------ PIN DECLARATIONS ------------// 

  //SMPS Pins
  pinMode(2, INPUT_PULLUP); // Pin 2 is the input from the CL/OL switch
  pinMode(6, OUTPUT); // This is the PWM Pin


  //Analogue measurements
  pinMode(A0, INPUT); //Measure Vpd ( = V_out/5)
  pinMode(A1, INPUT); //Measures cell voltages
  pinMode(A2, INPUT); //Measures the amplified voltage of the current sensor (= 11*V_resistor)

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
//Note! Reason for every if statement to be triggered at different int_count is to give better timing constraints

void loop() {
  if (loop_trigger == 1){ // FAST LOOP (500 Hz)
      
      loop_trigger = 0; //reset the trigger and move on with life
      int_count++; //count how many interrupts since last reset
      state_num = next_state; //state transition

      //Get sampled values
      sampling();

      current_sum += I_out/500; //Calculate the average output current for the cycle
      ref_sum += current_ref/500; //Calculate the average reference current for the cycle

      //Check whether we should enter an error state
      check_for_errors();


      //--------- PID CONTROL FOR SMPS ------------//
      
      if(state_num == 2 || state_num == 3){ //In balancing and CV part of charging duty cycle is set by voltage
        error_volts = (voltage_ref - (V_out - V05)) / 1000; //PID error calculation      
        pwm_out = pidv(error_volts);
      } else { //Otherwise is set by current
        error_amps = (current_ref - I_out) / 1000; //PID error calculation
        pwm_out = pidi(error_amps); //Perform the PID controller calculation
      }

      analogWrite(6, (int)(pwm_out * 255)); // write it out (non-inverting for Boost)

      switch(int_count){ //Decides what happens at different parts of a cycle

        case 100: { //Writing of SOC/SOH data is staggered from other logging to get better timing constraints

          //Delete old SOH data:
          if (SD.exists("StateOfH.csv")) {
            SD.remove("StateOfH.csv");
          }

          //Write new SOH data
          File SOHFile = SD.open("StateOfH.csv", FILE_WRITE); //Open the state of health data
          
          dataString = "";
          for (int i = 0; i < 8; i++){
            dataString += String(SOH[i]);
            dataString += ",";
          }

          //Remove extra comma at end of csv, just to keep it nice
          dataString[dataString.length()-1] = '\0';


          SOHFile.println(dataString); //Write new SOH data to file 
          Serial.println(dataString); //For ease, serial print the data as well

          SOHFile.close(); //Close the file
          
          break;
        }


        //----------- CELL VOLTAGE MEASUREMENT -----------//
        //Measure only one cell voltage once per second, relays are switched at 900 ms and 1000 ms, which limits duty cycle to < 90%
        case 450: {
          //Switch relay on
          digitalWrite(dig_order[cell_count - 1],true);
          break;
        }

        case 475: { //Check voltage some time after relay is switched so measurement is stable
         V_cell[cell_count - 1] = analogRead(A1)*float(4096/1023)/1.012; //Get the cell voltage [mV]
         break;
        }

        case 490: { //Switch relay off after measurement
          digitalWrite(dig_order[cell_count - 1],false);
          cell_count = (cell_count % 4) + 1;
          break;
        }

        case: 495 { //Find max and min cell voltage
          
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
           
          break; 
        }


        case 500: { //Do this once per second
  
            //------- DATA LOGGING --------//
            
            dataString = String(state_num) +  "," + String(ref_sum) + "," + String(current_sum) + "," + String(V_out) + "," + String(V_Bat) + "," + String(V_cell[0]) + "," + String(V_cell[1]) + "," + String(V_cell[2]) + "," + String(V_cell[3]); //build a datastring for the CSV file
            Serial.println(dataString); // send it to serial as well in case a computer is connected
            File dataFile = SD.open("BatCharg.csv", FILE_WRITE); // open our CSV file
            if (dataFile){ //If we succeeded (usually this fails if the SD card is out)
              dataFile.println(dataString); // print the data
            } else {
              Serial.println("File not open"); //otherwise print an error
            }
            dataFile.close(); // close the file
  
  
            //Calculate new SOH and SOC data
            SOH[0] += current_sum; //How much capacity we have used so far
            //SOH[1] = SOH[1] //If we need to change number of cycles, it is not done here, so don't change it
            //SOH[2] = SOH[2] //If we need to change current capacity, it is not done here, so don't change it
            //SOH[3] = SOH[3] //Initial capacity is a constant so don't change it
            SOH[4] = V_cell[0]; //Cell 1 voltage
            SOH[5] = V_cell[1]; //Cell 2 voltage
            SOH[6] = V_cell[2]; //Cell 3 voltage
            SOH[7] = V_cell[3]; //Cell 4 voltage


           //------- STATE MACHINE ---------//

            int_count = 0; // reset the interrupt count so we dont come back here for 1000ms
            input_switch = digitalRead(2); //get the OL/CL switch status
            current_sum = 0; //reset the current sum so it is ready for the next cycle.
            ref_sum = 0;  //resets the average reference current so it is ready for the next cycle
      
           
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
                if(input_switch == 0){ //If the switch = 0, then go back to start
                  next_state = 0;
                }else if (max_cell < 3600) { // if not charged, stay put
                  next_state = 1;      
                } else { //Once one of the cells reaches 3600 mV we go into the balancing state
                  V_Setpoint = V_Bat; //store current battery voltage
                  next_state = 2;
                }
                
                break;
              }
      
              case 2:{ // Balancing state
                if(input_switch == 0){ //If the switch = 0, then go back to start
                  next_state = 0;
                }else if(max_cell > min_cell + 50){ //If not done balancing stay in balancing state
                  next_state = 2;
                }else{ //If done balancing move to constant voltage
                  next_state = 3;
                }
                
                break;
              }
      
              case 3:{ // Charge state, constant voltage
      
                if(input_switch == 0){ //If the switch = 0, then go back to start
                  next_state = 0;
                }else if (current_sum > 0.05*standard_current){ // if not charged, stay put, wait until current is less than 5% of standard current
                  next_state = 3;
                } else { // otherwise go to charge rest
                  SOH[1]++;//We have now finished a charge cycle so add 1 to SOH[1], could have done this in state 5 as well
                  SOH[0] = 0; //At this point no charged has been used so reset SOH[0]      
                  next_state = 4; //Go to charge rest
                }
                
                break;
              }
              
              case 4:{ // Charge Rest, no current
                if(input_switch == 0){ // if the switch = 0, then go back to start
                  next_state = 0;
                  rest_timer = 0;
                }else if (rest_timer < 30) { // Stay here if timer < 30
                  next_state = 4;
                  rest_timer++;
                } else { // Or move to discharge (and reset the timer)
                  next_state = 5;
                  rest_timer = 0;
                }
                
                break;        
              }
              
              case 5:{ //Discharge state (-250mA)
      
                if(input_switch == 0){ //if the switch = 0, then go back to start
                  next_state = 0;
                }else if (min_cell > 2500){ //If all cell have voltage higher than 2500 mV, keep discharging
                  next_state = 5;
                }else{ //Otherwise we are done discharging and move to discharge rest
                  next_state = 6;
                  SOH[2] = SOH[0]; //Update the maximum capacity
                }
                
                break;
                
              }
              
              case 6:{ // Discharge rest, no current
                if(input_switch == 0){ //if the switch = 0, then go back to start
                  next_state = 0;
                  rest_timer = 0;
                }else if (rest_timer < 30) { // Rest here for 30s like before
                  next_state = 6;
                  rest_timer++;
                } else { // When thats done, move back to charging (and light the green LED)
                  next_state = 1;
                  rest_timer = 0;
                }
               
                break;
              }
              
              case 7: { // ERROR state, no current
                next_state = 7; // Always stay here
                if(input_switch == 0){ //UNLESS the switch = 0, then go back to start
                  next_state = 0;
                }
                break;
              }
        
              default :{ // Should not end up here ....
                Serial.println("Boop");
                current_ref = 0;
                next_state = 7; // So if we are here, we go to error
                break;
              }
            }

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
  
        //Making current pulse, with given duty_cycle and period
        if ( (int_count % pulse_period) < duty_cycle*pulse_period){
          current_ref = standard_current / duty_cycle;
        }else{
          current_ref = 0;
        }
  
        break;
      }

      case 2: { //Balancing state
        //To allow certain cells to charge while others don't we use a current low enough that it can be dissipated
        voltage_ref = V_Setpoint;
        
        if(int_count == 50){ //Once a second do balancing stuff, only done once a second due to low update frequency of cell voltages
          balancing();
        }
  
        break;
      }

      case 3: { //Constant voltage charging state, pulse charging, green led
        //Note! Voltage does not need to pulse as we can achieve the desired voltage despite cell being disconnected
        voltage_ref = 3600 * num_cells;

        //Note! Balancing is also done in constant voltage state for good measure
        if(int_count == 50){ //Once a second do balancing stuff, only done once a second due to low update frequency of cell voltages
          balancing();
        }
        
        break;
      }

  
      case 4: { //Charge rest, no LEDS, no current
        current_ref = 0;
        break;
      }
  
      case 5: { //Discharge state,  (-250mA and no LEDs)

        //Making current pulse, with given duty_cycle and period
        if ( (int_count % pulse_period) < duty_cycle*pulse_period){
          current_ref = -standard_current/duty_cycle;
        }else{
          current_ref = 0;
        }

        break;
        
      }
  
      case 6: { //Discharge rest, no LEDs, no current
        current_ref = 0;
        break;
      }
  
      case 7: { //Error state RED LED and no current
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
    if(V_cell[i] > min_cell + 30){
      digitalWrite(dis_order[i],true); //Turn on dis
    }else{
      digitalWrite(dis_order[i],false); //Turn off dis
    }
  }
}


void sampling(){ //Sample the relevant voltages and determine currents

//NEED TO USE SOME CONSTANTS TO ADJUST VOLTAGES SO THAT THEY ARE CORRECT

  // Make the initial sampling operations for the circuit measurements
  unsigned int sensorValue0 = analogRead(A0);
  unsigned int sensorValue2 = analogRead(A2);

  V_out = sensorValue0*(4096/1023.0)*5/1.08; //Calculate output voltage [mV]
  V05 = sensorValue2*(4096/1023.0)/11; //Calculate voltage across current sensor [mV]
  V_Bat = V_out - V05; //Calculate voltage across batteries [mV]

  I_out = sensorValue2*(4096/1023.0)*0.1713 - 0.9821; //Calculate output current [mA]
  
}


void check_for_errors(){ //Check whether we should enter an error state

  //---------- CHECKING FOR ERROR STATES ----------//

   //Checking that the cell voltages are in an acceptable range
  for (int i = 0; i < 4; i++){
    if((V_cell[i] > 3700 || V_cell[i] < 2400)){
      state_num = 7; //go directly to jail
      next_state = 7; // stay in jail
    }
  }

  //Checking for excessive output voltage and current
  if (I_out > 600 || V_out > 16000){
    state_num = 7; //go directly to jail
    next_state = 7; // stay in jail
  }

}

// Timer A CMP1 interrupt. Every 2000us the program enters this interrupt. This is the fast 500 Hz loop
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

//PID controller for voltage
float pidv( float pid_input){
  float e_integration;
  e0v = pid_input;
  e_integration = e0v;
 
  //anti-windup, if last-time pid output reaches the limitation, this time there won't be any intergrations.
  if(u1v >= uv_max) {
    e_integration = 0;
  } else if (u1v <= uv_min) {
    e_integration = 0;
  }

  delta_uv = kpv*(e0v-e1v) + kiv*Ts*e_integration + kdv/Ts*(e0v-2*e1v+e2v); //incremental PID programming avoids integrations.there is another PID program called positional PID.
  u0v = u1v + delta_uv;  //this time's control output

  //output limitation
  saturation(u0v,uv_max,uv_min);
  
  u1v = u0v; //update last time's control output
  e2v = e1v; //update last last time's error
  e1v = e0v; // update last time's error
  return u0v;
}


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
 
