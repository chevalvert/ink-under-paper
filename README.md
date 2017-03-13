<p align="center">
  <img src="preview.gif?raw=true">
</p>
<p align="right">
  <a href="http://chevalvert.fr/">
    <img src="https://avatars0.githubusercontent.com/u/7009492?v=3&s=75&raw=true" alt="Chevalvert">
  </a>
</p>

## Sketch global options

| variable name             | description |
| :------------------------ | :---------- |
| `FULLSCREEN`              | _launch the sketch in fullscreen_
| `DEBUG`                   | _enable debug trace_
| `SMT_MIRROR_X`            | _mirror the SMT on the X axis_
| `SMT_MIRROR_Y`            | _mirror the SMT on the Y axis_
| `COLOR_ALIVE`             | _cell's color when alive_
| `COLOR_DEAD `             | _cell's color when dying_
| `CELL_RESOLUTION`         | _the cell's size in pixels_
| `CELL_LIFESPAN_MAX`       | _the cell will grow until reaching this value_
| `CELL_LIFESPAN_START`     | _the start value of a newborn cell<br>(the cell will be considered dead bellow this value)_
| `CELL_LIFESPAN_INCREMENT` | _how fast the cell's life increases_
| `CELL_LIFESPAN_DECREMENT` | _how fast the cell's life decreases_
| `GROW_RATE_THRESHOLD`     | _the percent of max screen occupation_
| `GROW_RATE_MIN`           | _the minimum growing rate of a flood (between 0 and 1)_
| `GROW_RATE_MAX`           | _the maximum growing rate of a flood (between 0 and 1)_