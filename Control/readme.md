## Organisation of Files

There are 4 folders as a part of the Control Subsystem:

The folder [ESP32Control](ESP32Control) contains the control code for the ESP32 written in .ino with the Arduino IDE configured together with the ESP32 board. To test the code, simply follow instructions to use the ESP32 add-on through the Arduino IDE and flash the code onto the device.

[ControlClient.ino](ESP32Control/ControlClient.ino) is the main ESP32 code which was run as a part of the final Mars Rover Demo. [DriveCommands.ino](ESP32Control/DriveCommands.ino) is an earlier version of the code meant for testing out UART solely between Control and Drive by inputting commands through the terminal.

The folder [ESP32TestScripts](ESP32TestScripts) contains two test scripts which were run on the ESP32 to explore it's capabilities.

The folder [EnergyControl](EnergyControl) contains the final python script, [EnergyClient.py](EnergyControl/EnergyClient.py) for sending data from the Energy subsystem to the Command subsystem. 

The folder [TCPDebugging](TCPDebugging) contains a simple python TCP server which can receive messages and send messages through use of the terminal.