D.Y.S.P. using pre-calculated cycle table
=========================================

Simple D.Y.S.P. routine which uses a 256-byte table to determine how many
cycles to waste for each combination of sprites on a raster line.

Calculating how many cycles to waste on each line unfortunately takes a lot of
raster time, so for actual demo code using a fixed Y-sinus with a pre-calculated
'cycle-waste' table would be much faster, although far less flexible.

This is just a proof of concept, right now, it's a bit of a mess.


Assembling
----------

Use 64tass to assemble: `64tass -C -a -o demo.prg main.asm`, or use `make`.


SID tune
--------

The code references a sid tune to make sure we get proper raster jitter to
stress test the stable raster routine. Unless you have your HVSC at
`/home/compyx/c64/HVSC`, assembling will fail, so comment out any references
to the tune.


