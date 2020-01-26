;+
;Fitting the parameters of the coordinates of the origin of the sphere
;by least-square method to the observations.
;-

pro dir_iterointi, th_0=th_0, ph_0=ph_0, framesa=framesa, framesb=framesb, framesc=framesc, obsdatea=obsdatea, obsdateb=obsdateb, obsdatec=obsdatec, stereofilesa=stereofilesa, stereofilesb=stereofilesb, sohofiles=sohofiles, points_a=points_a, points_b=points_b, points_c=points_c, Arcoord=Arcoord, Brcoord=Brcoord, Aradius=Aradius, Bradius=Bradius, t0=t0, direction, edellinenminimidir, validir

  print, ''
  print, 'Looking for the latitude and longitude of the origin.'
  print, '-----------------------------------------------------'
  print, ''
  
 ; Haun alkuparametrejä:
  nrofruns = 2                  ;how many times iterated
  numberofrandompoints = 30     ;number of points tried on each run.
  vali = validir
  edellinenminimi = edellinenminimidir
  edellinenth = th_0
  edellinenph = ph_0
  polttaa = 0
  kylmenee = 0

  th = th_0
  ph = ph_0
  
  ;TÄSTÄ ALKAIS ETSINTÄKIERTO:
  for kierros=2, nrofruns+1 do begin

     print, "Beginning iterationround number ", STRTRIM(kierros-1, 1),$
            " out of ", STRTRIM(nrofruns, 1), " with parameters:"
     print, "th_o = ", strtrim(th,1), ", ph_o = ", strtrim(ph,1)

     rndth = fltarr(numberofrandompoints)
     rndph = fltarr(numberofrandompoints)
     seed1 = findgen(numberofrandompoints)
     seed2 = findgen(numberofrandompoints)*2
     for i=0, numberofrandompoints/4 do begin
        thrnd = randomu(seed1[i], 1, 1)
        phrnd = randomu(seed2[i], 1, 1)
        rndth[i] = th + (thrnd)*vali
        if rndth[i] gt 360 then begin
           rndth[i] = th - (thrnd)*vali
        endif
        rndph[i] = ph + (phrnd)*vali
        if rndph[i] gt 90 then begin
           rndph[i] = ph - (phrnd)*vali
        endif
     endfor
     for i = (numberofrandompoints/4)+1, (numberofrandompoints/2)-1 do begin
        thrnd = randomu(seed1[i], 1, 1)
        phrnd = randomu(seed2[i], 1, 1)
        rndth[i] = th - (thrnd)*vali
        if rndth[i] lt 0 then begin
           rndth[i] = th + (thrnd)*vali
        endif
        rndph[i] = ph - ph*(phrnd)*vali
        if rndph[i] lt -90 then begin
           rndph[i] = ph + (phrnd)*vali
        endif
     endfor
     for i= numberofrandompoints/2, 3*numberofrandompoints/4 do begin
        thrnd = randomu(seed1[i], 1, 1)
        phrnd = randomu(seed2[i], 1, 1)
        rndth[i] = th + (thrnd)*vali
        if rndth[i] gt 360 then begin
           rndth[i] = th + (thrnd)*vali
        endif
        rndph[i] = ph + (phrnd)*vali
        if rndph[i] gt 90 then begin
           rndph[i] = ph - (phrnd)*vali
        endif
     endfor
     for i = (3*numberofrandompoints/4)+1, numberofrandompoints-1 do begin
        thrnd = randomu(seed1[i], 1, 1)
        phrnd = randomu(seed2[i], 1, 1)
        rndth[i] = th - (thrnd)*vali
        if rndth[i] lt 0 then begin
           rndth[i] = th + (thrnd)*vali
        endif
        rndph[i] = ph - ph*(phrnd)*vali
        if rndph[i] lt -90 then begin
           rndph[i] = ph - (phrnd)*vali
        endif
     endfor

     errors = fltarr(numberofrandompoints,numberofrandompoints)
     for i=0, numberofrandompoints-1 do begin
        for j=0, numberofrandompoints-1 do begin
           ksi = 0

           ;A
           for k=1, n_elements(framesa)-1 do begin
              tmp = strsplit(framesa[k], ':', /extract, /regex)
              moment = tmp[0]*3600 + tmp[1]*60 -t0
              ;Look for the frame:
              frame1 = where(strmatch(obsdatea[0,*], '*'+framesa[k]+':*'))
              
              aimg1 = stereofilesa[frame1[0]]
              mreadfits, aimg1, aindex1, aimage1, /quiet
              wcsa = fitshead2wcs( aindex1 )
              asatph = wcsa.position.hglt_obs
              asatph = 90 - asatph ;latitude to colatitude 
              asatth = wcsa.position.hgln_obs
              asatdist = wcsa.position.dsun_obs
              array = READ_CSV( framesa[k] + points_a + '.csv', count=count)
              a_points = [[array.(0)],[array.(1)]]
              
              origo = [rndth[j], rndph[i], Arcoord + Brcoord *moment]
              radius = Aradius + Bradius *moment
              picturecoords2, origo=origo, satth=asatth, satph=asatph, $
                             satdist=asatdist, radius=radius, rx=rxa, ry=rya,$
                             sade=sadea
              ;d ja r:
              for l=0, n_elements(a_points[*,0])-1 do begin
                 ad = sqrt( (a_points[l,0]-rxa)*(a_points[l,0]-rxa) + $
                            (a_points[l,1]-rya)*(a_points[l,1]-rya) )
                 ar = sadea
                 ksi = ksi + (ad-ar)*(ad-ar)
              endfor
           endfor
           
           ;B
           for k=1, n_elements(framesb)-1 do begin
              tmp = strsplit(framesb[k], ':', /extract, /regex)
              moment = tmp[0]*3600 + tmp[1]*60-t0
              ;Look for the frame:
              frame1 = where(strmatch(obsdateb[0,*], '*'+framesb[k]+':*'))
              
              bimg1 = stereofilesb[frame1[0]]
              mreadfits, bimg1, bindex1, bimage1, /quiet
              wcsb = fitshead2wcs( bindex1 )
              bsatph = wcsb.position.hglt_obs
              bsatph = 90 - bsatph ;latitude to colatitude 
              bsatth = wcsb.position.hgln_obs
              bsatdist = wcsb.position.dsun_obs
              array = READ_CSV( framesb[k] + points_b + '.csv', count=count)
              b_points = [[array.(0)],[array.(1)]]
              
              origo = [rndth[j], rndph[i], Arcoord + Brcoord *moment]
              radius = Aradius + Bradius *moment
              picturecoords2, origo=origo, satth=bsatth, satph=bsatph, $
                             satdist=bsatdist, radius=radius, rx=rxb, ry=ryb,$
                             sade=sadeb
              ;d ja r:
              for l=0, n_elements(b_points[*,0])-1 do begin
                 bd = sqrt( (b_points[l,0]-rxb)*(b_points[l,0]-rxb) + $
                            (b_points[l,1]-ryb)*(b_points[l,1]-ryb) )
                 br = sadeb
                 ksi = ksi + (bd-br)*(bd-br)
              endfor
           endfor

           ;C
           for k=1, n_elements(framesc)-1 do begin
              tmp = strsplit(framesc[k], ':', /extract, /regex)
              moment = tmp[0]*3600 + tmp[1]*60-t0
              ;Look for the frame:
              frame1 = where(strmatch(obsdatec[0,*], '*'+framesc[k]+':*'))
              
              cimg1 = sohofiles[frame1[0]]
              mreadfits, cimg1, cindex1, cimage1, /quiet
              wcsc = fitshead2wcs( cindex1 )
              csatph = wcsc.position.hglt_obs
              csatph = 90 - csatph ;latitude to colatitude 
              csatth = wcsc.position.hgln_obs
              csatdist = wcsc.position.dsun_obs
              array = READ_CSV( framesc[k] + points_c + '.csv', count=count)
              c_points = [[array.(0)],[array.(1)]]
              
              origo = [rndth[j], rndph[i], Arcoord + Brcoord *moment]
              radius = Aradius + Bradius *moment
              picturecoords2, origo=origo, satth=csatth, satph=csatph, $
                             satdist=csatdist, radius=radius, rx=rxc, ry=ryc,$
                             sade=sadec
              ;d ja r:
              for l=0, n_elements(c_points[*,0])-1 do begin
                 cd = sqrt( (c_points[l,0]-rxc)*(c_points[l,0]-rxc) + $
                            (c_points[l,1]-ryc)*(c_points[l,1]-ryc) )
                 cr = sadec
                 ksi = ksi + (cd-cr)*(cd-cr)
              endfor
           endfor

           errors[i,j]=ksi
           
          ;laskuri:
           pros = (i*1.0/(numberofrandompoints-1))*100
           esc = string(27B)
           print, esc + '[24D' + esc + '[K', format='(A, $)'
           print, pros, format='(I3, "%", $)'


        endfor
     endfor
    
     minimi = min(errors, /NAN)

     print, ' '
     print, "minimi:", minimi
     
     if edellinenminimi eq 0.0 then begin
        edellinenminimi = minimi
     endif
     vertmin = edellinenminimi
     if minimi ge vertmin then begin
        kylmenee = kylmenee +1
        edellinenminimi = vertmin
        th = edellinenth
        ph = edellinenph
        vali = vali*1.5
        if vali gt 90 then begin
           vali = 90
        endif
        print, " "
        print, " Not getting closer."
        print, " " 
     endif
     if minimi lt vertmin then begin
        polttaa = polttaa +1
        for i=0, numberofrandompoints-1 do begin
           for j=0, numberofrandompoints-1 do begin
              if errors[i,j] eq minimi then begin
                 i_index = i
                 j_index = j
              endif
           endfor
        endfor
        ph = rndph[i_index]
        th = rndth[j_index]
        edellinenth = th
        edellinenph = ph
        edellinenminimi = minimi
        vali = vali*0.5
        print, " "
        print, " Going good, getting closer!"
        print, " "
     endif
     
  endfor
  
  print, STRTRIM(polttaa, 1),$
         " iteration rounds took a step closer to the final solution. On ", $
         STRTRIM(kylmenee, 1), $
         " iteration rounds solution wasn't getting closer."  

  direction = [th,ph]
  edellinenminimidir = edellinenminimi
  validir = vali

END
