//First draft for charging cycle algorithm
//Created by Edvard J. S. Holen, based on "Battery_Charge_Cycle_Logged_V1.1" by Phil Clemow

//Include relevant libraries
#include <Wire.h>
#include <INA219_WE.h>
#include <SPI.h>
#include <SD.h>

INA219_WE ina219; // this is the instantiation of the library for the current sensor

// set up variables using the SD utility library functions:
Sd2Card card;
SdVolume volume;
SdFile root;

//Set parameters
int num_cells = 1; //Define number of cells in circuit
int pulse_period = 500; //Should be a factor in 500, given in ms
float duty_cycle = 0.8; //Duty cycle of pulse charging, max 0.9

//Declare variables
const int chipSelect = 10;
unsigned int rest_timer;
unsigned int loop_trigger;
unsigned int int_count = 0; // a variables to count the interrupts. Used for program debugging.

float current_sum = 0; //used to calculate the average current in the given cycle.
float ref_sum = 0; //used to calculate the average current reference in a cycle
float standard_current = 250;
float current_factor = 1; //Used to set higher or lower current based on power of panels
float voltage_ref = 0;

float u0i, u1i, delta_ui, e0i, e1i, e2i; // Internal values for the current controller
float ui_max = 1, ui_min = 0; //anti-windup limitation
float kpi = 0.02512, kii = 39.4, kdi = 0; // current pid.
float kpv=0.05024,kiv=15.78,kdv=0; // voltage pid.


float Ts = 0.001; //1 kHz control frequency.
float current_measure, current_ref = 0, error_amps; // Current Control
float pwm_out;
float V_Bat;
boolean input_switch;
int state_num=0,next_state;
String dataString;


float SOH[8]; //Array used for storing SOH data




void setup() {
  //Some General Setup Stuff

  Wire.begin(); // We need this for the i2c comms for the current sensor
  Wire.setClock(700000); // set the comms speed for i2c
  ina219.init(); // this initiates the current sensor
  Serial.begin(9600); // USB Communications


  //Check for the SD Card
  Serial.println("\nInitializing SD card...");
  if (!SD.begin(chipSelect)) {
    Serial.println("* is a card inserted?");
    while (true) {} //It will stick here FOREVER if no SD is in on boot
  } else {
    Serial.println("Wiring is correct and a card is present.");
  }

  if (SD.exists("BatCycle.csv")) { // Wipe the datalog when starting
    SD.remove("BatCycle.csv");
  }

 //Get old SOH/SOC data
  File SOHFile = SD.open("StateOfH.csv",FILE_READ); //Open the state of health data
  dataString = "";
  
  for (int i = 0; i < size(SOH); i++){
    while(SOHFile.available()){
      if(SOHFile.peek() != ','){
        dataString += SOHFile.read();
      }else{
        SOHFile.read();
        SOH[i] = float(dataString);
        dataString = "";
        break;
      }
    }
  }

  
  noInterrupts(); //disable all interrupts
  analogReference(EXTERNAL); // We are using an external analogue reference for the ADC

  //SMPS Pins
  pinMode(13, OUTPUT); // Using the LED on Pin D13 to indicate status
  pinMode(2, INPUT_PULLUP); // Pin 2 is the input from the CL/OL switch
  pinMode(6, OUTPUT); // This is the PWM Pin

  //LEDs on pin 7 and 8
  pinMode(7, OUTPUT);
  pinMode(8, OUTPUT);

  //Analogue input, the battery voltage (also port B voltage)
  pinMode(A0, INPUT);

  //Pins used to control battery boards
  pinMode(A1, INPUT); //Connected to the measurement port of all Battery boards

  pinMode(4, OUTPUT); //Used to control Dis input on cell1
  pinMode(5, OUTPUT); //Used to control Rly input on cell1
  

  // TimerA0 initialization for 1kHz control-loop interrupt.
  //TCA0.SINGLE.PER = 999; //
  //TCA0.SINGLE.CMP1 = 999; //
  TCA0.SINGLE.PER = 1999; //
  TCA0.SINGLE.CMP1 = 1999; //
  TCA0.SINGLE.CTRLA = TCA_SINGLE_CLKSEL_DIV16_gc | TCA_SINGLE_ENABLE_bm; //16 prescaler, 1M.
  TCA0.SINGLE.INTCTRL = TCA_SINGLE_CMP1_bm;

  // TimerB0 initialization for PWM output
  TCB0.CTRLA = TCB_CLKSEL_CLKDIV1_gc | TCB_ENABLE_bm; //62.5kHz

  interrupts();  //enable interrupts.
  analogWrite(6, 120); //just a default state to start with

}

void loop() {
  if (loop_trigger == 1){ // FAST LOOP (1kHZ)
      state_num = next_state; //state transition


      if ((V_Bat > 3700 || V_Bat < 2400)) { //Checking for Error states (just battery voltage for now)
          state_num = 6; //go directly to jail
          next_state = 6; // stay in jail
      }



      //--------- CLOSED LOOP FOR SMPS ------------//

      //in state 2 it is the voltage that decides the duty cycle, not current, note that it is output voltage we need, will put it at A0

      current_measure = (ina219.getCurrent_mA()); // sample the inductor current (via the sensor chip)
      current_sum += current_measure/500;
      ref_sum += current_ref/500;
      error_amps = (current_ref - current_measure) / 1000; //PID error calculation

      voltage_measure = = analogRead(A0)*4.096/1.033; //check the battery voltage (1.03 is a correction for measurement error, you need to check this works for you)
      error_volts = (voltage_ref - voltage_measure) / 1000; //PID error calculation
      

      if(state_num == 2){ //In CV part of charging duty cycle is set by voltage
        pwm_out = pidv(error_volts);
      } else { //Otherwise is set by current
        pwm_out = pidi(error_amps); //Perform the PID controller calculation
      }

      
      pwm_out = saturation(pwm_out, 0.99, 0.01); //duty_cycle saturation
      analogWrite(6, (int)(255 - pwm_out * 255)); // write it out (inverting for the Buck here)
      int_count++; //count how many interrupts since this was last reset to zero
      loop_trigger = 0; //reset the trigger and move on with life
      

      //-------- CELL VOLTAGE MEASUREMENT --------//
      //Measure only one cell voltage once per second, relays are switched at 900 ms and 1000 ms, which limits duty cycle to < 90%
      if (int_count == 450){
        digitalWrite(5,true);
      }

      //WHAT IF PULSE PERIOD IS CHANGED?
      
      if (int_count == 475){ 
         V_Bat = analogRead(A1)*4.096/1.033; //check the battery voltage (1.03 is a correction for measurement error, you need to check this works for you)
      }

      if (int_count == 500){
        digitalWrite(5,false);
      }



      //------- DATA LOGGING --------//

      if (int_count == 500){ //Do this once per second

          //Data logging
          dataString = String(state_num) + "," + String(V_Bat) + "," + String(ref_sum) + "," + String(current_sum); //build a datastring for the CSV file
          Serial.println(dataString); // send it to serial as well in case a computer is connected
          File dataFile = SD.open("BatCycle.csv", FILE_WRITE); // open our CSV file
          if (dataFile){ //If we succeeded (usually this fails if the SD card is out)
            dataFile.println(dataString); // print the data
          } else {
            Serial.println("File not open"); //otherwise print an error
          }
          dataFile.close(); // close the file


          //MAYBE STAGGER FROM OTHER SD data STUFF SO THAT IT TAKES LESS TIME
          //State of health (and some SOC)


          //Calculate new SOH data
          SOH[0] += current_sum; //How much capacity is left in battery
          //SOH[1] = SOH[1] //If we need to change number of cycles, it is not done here, so don't change it
          //SOH[2] = SOH[2] //If we need to change current capacity, it is not done here, so don't change it
          //SOH[3] = SOH[3] //Initial capacity is a constant so don't change it
          SOH[4] = V_Bat;
          //For when we use more than one battery, NEED TO UPDATE WITH EXTRA MEASUREMENTS
          SOH[5] = V_Bat;
          SOH[6] = V_Bat;
          SOH[7] = V_Bat;

          //Delete old SOH data:
          if (SD.exists("StateOfH.csv")) {
            SD.remove("StateOfH.csv");
          }

          //Write new SOH data
          File SOHFile = SD.open("StateOfH.csv", FILE_WRITE); //Open the state of health data
          
          dataString = "";
          for (int i = 0; i < size(SOH); i++){
            dataString += String(SOH[i]);
            dataString += ",";
          }

          //Remove extra comma at end of csv, just to keep it nice
          dataString[strlen(dataString)-1] = '\0';


          dataFile.println(dataString); //Write new SOH data to file 
          Serial.println(dataString); //For ease, serial print the data as well

          SOHFile.close(); //Close the file
    

          SOHFile.close(); //Close the file
      


      //------- STATE MACHINE ---------//

  
    //Next state
    if (int_count == 500) { // SLOW LOOP (1Hz)
      int_count = 0; // reset the interrupt count so we dont come back here for 1000ms
      input_switch = digitalRead(2); //get the OL/CL switch status
      current_sum = 0; //reset the current sum so it is ready for the next cycle.
      ref_sum = 0;

       
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
          if (V_Bat < 3600) { // if not charged, stay put
            next_state = 1;      
          } else { //Once one of the cells reaches 3600 mV we go into CV
            next_state = 2;
          }
          if(input_switch == 0){ // UNLESS the switch = 0, then go back to start
            next_state = 0;
          }
          break;
        }

        case 2:{ // Charge state, constant voltage

          if (current_sum > 0.05*standard_current){ // if not charged, stay put, wait until current is less than 5% of standard current
            next_state = 2;
          } else { // otherwise go to charge rest
            //We have now finished a charge cycle so add 1 to SOH[1], could have done this in state 5 as well
            SOH[1]++;

            //Update the maximum capacity
            SOH[2] = SOH[0];
            
            next_state = 3;
          }
          
          if(input_switch == 0){ // UNLESS the switch = 0, then go back to start
            next_state = 0;
          }
          break;
        }
        
        case 3:{ // Charge Rest, green LED is off and no current
          if (rest_timer < 30) { // Stay here if timer < 30
            next_state = 3;
            rest_timer++;
          } else { // Or move to discharge (and reset the timer)
            next_state = 4;
            rest_timer = 0;
          }
          if(input_switch == 0){ // UNLESS the switch = 0, then go back to start
            next_state = 0;
            rest_timer = 0;
          }
          break;        
        }
        
        case 4:{ //Discharge state (-250mA and no LEDs)
           if (V_Bat > 2500) { // While not at minimum volts, stay here
             next_state = 4;
           } else { // If we reach full discharged, move to rest
             next_state = 5;

             //At this point all charge stored in the cell has been used so SOH[0] should be o
             SOH[0] = 0;
             
           }
          if(input_switch == 0){ //UNLESS the switch = 0, then go back to start
            next_state = 0;
          }
          break;
        }
        
        case 5:{ // Discharge rest, no LEDs no current
          if (rest_timer < 30) { // Rest here for 30s like before
            next_state = 5;
            rest_timer++;
          } else { // When thats done, move back to charging (and light the green LED)
            next_state = 1;
            rest_timer = 0;
          }
          if(input_switch == 0){ //UNLESS the switch = 0, then go back to start
            next_state = 0;
            rest_timer = 0;
          }
          break;
        }
        
        case 6: { // ERROR state RED led and no current
          next_state = 6; // Always stay here
          if(input_switch == 0){ //UNLESS the switch = 0, then go back to start
            next_state = 0;
          }
          break;
        }
  
        default :{ // Should not end up here ....
          Serial.println("Boop");
          current_ref = 0;
          next_state = 6; // So if we are here, we go to error
        }
        
      }
  
    }
   
  
    //Output
    switch (state_num) { // STATE OUTPUT
  
      case 0: { //Start state, no current, no leds
        current_ref = 0;
  
        //Leds
        digitalWrite(7,false);
        digitalWrite(8,false);
        break;
        
      }
  
      case 1: { //Constant current charging state, pulse charging, green led //NEED TO ADD BALANCING
  
        //LEDs
        digitalWrite(7,false);
        digitalWrite(8,true);
  
        //Making current pulse, with given duty_cycle and period
        if ( (int_count % pulse_period) < duty_cycle*pulse_period){
          current_ref = 250/duty_cycle;
        }else{
          current_ref = 0;
        }
  
        //Cell balancing
        
        break;
      }

      case 2: { //Constant voltage charging state, pulse charging, green led //NEED TO ADD BALANCING
  
        //LEDs
        digitalWrite(7,false);
        digitalWrite(8,true);
  
        //Note! Voltage does not need to pulse as we can achieve the desired voltage despite cell being disconnected
        voltage_ref = 3600;
  
        //Cell balancing
        
        break;
      }

  
      case 3: { //Charge rest, no LEDS, no current
        current_ref = 0;
  
        //LEDs
        digitalWrite(7,false);
        digitalWrite(8,false);


        break;
      }
  
      case 4: { //Discharge state,  (-250mA and no LEDs) //SHOULD DISCHARGE IN PULSES ALSO?
  
        //LEDs
        digitalWrite(7,false);
        digitalWrite(8,false);

        //Making current pulse, with given duty_cycle and period
        if ( (int_count % pulse_period) < duty_cycle*pulse_period){
          current_ref = -250/duty_cycle;
        }else{
          current_ref = 0;
        }

        break;
        
      }
  
      case 5: { //Discharge rest, no LEDs, no current
        current_ref = 0;
  
        //LEDs
        digitalWrite(7,false);
        digitalWrite(8,false);

      }
  
      case 6: { //Error state RED LED and no current
        current_ref = 0;
  
        //LEDs
        digitalWrite(7,true);
        digitalWrite(8,false);
        
        break;
      }
      
    }
  
  }
}

// Timer A CMP1 interrupt. Every 1000us the program enters this interrupt. This is the fast 1kHz loop
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
