# BPC-DE1-Project
Project for the bachelor subject Digital Electronics 1, 2026 <br>

## Main objective 
Creation of a working alarm clock. The maximum amount of time set being a whole day (23:59:59). After the time runs out, colored diode lights up and buzzer. The user should be able to increase/decrease time either by seconds, minutes and hours. After setting time and running the alarm clock, the user is blocked to manipulate the time (unless the time is stopped).

### List of used components on  the board
<table>
  <thead>
      <tr>
        <th>
      Component
        </th>
        <th>
      Function
        </th>
      </tr>
  </thead>
  <tr>
    <td>
      Up button
    </td>
    <td>
      Increases time value
    </td>
  </tr>
  <tr>
    <td>
      Down button
    </td>
    <td>
      Decreases time value
    </td>
  </tr>
  <tr>
    <td>
      Center button
    </td>
    <td>
      Starts the alarm clock/stops the countdown, stops the RGB diode signal after its been turned on
    </td>
  </tr>
  <tr>
    <td>
      Left button
    </td>
    <td>
      Resets the time
    </td>
  </tr>
  <tr>
    <td>
      Right button
    </td>
    <td>
      Changes the time incrementation/decrementation (by seconds, minutes, hours)
    </td>
  </tr>
  <tr>
    <td>
      6x 7 segment displays
    </td>
    <td>
      Displays the time in HH:MM:SS format
    </td>
  </tr>
  <tr>
    <td>
      RGB diode
    </td>
    <td>
      Signals when the time has run out
    </td>
  </tr>
</table>

## Custom modules
The project contains new custom modules wrapped into  ```alarm_clock_top ``` top level:
<ul>
  <li>
``alarm_clock ```
  </li>
  <li>
```buzzer_module ```
  </li>
</ul>

Table of signal coming into module ```alarm_clock ```:
| Port name | Direction | Type | Description |
|:---------:|:---------:|:----:|:-----------:|
| clk | in | std_logic | Main clock |
| sig_reset | in |  std_logic | Resets clock to 00:_00:00|
| sig_in | in |  std_logic | Increment time |
| sig_dec | in |  std_logic | Decrement time |
| sig_mode | in |  std_logic | Cycle edit mode (sec -> min -> hr) |
| sig_play_pause | in |  std_logic | Toggle countdown/silence alarm |
| ce_1hz | in |  std_logic | 1 Hz enable pulse for real-time counting |
| disp_data | out |  std_logic_vector(23 downto 0) | Packed BCD for displays |
| alarm_active | out |  std_logic | Activates when timer hits 0 |

Table of signal coming into module ```buzzer_module ```:
| Port name | Direction | Type | Description |
|:---------:|:---------:|:----:|:-----------:|
| clk | in | std_logic | Main clock |
| en | in | std_logic | Enable |
| buzzer_out | out | std_logic | Buzzer output |

## Test benches
```alarm_clock_tb```
<img width="1130" height="311" alt="image" src="https://github.com/user-attachments/assets/b0ef155d-4c35-462a-9485-50e8ccf6194d" />


```buzzer_module:tb```
<img width="974" height="159" alt="image" src="https://github.com/user-attachments/assets/db3c7fa3-a3d6-47c1-a542-b50b61c34eca" />
<i>Requires to manually change the C_MAX value in buzzer_module to 2 for simulation purposes</i>

RTL analysis Schematic
<img width="1025" height="638" alt="image" src="https://github.com/user-attachments/assets/7fb00ab4-e502-406d-8be2-2bc1809ae96c" />




## Used hardware
The code runs on the <b>Nexys A7-50T</b> FPGA board.
<img width="600" height="434" alt="obrazek" src="https://github.com/user-attachments/assets/14bbc566-4629-44aa-ba74-07658a58a81e" />
<i>Note: The board in question.</i>

## Top level scheme
The top level being called ```alarm_clock_top.vhd``` (will be corrected when we got to the lab back) <br>
<img width="7974" height="6768" alt="Schema_Script (1)" src="https://github.com/user-attachments/assets/ef1b1eff-767a-4138-9cea-7e517a7f0d5c" />
<i>Top level scheme </i>




