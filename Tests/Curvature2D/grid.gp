#set term x11
set term aqua size 846,646
set xrange [0.:0.8]
set yrange [0.:0.8]
set multiplot
plot "grid.txt" w vec nohead lt 0
set parametric
set trange [0:2*pi]
# Parametric functions for a circle
fx(t) = 0.2*cos(t) + 0.475
fy(t) = 0.2*sin(t) + 0.475
plot fx(t),fy(t) lt 1
plot "segments.txt" w vec nohead lt 3
plot "points.txt" lw 3

# pause 100