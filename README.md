D.Y.S.P. using pre-calculated cycle table
=========================================

Simple D.Y.S.P. routine which uses a 256-byte table to determine how many
cycles to waste for each combination of sprites on a raster line.

Calculating how many cycles to waste on each line unfortunately takes a lot of
raster time, so for actual demo code using a fixed Y-sinus with a pre-calculated
'cycle-waste' table would be much faster, although far less flexible.

This is just a proof of concept, not demo ready, and way too old school.
I'm planning to use this for and article on
[codebase64.org](http://codebase64.org), once I've cleaned up the code a bit.


Assembling
----------

Use [64tass](https://sourceforge.net/projects/tass64/) to assemble:

`64tass -C -a -o dysp.prg main.asm`

Or use `make`. An additional target `make x64` exists, which will assemble the
code and then run [VICE](https://sourceforge.net/projects/vice-emu/)'s x64
binary to run the dysp. This will only work on Unix-like systems.


SID tune
--------

Included is a SID tune by JCH, a nice old school tune for an old school effect.


