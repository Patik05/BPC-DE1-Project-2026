# BPC-DE1-Project Alarm clock
Project for the bachelor subject Digital Electronics 1, 2026 <br>

##  Main objective
Create working alarm clock. Maximum amount of time being possible to set being a day (23.59.59 <=> HH.MM.SS). User should be able to increase/decrease units of time by second, minutes and hours (depending on the mode set). After the set time is satisfactory, user may start the alarm clock. While the clock is running, the user is effectively blocked from manipulating with the alarm clock time, unless the countdown is stopped (time running out or pressing the stop/start button). When the set time runs out, a coloured red diode lights up and buzzer starts buzzing. It continues to signal until the stop/start button gets pressed.

### List of used hardware components of the board
| Component | Function |
| :--- | :----- |
| `BTNU` - Up button | Increases time value |
| `BTND` - Down button | Decreases time value |
| `BTNC` - Center button | Starts/stops the alarm clock the countdown, stops buzzer noise + the RGB diode after the timer runs out |
| `BTNL` - Left button | Resets the time |
| `BTNR` - Right button | Changes the time incrementation/decrementation (by seconds, minutes, hours) |
| `6x 7-segment displays` | Displays the time in HH.MM.SS format |
| `RGB diode` | Signals output in red when the time runs out |

## Modules
Everything is wrapped into top level `alarm_clock_top`
Custom new modules:
- ```alarm_clock``` ([code](alarm_clock/alarm_clock.srcs/sources_1/new/alarm_clock.vhd))
- ```buzzer_module``` ([code](alarm_clock/alarm_clock.srcs/sources_1/new/buzzer_module.vhd))

Already existing modules from the [VHDL examples](https://github.com/tomas-fryza/vhdl-examples/tree/master) repository using documentation:
- [```bin2seg```](https://github.com/tomas-fryza/vhdl-examples/tree/master/lab3-segment) (modified, the default number is set to 0 (seg <= 0000001), otherwise works the same) ([code](alarm_clock/alarm_clock.srcs/sources_1/imports/imports/new/bin2seg.vhd))
- [```clk_en```](https://github.com/tomas-fryza/vhdl-examples/tree/master/lab4-counter) (unchanged, docs included within the counter .md file) ([code](alarm_clock/alarm_clock.srcs/sources_1/imports/imports/new/clk_en.vhd))
- [```counter```](https://github.com/tomas-fryza/vhdl-examples/tree/master/lab4-counter) (unchanged) ([code](alarm_clock/alarm_clock.srcs/sources_1/imports/imports/Documents/counter/counter.srcs/sources_1/new/counter.vhd))
- [```display_driver```](https://github.com/tomas-fryza/vhdl-examples/tree/master/lab5-display) (modified, allowing 6 segment displays instead of only 2) ([code](alarm_clock/alarm_clock.srcs/sources_1/imports/imports/new/display_driver.vhd))
- [```debounce```](https://github.com/tomas-fryza/vhdl-examples/tree/master/lab6-debounce) (unchanged) ([code](alarm_clock/alarm_clock.srcs/sources_1/imports/imports/Documents/debounce/debounce.srcs/sources_1/new/debounce.vhd))
  
  Completed source code of how these borrowed modules look in full are [here](https://github.com/tomas-fryza/vhdl-examples/tree/master/examples/_solutions).

## Constraints file
[Constraints file](https://github.com/Patik05/BPC-DE1-Project-2026/blob/main/alarm_clock/alarm_clock.srcs/constrs_1/imports/newly/nexys.xdc) for the nexys A7 50t board for this project.
## alarm_clock module

### Background
An alarm clock is used to be an adjustable timer that signals to an user that time has run out. Runs with a clock cycle ('clk'). It also requires to have a possible way for an user to input its time values and when to signal the countdown.

### I/O ports of the `alarm_clock` module:
| Port name | Direction | Type | Description |
|:---------|:---------:|:----|:-----------|
| `clk` | in | `std_logic` | Main system clock |
| `sig_reset` | in |  `std_logic` | Resets clock to 00.00.00 and clears alarms|
| `sig_in` | in |  `std_logic` | Increments time by the currently selected time unit (Sec/Min/Hr) |
| `sig_dec` | in |  `std_logic` | Decrements time by the currently selected time unit (Sec/Min/Hr)|
| `sig_mode` | in |  `std_logic` | Cycles the edit mode (sec -> min -> hr) |
| `sig_play_pause` | in |  `std_logic` | Toggles countdown/silence alarm |
| `ce_1hz` | in |  `std_logic` | 1 Hz enable pulse for real-time counting |
| `disp_data` | out |  `std_logic_vector(23 downto 0)` | 24-bit bus containing 6 concatenated 4-bit BCD values representing HH.MM.SS |
| `alarm_active` | out |  `std_logic` | Activates high (1) when timer hits 0 |

The module operates with three states: `Setup mode` (paused, being editable) and a `Countdown mode` (when the time is counting down) and `Alarm ringing mode` (time has run out)
- `Setup mode`: User interacts with time incrementation/decrementation (`sig_inc`, `sig_dec` respectively. The math uses a wrap-around logic (meaning that decrementing 00 seconds wraps to 59 seconds while not borrowing from minutes).
- `Countdown mode`: User setup inputs get ignored, except for the center button to stop the countdown (`sig_play_pause`). While the mode is active, it exclusively listens to `ce_1hz` pulse, executing standard clock math.
- `Alarm ringing tone`: When the timer reads 00.00.00, it triggers a red diode to glow and a buzzer to start making noise, continuing until the user presses the center button (`sig_play_pause`), returning the system to `Setup_mode`.

Outcome of `alarm_clock_tb`:
![alarm_clock_tb](images/sim1_alarm_clock_tb.png)<br>
<i>The display of the simulation shows us an example of the alarm clock responding to incoming signals.</i>

The test provides us the following events:
- sig_reset is used to be sure that all used variables for the clock are indeed at the starting values.
- sig_inc (navy blue) gets pushed to increment values of the alarm clock, increasing the output in disp_data from 000000 to 000003 adding 3 seconds, then after switching mode to a 000103 adding a minute
- sig_mode (gray) changes the mode of incrementation/decrementation (ss -> mm -> hh -> ss -> ...), simulation only shows switching from seconds to minutes
- sig_dec (red) decreases the time on the actual alarm clock
- sig_play_pause (violet) is used to signal countdown and eventual stop of the sounds of the buzzer and the led_diode (alarm_active)
- ce_1hz (gray) shows the countdown, before alarm_active is turned on
- alarm_active (dark blue) shows the time when buzzer is blaring and the led diode (red) is glowing

### Conclusion
The test shows us intended change in behaviour for a module that should work as an adjustable alarm clock that signals when time runs out. With the usage of the debounce module its also ensured, that the button mashing (sending signals) will remain consistent.

## buzzer_module module
### Background
The nexys A7 50t board oscilator operates on a 100,000,000 frequency and we desire a 50% duty cycle square wave, which this module achieves (the actual HW508 buzzer lacks an internal oscillator).

### I/O ports of the `buzzer_module` module:

Table of signals coming into custom module ```buzzer_module ```:
| Port name | Direction | Type | Description |
|:---------|:---------:|:----|:-----------|
| `clk` | in | `std_logic` | Main clock (Target 100 MHz) |
| `en` | in | `std_logic` | Active-high enable and triggers the wave generation |
| `buzzer_out` | out | `std_logic` | Buzzer output (toggling square wave routed to the physical Pmod pin)|

- The module utilizes an internal counter to dived the incoming clock. Assuming a 100 MHz input clock, the default `C_MAX` constant of `25000` toggles the output pin every 25000 cycles. This creates a full wave every 50000 cycles, resulting in a 2 kHz square wave (100000000 / 50000 = 2000 Hz). The output give a 50% duty cycle for high audio volume and clarity.

Outcome of `buzzer_module_tb`:
![buzzer_module_tb](images/sim2_buzzer_module_tb.png)<br>
<i>Requires to manually change the C_MAX value in buzzer_module to 2 for simulation purposes</i>

The test provides us the following events:
- en (dark blue) signals us, that the buzzer should be turned on. In this case the duration is 300 ns
- buzzer_out (teal) the buzzer recieves 50% duty cycle square wave

### Conclusion
The test shows us, that the buzzer recieves 50% duty cycle square wave, when its enabled.

## JA Pmod connectors (Nexys A7)
In the actual realization for the buzzer to be functional, it is neccesary to note which actual port the buzzer (in our case HW508) should be connected. The constraint file is set to expect the buzzer in port C17:

`set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS33 } [get_ports {buzzer}];`

   | Pin | Signal | FPGA Pin | Description  |
   | :--: | :---- | :------- | :----------- |
   | 1   | JA1    | C17      | Data / IO    |

![pmods](images/pmod_connector.png)<br>
<i>Pmod connectors for nexys A7 50t</i>

![buzzer_pinout](images/passive_buzzer_pinout.jpg)<br>
<i>Reference on the buzzer pinout</i><br>
It is expected to connect the buzzer Signal pin to the rightmost corner of the JA pinout, the middle +5V pin to VCC pinout and the Ground on the GND pinout.


## Used hardware
The code runs on the <b>Nexys A7-50T</b> FPGA board.
![nexys_board](images/nexys_board.png)<br>
<i>Note: The board in question.</i>

## Top level schematics
Each button uses a different version of debouce module with instantations (hence the top level scheme contains `debounce_up`, `debounce_down`, etc.)
![rtl_schematic](images/rtl.png)<br>
<i>RTL analysis Schematic</i>

The top level being called `alarm_clock_top` <br>
![top_level_scheme](images/alarm_clock_scheme.png)<br>
<i>Top level scheme</i>

## Team members and the work
| Name | Responsibility |
| :--- | :------------- |
| [Patrik Malý](https://github.com/Patik05) | Responsible for the code, test benches and documentation. |
| [Radek Ondra](https://github.com/Radek-Ondra) | Responsible for the custom made top level schematic. |
| [Assiya Murat](https://github.com/assiya2305) | Responsible for the poster. |

## References
1. Digilent blog. [Nexys A7 Reference Manual](https://reference.digilentinc.com/reference/programmable-logic/nexys-a7/reference-manual)

2. Diligent. [General .xdc file for the Nexys A7-50T](https://github.com/Digilent/digilent-xdc/blob/master/Nexys-A7-50T-Master.xdc)

3. Tomas Fryza, vhdl-examples. [VHDL examples](https://github.com/tomas-fryza/vhdl-examples/tree/master)

4. Microcontrollerslab. [Image for the buzzer pinouts](https://microcontrollerslab.com/buzzer-module-interfacing-arduino-sound-code/)
