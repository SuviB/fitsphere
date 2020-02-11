# fitsphere
IDL code to fit parameters of a sphere as a function of time to CME (Coronal mass ejection) observations.

Input:
- date       = date of the event.
- start      = starting time.
- stop       = time of the last image to be considered.
- Ar_o, Br_o = r-coordinate of the sphere origin is given by: r_o = Ar_o + Br_o t ,
              good values to begin with could be: Ar_o=100, Br_o=5e+5
- th_o       = latitude of the origin, direction of the propagation.
- ph_o       = longitude of the origin, direction of the propagation.
- Arad, Brad = radius of the sphere is given by R = Arad + Brad * t.
- points_a   = a tag for the name of the file where points will be saved for the images from STEREOA.
- points_b   = a tag for the name of the file where points will be saved for the images from STEREOB.
- points_c   = a tag for the name of the file where points will be saved for the images from SOHO.

The CME observations (.fits) should be stored in the archive they come in from VSO in the same directory as the code.
- STEREO A: archive/secchi/L0/a/seq/cor2/date/ and archive/secchi/L0/a/seq/cor1/date/
- STEREO B: archive/secchi/L0/b/seq/cor2/date/ and archive/secchi/L0/b/seq/cor1/date/
- SOHO: archive/soho/private/data/processed/lasco/level_05/date/c2/ and archive/soho/private/data/processed/lasco/level_05/'+ sohodate+ '/c3/

Output:
- final parameters for 
- Ar_o, Br_o = Arcoord, Brcoord, give the r-coordinate of the sphere origin as function of time.
- th_o, ph_o, these are not a function of time. 
- Arad, Brad = Aradius, Bradius, give the radius of the sphere as function of time.
- On screen images of the sphere plotted on the observations before and after the fitting. (not saved)

Conclusions:
- Speed of the tip of the CME (m/s) can be obtained by summing up: Br_o + Brad
- Shape and location of the sphere can be found as function of time (s) since the start time.
