# ada-motorcontrol
This is a sofware platform for developing motor control applications, mainly aimed at brushless DC motors (BLDC/PMSM). 
It is written in Ada, a language designed for use in systems where reliability and efficiency is essential, and is therefore commonly used in safety critical application. 
Read more about Ada here: http://www.adacore.com/adaanswers/about/ada

For the current state of project and features, see the [Make with Ada project log](http://www.makewithada.org/entry/ada-motorcontrol). 

## Supported Hardware
- [MotCtrl board](https://github.com/osannolik/MotCtrl)
- Planned: VESC

## Documentation
Generated from source:
https://github.com/osannolik/ada-motorcontrol/tree/master/doc

## Getting Started
The software is build using the [GNAT GPL 2017 ARM ELF](http://libre.adacore.com/download/configurations) compiler and is based on the following repos
- [embedded-runtimes](https://github.com/osannolik/embedded-runtimes)
- [Ada Drivers Library](https://github.com/osannolik/Ada_Drivers_Library)

1. Clone this repo recursively
```
git clone --recursive https://github.com/osannolik/ada-motorcontrol.git
```
2. Follow this [guide](https://github.com/AdaCore/Ada_Drivers_Library/tree/master/examples#getting-started) to install GNAT GPL and the embedded runtimes. Note that you should use the runtimes included in this repo since it includes the runtime for the Motorcontrol board. The same applies to Ada_Drivers_Library. 
3. Use the Makefile or GPS IDE to build the software
```
make all
```
4. Using st-link, flash and run by
```
make run
```
