Meteoroid
=====================

TL;DR  —  An action-adventure in the “Metroidvania” style.


Building: `make` at the top level

Build requires: `64tass`, `sbcl`, and some other stuff.

Copyright © 2021, Bruce-Robert Pocock



https://star-hope.org/games/Meteoroid/

Credits
---------

Program, art, music, etc. — Bruce-Robert Pocock.



Includes  VCS header  file by  Matthew Dillon,  Olaf “Rhialto”  Seibert,
Andrew Davie, and Peter H. Froehlich (converted for 64tass syntax).
 
Binary-to-decimal translation  based upon  code by Andrew  Jacobs, based
upon code by Garth Wilson.

Some math  functions by  AtariAge Forum  user Omegamatrix;  others taken
from December 1984  Apple Assembly Line. (actually, I'm not  sure if I'm
using these, but they're in the macro files.)

“Have You Played Atari Today”  jingle transcribed by AtariAge Forum user
tiggerthehun and converted to MIDI myself.

And, of course thanks to everyone in the Stella and AtariAge communities
for making this game possible.



How To Build
---------------

First off,  you'll probably want a  Linux® system as this  build process
has  not been  tested under  macOS  and is  very unlikely  to work  with
Windows (since most of the tools are missing).

Make sure you have installed:

* SBCL (Steel Bank Common Lisp)
* Perl 5(.x)
* XeLaTeX
* 64tass (Turbo Assembler)
* GNU Make

and, to test:
* Stella

and, to burn EPROMS:
* MiniPro USB recording tools, a  MiniPro USB EPROM burner, and AT27C256
  EPROMs or compatible.

`cd` into the top-level directory and  run `make demo` to build the demo
software  for  all  three  regions  (NTSC,  PAL,  and  SECAM)  into  the
`Dist` directory.

To build and playtest, run `make  stella` for NTSC, or `make stella-pal`
or `make stella-secam` for the other regions.

To  burn an  EPROM,  run  `make cart-ntsc`,  `make  cart-pal`, or  `make
cart-secam`

If you  have a  Harmony or  Uno cartridge  and mount  the SD  card under
`/run/media/${USER}/HARMONY` or `/run/media/${USER}/TBA_2600`, which are
the  default  mount  points  and  SD disk  labels  for  those  platforms
respectively,  you can  write  to  the top  level  directory with  `make
harmony` or `make uno`.  It may be just as easy to  `make demo` and copy
the `.a26` files over directly.
