;+
;takes the origin and radius of the sphere and transfers it to
;the coordinates of an image taken from a satellite. Units arcsec.
;-

pro picturecoords2, origo=origo, satth=satth, satph=satph, satdist=satdist,$
                   radius=radius, rx=rx, ry=ry, sade=sade



;print, "satth", satth
;print, "satph", satph
;print, "satdist", satdist

  
  ;phi(lat) to colat
  theta = origo[0]
  phi = 90 - origo[1]
  rorigo = origo[2]


  theta1=phi
  phi1=theta
  satth1=satph
  satph1=satth


  
  
  ;kierto:
  newx = rorigo*( [ sin(theta1*!dtor)*sin(satth1*!dtor)*cos((phi1*!dtor)-(satph1*!dtor)) ] - $
                  [cos(theta1*!dtor)*cos(satth1*!dtor)] )
  newy = rorigo *sin(theta1*!dtor) *sin((phi1*!dtor)-(satph1*!dtor))
  newz = rorigo*( [sin(theta1*!dtor)*cos(satth1*!dtor)*cos((phi1*!dtor)-(satph1*!dtor))] + $
                  [cos(theta1*!dtor)*sin(satth1*!dtor)] )


 ; print, 'newx,newy,newz',newx, newy, newz

  
  ;origo projisoituu näin:
  rx = 3600 * (180/!pi) *atan(newy/(satdist-newx))
  ry = 3600 * (180/!pi) *atan(newz/(satdist-newx))

;  print, 'rx,ry',rx,ry
  
  ;säde projisoituu näin:
  sade = 3600* (180/!pi) *atan( radius/sqrt((satdist-newx)*(satdist-newx) - radius*radius) )

 ; print, 'sade', sade

end
