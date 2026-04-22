# BPC-DE1-Project
Project for the bachelor subject Digital Electronics 1, 2026 

## -- Main objective --
Creation of a working alarm clock. The maximum amount of time set being a whole day (23:59:59). After the time runs out, colored diode lights up (or buzzer).

### -- Secondary objective --
Implementation of a buzzer (HW-508)

### -- List of used components on  the board --
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

## -- Used hardware --
The code runs on the <b>Nexys A7-50T</b> FPGA board.
<img width="600" height="434" alt="obrazek" src="https://github.com/user-attachments/assets/14bbc566-4629-44aa-ba74-07658a58a81e" />
<i>Note: The board in question.</i>

## -- Top level scheme --
The top level being called ```Alarm_clock_top.vhd``` (will be corrected when we got to the lab back) <br>
<img width="785" height="651" alt="obrazek" src="https://github.com/user-attachments/assets/e2853872-2b62-443d-8ae2-a32b12ba2f4a" />
<i>Top level scheme - Still subject to change due to inconsistencies (one missing module)</i>
