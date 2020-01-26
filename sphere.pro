;+
;Projisoi annetun pallon kuvan taivaantasoon.
;
;Parametrit:
;satth, satph, satdist: Sateliitin sijainti pallokoordinaateissa.
;origin, radius: Projisoitavan pallon origo ja säde.
;kuvax, kuvay: Löydetyt pisteet kuvan koordinaateissa.
;
;Calls for: picturecoords.pro
;-

pro sphere, satth=satth, satph=satph, satdist=satdist, origin=origin, radius=radius, kuvax=kuvax, kuvay=kuvay

;  print, "origin:", origin

  picturecoords2, origo=origin, satth=satth, satph=satph, satdist=satdist,$
                 radius=radius, rx=rx, ry=ry, sade=sade

  
  ;pisteet ympyrän kehällä:
  ang = findgen(360)
  kuvax = fltarr(360)
  kuvay = fltarr(360)
  for i=0, 359 do begin
     kuvay[i] = ry+ sade*cos(!dtor*ang[i])
     kuvax[i] = rx+ sade*sin(!dtor*ang[i])
  endfor

  ;plotataan origo kuvaan:
  oplot, [rx], [ry], color=cgcolor('Green'), psym=1, symsize=4
  
end
