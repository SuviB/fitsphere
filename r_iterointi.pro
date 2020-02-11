;+
;
;-

pro r_iterointi, th_0=th_0, ph_0=ph_0, Ar_o=Ar_o, Br_o=Br_o, A_rad=A_rad, B_rad=B_rad, framesa=framesa, framesb=framesb, framesc=framesc, obsdatea=obsdatea, obsdateb=obsdateb, obsdatec=obsdatec, stereofilesa=stereofilesa, stereofilesb=stereofilesb, sohofiles=sohofiles, points_a=points_a, points_b=points_b, points_c=points_c, Arcoord=Arcoord, Brcoord=Brcoord, Aradius=Aradius, Bradius=Bradius, t0=t0, edellinenminimir, avalir, bvalir

  print, ''
  print, 'Looking for the radius of the sphere and r-coordinate of the origin.'
  print, '--------------------------------------------------------------------'
  print, ''

  lt_0_flag = 0
  
  ; Haun alkuparametrejä:
  nrofruns = 3                 ;how many times iterated
  numberofrandompoints = 30     ;number of points tried on each run.
  avali=avalir
  bvali=bvalir
  edellinenminimi = edellinenminimir
  edellinenAr_o = Ar_o
  edellinenBr_o = Br_o
  edellinenArad = A_rad
  edellinenBrad = B_rad
  polttaa = 0
  kylmenee = 0
  
  Arcoord = Ar_o
  Brcoord = Br_o
  Aradius = A_rad
  Bradius = B_rad
  
  ;TÄSTÄ ALKAIS ETSINTÄKIERTO:
  for kierros=2, nrofruns+1 do begin
     print, "Beginning r-coordinate and radius iteration subround number ",$
            STRTRIM(kierros-1, 1),$
            " out of ", STRTRIM(nrofruns, 1), " with parameters:"
     print, 'Arcoord = ', strtrim(Arcoord, 1), $
            ', Brcoord = ', strtrim(Brcoord, 1), $
            ', Aradius = ', strtrim(Aradius, 1), $
            ', Bradius = ', strtrim(Bradius, 1)

     rndAr_o = fltarr(numberofrandompoints)
     rndBr_o = fltarr(numberofrandompoints)
     rndArad = fltarr(numberofrandompoints)
     rndBrad = fltarr(numberofrandompoints)
     Aseed = findgen(numberofrandompoints)
     Bseed = findgen(numberofrandompoints)*2
     for i=0, numberofrandompoints/4 do begin
        Brnd = randomu(Bseed[i], 1, 1)
        Brnd = (Brnd)*bvali
        Brnd1 = randomu(Bseed[i/2], 1, 1)
        Brnd1 = (Brnd1)*bvali
        Arnd = randomu(Aseed[i], 1, 1) 
        Arnd = (Arnd)*avali
        Arnd1 = randomu(Aseed[i/2], 1, 1) 
        Arnd1 = (Arnd1)*avali
        rndAr_o[i] = Arcoord + Arnd
        rndBr_o[i] = Brcoord + Brnd
        rndArad[i] = Aradius + Arnd1
        rndBrad[i] = Bradius + Brnd1
     endfor
     for i= (numberofrandompoints/4)+1, (numberofrandompoints/2)-1 do begin
        Brnd = randomu(Bseed[i], 1, 1)
        Brnd = (Brnd)*bvali
        Brnd1 = randomu(Bseed[i/2], 1, 1)
        Brnd1 = (Brnd1)*bvali
        Arnd = randomu(Aseed[i], 1, 1) 
        Arnd = (Arnd)*avali
        Arnd1 = randomu(Aseed[i/2], 1, 1) 
        Arnd1 = (Arnd1)*avali
        rndAr_o[i] = Arcoord - Arnd
        rndBr_o[i] = Brcoord - Brnd
        rndArad[i] = Aradius - Arnd1
        rndBrad[i] = Bradius - Brnd1
     endfor
     for i= numberofrandompoints/2, 3*numberofrandompoints/4  do begin
        Brnd = randomu(Bseed[i], 1, 1)
        Brnd = (Brnd)*bvali
        Brnd1 = randomu(Bseed[i/2], 1, 1)
        Brnd1 = (Brnd1)*bvali
        Arnd = randomu(Aseed[i], 1, 1) 
        Arnd = (Arnd)*avali
        Arnd1 = randomu(Aseed[i/2], 1, 1) 
        Arnd1 = (Arnd1)*avali
        rndAr_o[i] = Arcoord - Arnd
        rndBr_o[i] = Brcoord + Brnd
        rndArad[i] = Aradius - Arnd1
        rndBrad[i] = Bradius + Brnd1
     endfor
     for i= (3*numberofrandompoints/4)+1, numberofrandompoints-1 do begin
        Brnd = randomu(Bseed[i], 1, 1)
        Brnd = (Brnd)*bvali
        Brnd1 = randomu(Bseed[i/2], 1, 1)
        Brnd1 = (Brnd1)*bvali
        Arnd = randomu(Aseed[i], 1, 1) 
        Arnd = (Arnd)*avali
        Arnd1 = randomu(Aseed[i/2], 1, 1) 
        Arnd1 = (Arnd1)*avali
        rndAr_o[i] = Arcoord + Arnd
        rndBr_o[i] = Brcoord - Brnd
        rndArad[i] = Aradius + Arnd1
        rndBrad[i] = Bradius - Brnd1
     endfor
     
     errors = fltarr(numberofrandompoints,numberofrandompoints)
     for i=0, numberofrandompoints-1 do begin
        for j=0, numberofrandompoints-1 do begin
           ksi = 0

           ;A
           for k=1, n_elements(framesa)-1 do begin
              tmp = strsplit(framesa[k], ':', /extract, /regex)
              moment = (tmp[0]*3600) + (tmp[1]*60) -t0
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
              
              origo = [th_0, ph_0, rndAr_o[i] + rndBr_o[i] *moment]
              radius = rndArad[j] + rndBrad[j] *moment
              if radius lt 0 then begin
                 radius = 0.0
                 lt_0_flag = 1
              endif
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
              
              origo = [th_0, ph_0, rndAr_o[i] + rndBr_o[i] *moment]
              radius = rndArad[j] + rndBrad[j] *moment
              if radius lt 0 then begin
                 radius = 0.0
              endif
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
              
              origo = [th_0, ph_0, rndAr_o[i] + rndBr_o[i] *moment]
              radius = rndArad[j] + rndBrad[j] *moment
              if radius lt 0 then begin
                 radius = 0.0
              endif
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
     
     if lt_0_flag eq 1 then begin
        print, 'At least one of the tried radii was less than zero.'
        lt_0_flag = 0
     endif
     
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
        Arcoord = edellinenAr_o
        Brcoord = edellinenBr_o
        Aradius = edellinenArad
        Bradius = edellinenBrad
        avali = avali*1.5
        if avali gt Ar_o or avali gt A_rad then begin
           avali = avali/2.0
        endif
        bvali = bvali*1.5
        if bvali gt Br_o or bvali gt B_rad then begin
           bvali = bvali/2.0
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
        Arcoord = rndAr_o[i_index]
        Brcoord = rndBr_o[i_index] 
        Aradius = rndArad[j_index] 
        Bradius = rndBrad[j_index]
        edellinenAr_o = Arcoord
        edellinenBr_o = Brcoord
        edellinenArad = Aradius
        edellinenBrad = Bradius
        edellinenminimi = minimi
        avali = avali*0.5
        bvali = bvali*0.5
        print, " "
        print, " Going good, getting closer!"
        print, " "
     endif
     
     
  endfor

  
  print, STRTRIM(polttaa, 1),$
         " iteration rounds took a step closer to the final solution. On ", $
         STRTRIM(kylmenee, 1), $
         " iteration rounds solution wasn't getting closer."
  
  edellinenminimir = edellinenminimi
  avalir = avali
  bvalir = bvali
  
END
