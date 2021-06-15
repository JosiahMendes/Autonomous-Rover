/*
 * Code used to discharge 4 battery cells in series
 * 
 * Code written by Edvard J. S. Holen (edvard.holen19@imperial.ac.uk)
 * Start date: 1st June 2021
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

float current_sum = 0; //used to calculate the average output current in the given cycle
float power_sum = 0; //used to calculate the average power in the given cycle

float V_in; //Input voltage
float I_in; //Input current
float V_cell[4]; //Cell voltages of each battery cell
double SOH[5]; //Array used for storing SOH data
unsigned long energy_lookup[600]; //Lookup table for how much energy is left based on SOC
unsigned int energy_correction[600];  //Lookup table used to track how much energy has been expended

float min_cell;
float max_cell;
int dig_order[4] = {20, 21, 3, 9}; //Gives the digital output number for each of the rly input


float u0i, u1i, delta_ui, e0i, e1i, e2i; // Internal values for the current controller
float ui_max = 1, ui_min = 0; //anti-windup limitation
float kpi=0.02512,kii=39.4,kdi=0; // current pid


float Ts = 0.002; //500 Hz control frequency.

float error_amps; // current control
float duty_cycle; //duty cycle of SMPS

char* dataChars; //Array of characters used for reading in data from SD card
String dataString; //string used for data logging and printing to serial
const int chipSelect = 10; //constant used for SD card

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
  if (SD.exists("BatDisch.csv")) {
    SD.remove("BatDisch.csv");
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

  ///5V supply for op-amp
  pinMode(17, OUTPUT);
  digitalWrite(17,true);


  //Analogue measurements
  pinMode(A1, INPUT); //Measures cell voltages
  pinMode(A2, INPUT); //Measure Vin
  

  //Pins used to control battery boards
  pinMode(20, OUTPUT); //Rly cell1

  pinMode(21, OUTPUT); //Rly cell2

  pinMode(3, OUTPUT); //Rly cell3

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

}


//------------ MAIN LOOP -------------//

void loop() {
  if (loop_trigger == 1){ // FAST LOOP (500 Hz)
      
      loop_trigger = 0; //reset the trigger and move on with life
      int_count++; //count how many interrupts since last reset
      state_num = next_state; //state transition

      //Sample output and currents
      I_in =  (ina219.getCurrent_mA()); //Measure input current [mA]
      V_in =  analogRead(A2)*float(4.5*4000/1023);
      

      current_sum += I_in/500; //Calculate the average battery current for the cycle
      power_sum -= 0.001*I_in*V_in/(500); //Calculate the average power usage for the current cycle, only used during discharge

      //--------- PID CONTROL FOR SMPS ------------//
   
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


        case 100:{

          cycle_count++;
          
          if(cycle_count % 4 == 0){
            
            Serial.println(dataString); // send it to serial as well in case a computer is connected
            File dataFile = SD.open("BatDisch.csv", FILE_WRITE); // open our CSV file
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
          dataString = String(state_num) +  "," + String(current_sum) + "," + String(I_in) + "," + String(V_in) + "," + String(V_cell[0]) + "," + String(V_cell[1]) + "," + String(V_cell[2]) + "," + String(V_cell[3]); //build a datastring for the CSV file
          //Calculate new SOH and SOC data
          SOH[0] += current_sum; //How much capacity we have used so far
          //SOH[1] = SOH[1] //If we need to change number of cycles, it is not done here, so don't change it
          //SOH[2] = SOH[2] //If we need to change current capacity, it is not done here, so don't change it
          //SOH[3] = SOH[3] //Initial capacity is a constant so don't change it
          SOH[4] += power_sum; //How much energy has been used so far
          
          energy_correction[int(-SOH[0] / 3600)] += power_sum; 




          //---------- STATE MACHINE -----------//

          int_count = 0; // reset the interrupt count so we dont come back here for 1000ms
    
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

          input_switch = digitalRead(2); //get the OL/CL switch status
         
          switch (state_num) { // STATE MACHINE (see diagram)

            case 0:{ // Rest state
              if(input_switch == 1){
                next_state = 1;
              }else{
                next_state = 0;
              }
              break;
            }
            
            case 1:{ //Discharge state (-250mA)
              if (min_cell > 2500) { //If not discharged, keep discharging
                next_state = 1;
              } else { // Otherwise write data
                next_state = 2;
              }
              break;
            }
            
            
            case 2:{ //Write data to SD card
    
              next_state = 0;
              SOH[2] = SOH[0]; //Update the maximum capacity
              update_energy();//Update energy look-up table
              
              break;
            }
            
            
      
            default :{ // Should not end up here ....
              Serial.println("Boop");
              break;
            }
          }
        
          current_sum = 0; //reset the current sum so it is ready for the next cycle.
          power_sum = 0; //Resets the average power so it is ready for the next cycle
          
          break;   
        }
        
      } 
  }
}

//----------- FUNCTIONS -------------//

void update_energy(){

  //Iterate energy approximation and reset energy correction array
  for(int i = 0; i < 600; i++){ //Reset energy_correction array
    energy_lookup[i] = 0.99*energy_lookup[i];
    for(int j = i; j < 600; j++){
      energy_lookup[i] += 0.01*energy_correction[j];
    }
    energy_correction[i] = 0;
  }

  //Delete existing data
  if (SD.exists("EnergyLU.csv")) {
    SD.remove("EnergyLU.csv");
  }
  
  //Write new data
  File EnergyFile = SD.open("EnergyLU.csv", FILE_WRITE); //Open the state of health data
  
  for (int i = 0; i < 600; i++){
    dataString = "";
    dataString += String(energy_lookup[i]);
    dataString += ",";
    EnergyFile.print(dataString); //Write new data to file 
    Serial.print(dataString); //For ease, serial print the data as well
  }

  EnergyFile.close(); //Close the file
}

// Timer A CMP1 interrupt. Every 4000us the program enters this interrupt. This is the fast 250 Hz loop
ISR(TCA0_CMP1_vect) {
  loop_trigger = 1; //trigger the loop when we are back in normal flow
  TCA0.SINGLE.INTFLAGS |= TCA_SINGLE_CMP1_bm; //clear interrupt flag
}
