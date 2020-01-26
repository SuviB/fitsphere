;+
;Purpose:
;To find what kind of a sphere fits to the pictures of CME.
;
;Way:
;Finds files close to a given time, plots them as basetimediff or
;runtimediff.
;then plots on the pictures a projection of the sphere, given parameters.
;
;Parameters:
;date = 'yyyymmdd'
;time = 'hh:mm'
;coordinates in Stonyhurst:
;Ar_o,Br_o = r--coordinate of the origin (units meters)
;th_o = latitude [deg], origo coordinate
;ph_o = longitude [deg], origo coordinate
;Arab,Brad = radius [solar radius] of the sphere (unit meters)
;
;Calls for: listSTEREO.pro, findfile.pro, runtimediff.pro,
;listSOHO.pro, pointsonthecircle.pro,
;sphere.pro, r_iterointi.pro, dir_iterointi.pro
;-

;Calling sequence:
;fittingsphere, date='20140225', start='00:45', stop='02:00', Ar_o=1, Br_o=1, ph_o=1, th_o=1, Arad=2, Brad=0,  runtimediff=1, points_a='a', points_b='b', points_c='c'


pro fittingsphere, date=date, start=start, stop=stop, $
                   Ar_o=Ar_o, Br_o=Br_o, ph_o=ph_o, th_o=th_o,$
                   Arad=Arad, Brad=Brad,$
                   runtimediff=runtimediff, points_a=points_a, $
                   points_b=points_b, points_c=points_c

  
  ;PARAMETERS:
  t0 = 09*3600 + 00*60          ;Beginning of the event in seconds from 00:00UT
  kierroksia = 10

  
  if runtimediff eq 1 then begin
     basetimediff = 0
  endif else begin
     basetimediff = 1
  endelse
    
  ;files is a list of the files and their paths from one day.
  listSTEREO, stereoa=1, stereob=1, date=date, stereofilesa, stereofilesb
  listSOHO, date=date, sohofiles
  
  ;observation times and dates (and polarisation) into an array:
  obsdatea= strarr(3,n_elements(stereofilesa))
  for i=0, n_elements(stereofilesa)-1 do begin
     mreadfits, stereofilesa[i], indexa, /quiet, /nodata
     obsdatea[0,i] = indexa.DATE_obs
     obsdatea[1,i] = indexa.POLAR
     obsdatea[2,i] = indexa.DETECTOR
  endfor
  obsdateb= strarr(3,n_elements(stereofilesb))
  for i=0, n_elements(stereofilesb)-1 do begin
     mreadfits, stereofilesb[i], indexb, /quiet, /nodata
     obsdateb[0,i] = indexb.DATE_obs
     obsdateb[1,i] = indexb.POLAR
     obsdateb[2,i] = indexb.DETECTOR
  endfor
  obsdatec = strarr(3,n_elements(sohofiles))
  for i=0, n_elements(sohofiles)-1 do begin
     mreadfits, sohofiles[i], index, /quiet, /nodata
     obsdatec[0,i] = index.DATE_obs
     obsdatec[1,i] = index.POLAR
     obsdatec[2,i] = index.DETECTOR
  endfor
     
  ;tags to be changed to 1 if there's no (valid) data.
  dontusea = 0
  dontuseb = 0
  dontusec = 0

  framesa = strarr(1)
  framesb = strarr(1)
  framesc = strarr(1)
  diffframesa = strarr(1)
  diffframesb = strarr(1)
  diffframesc = strarr(1)
  
  time = start
  window = 0

  if stereofilesa[0] ne '' then begin
     print, ' '
     print, ' + STEREO A '
     print, '-------------'
     print, ' '
     
     tmp = strsplit(stop, ':', /extract, /regex)
     endtime = tmp[0]*3600 + tmp[1]*60 -t0
     tmp = strsplit(start, ':', /extract, /regex)
     moment = tmp[0]*3600 + tmp[1]*60 -t0
     while moment lt endtime do begin

        print, ''
        
        ;Find the frame closest to the given time:
        findfile, obsdate=obsdatea, time=time, frame1=frame1, newtime=newtime, $
                  nexttime=nexttime
        tmp = strsplit(newtime, ':', /extract, /regex)
        moment = tmp[0]*3600 + tmp[1]*60 -t0
        
        if frame1 ge 0 then begin
        
           aimg1 = stereofilesa[frame1]
           mreadfits, aimg1, aindex1, aimage1, /quiet
           ;with this time look for the frame to be subtracted:
           basetime=newtime
           polarisationa = aindex1.POLAR
           detectora = aindex1.DETECTOR
        
           ;base time difference substraction frame
           if basetimediff eq 1 then begin
              for i=0, n_elements(obsdatea[0,*])-1 do begin
                 if obsdatea[1,i] eq polarisationa and $
                    obsdatea[2,i] eq detectora then begin
                    adiff_frame=i
                    print, 'Found a time difference frame at: ', obsdatea[0,i]
                    i=n_elements(obsdatea)
                 endif
              endfor
           endif
        
           ;run time difference subtraction frame
           if runtimediff eq 1 then begin
              runtimediff, obsdate=obsdatea, time=basetime, frame=frame, $
                           polarisation=polarisationa, detector=detectora
              adiff_frame = frame
           endif

           if adiff_frame ge 0 then begin
              ;Find the time difference frame:
              aimg2 = stereofilesa[adiff_frame]
              mreadfits, aimg2, aindex2, aimage2, /quiet
  
              ;to maps
              index2map, aindex1, aimage1, amap1
              index2map, aindex2, aimage2, amap2

              ;plot
              adiff = diff_map(amap1, amap2, rotate=rotate)
              wdel, window 
              wdef, window, 600, /uright
              window = window + 1
              plot_map, adiff, /log, /cbar

              ;Check if the user wants to use this frame:
              B=''
              READ, B, PROMPT='Use this frame from STEREO Ahead? [y/n]: '
              if B eq 'n' or B eq 'N' or B eq 'no' or B eq 'No' or $
              B eq 'NO' then begin
                 dontusea = -1
                 window = window-1
                 wdel, window
              endif
              if B eq 'y' or B eq 'Y' or B eq 'YES' or B eq 'Yes' or $
              B eq 'yes' then begin
                 dontusea = 1
              endif
              if (B ne 'n') && (B ne 'N') && (B ne 'no') && (B ne 'No') && $
                 (B ne 'y') && (B ne 'Y') && (B ne 'yes') && (B ne 'Yes') && $
                 (B ne 'YES') && (B ne 'NO') then begin
                 READ, B, PROMPT='Answer [y/n]: '
                 if B eq 'n' or B eq 'N' or B eq 'no' or B eq 'No' or $
                    B eq 'NO' then begin
                    dontusea = -1
                    window = window-1
                    wdel, window
                 endif
                 if B eq 'y' or B eq 'Y' or B eq 'YES' or B eq 'Yes' or $
                    B eq 'yes' then begin
                    dontusea = 1
                 endif
              endif
              print, ' '

              if dontusea eq 1 then begin
                 
                 ;Check if there's a file with points to fit to:
                 file = file_search( newtime + points_a + '.csv')
                 if strlen(file[0]) gt 7 then begin
                    array = READ_CSV( newtime + points_a + '.csv', count=count)
                    a_points = fltarr(2, n_elements(array.(0)))
                    for i=0, 1 do begin
                       a_points[i,*] = array.(i)
                    endfor
                    oplot, a_points[0,*], a_points[1,*], color=cgcolor('Red'),$
                           psym=1, symsize=1
                 endif
                 ;If no, ask user to pick:
                 if strlen(file[0]) lt 8 then begin
                    ;choose the points to be used for fitting the sphere.
                    pointsonthecircle, points=a_points
                    write_csv, newtime + points_a + '.csv', a_points
                 endif

                 ;  Satellite location:
                 wcsa = fitshead2wcs( aindex1 )
                 asatph = wcsa.position.hglt_obs
                 asatph = 90 - asatph
                 asatth = wcsa.position.hgln_obs
                 asatdist = wcsa.position.dsun_obs

                 ;print, "sat phi(colat) =", asatph
                 ;print, "sat theta =", asatth
                 
                 givenorigo = [th_o, ph_o, Ar_o + Br_o *moment]
                 radius = Arad + Brad *moment
                 ;find the projection and plot it:
                 sphere, satth=asatth, satph=asatph, satdist=asatdist,$
                         origin=givenorigo, radius=radius, kuvax=akuvax,$
                         kuvay=akuvay
                 oplot, akuvax, akuvay, color=cgcolor('Blue'), psym=1,$
                        linestyle=0, symsize=1


                 

                 ;Save a weight for the points in the picture, later khi can
                 ;be multipliedby this.
                 
    ;             READ, A, PROMPT='Give a weight for this image [0,1]'
    ;             test = isnumber(A)
    ;             if A ge 1 or A le 0 or test eq 0 then begin
    ;                READ, A, PROMPT='Please give a value between 0 and 1.'
    ;             end
    ;             if A le 1 or A ge 0 then begin
    ;                write_csv, newtime + weight_a + '.csv', A
    ;             endif
                 


                 
                 
              endif
           endif
           
           if adiff_frame eq -1 then begin
              dontusea = -1
           endif
           if frame1 eq -1 then begin
              dontusea = -1
           endif
           
        endif
        
        if dontusea eq 1 then begin
           framesa = [framesa, newtime]
           diffframesa = [diffframesa, obsdatea[0,adiff_frame]]
        endif
           
        dontusea = 0
        time = nexttime
        print, '---'
     endwhile
  
  endif
  if  stereofilesa[0] eq '' then begin
     print, ' '
     print, 'No data from STEREO A found.'
     print, ' '
     dontusea = -1
  endif
  
  if  stereofilesb[0] ne '' then begin
     print, ' '
     print, ' + STEREO B '
     print, '-------------'
     print, ' ' 
     
     tmp = strsplit(stop, ':', /extract, /regex)
     endtime = tmp[0]*3600 + tmp[1]*60 -t0
     tmp = strsplit(start, ':', /extract, /regex)
     moment = tmp[0]*3600 + tmp[1]*60 -t0
     time = start
     while moment lt endtime do begin

        print, ''
        
        ;Find the frame closest to the given time:
        findfile, obsdate=obsdateb, time=time, frame1=frame1, newtime=newtime, $
                  nexttime=nexttime
        tmp = strsplit(newtime, ':', /extract, /regex)
        moment = tmp[0]*3600 + tmp[1]*60 -t0
        
        if frame1 ge 0 then begin
           bimg1 = stereofilesb[frame1]
           mreadfits, bimg1, bindex1, bimage1, /quiet
           ;with this time look for the frame to be subtracted:
           basetime=newtime
           polarisationb = bindex1.POLAR
           detectorb = bindex1.DETECTOR
 
           ;base time difference substraction frame
           if basetimediff eq 1 then begin
              for i=0, n_elements(obsdateb[0,*])-1 do begin
                 if obsdateb[1,i] eq polarisationb and $
                    obsdateb[2,i] eq detectorb then begin
                    bdiff_frame=i
                    print, 'Found a time difference frame at: ', obsdateb[0,i]
                    print, ''
                    i=n_elements(obsdateb)
                 endif
              endfor
           endif
        
           ;run time difference subtraction frame
           if runtimediff eq 1 then begin
              runtimediff, obsdate=obsdateb, time=basetime, frame=frame,$
                           polarisation=polarisationb, detector=detectorb
              bdiff_frame=frame
           endif
           
           if bdiff_frame ge 0 then begin
              ;Find the time difference frame:
              bimg2 = stereofilesb[bdiff_frame]
              mreadfits, bimg2, bindex2, bimage2, /quiet
     
              ;to maps
              index2map, bindex1, bimage1, bmap1
              index2map, bindex2, bimage2, bmap2
 
              ;plot
              bdiff=diff_map(bmap1, bmap2, rotate=rotate)
              wdel, window
              wdef, window, 600, /lright
              window = window +1
              plot_map, bdiff, /log, /cbar

              ;Check if the user wants to use this frame:
              B=''
              READ, B, PROMPT='Use this frame from STEREO Behind? [y/n]: '
              if B eq 'n' or B eq 'N' or B eq 'no' or B eq 'No' or $
                 B eq 'NO' then begin
                 dontuseb = -1
                 window = window-1
                 wdel, window
              endif
              if B eq 'y' or B eq 'Y' or B eq 'yes' or B eq 'Yes' or $
                 B eq 'YES' then begin
                 dontuseb = 1
              endif
              if (B ne 'n') && (B ne 'N') && (B ne 'no') && (B ne 'No') && $
                 (B ne 'y') && (B ne 'Y') && (B ne 'yes') && (B ne 'Yes') && $
                 (B ne 'YES') && (B ne 'NO') then begin
                 READ, B, PROMPT='Answer [y/n]: '
                 if B eq 'n' or B eq 'N' or B eq 'no' or B eq 'No' or $
                    B eq 'NO' then begin
                    dontuseb = -1
                    window = window-1
                    wdel, window
                 endif
              if B eq 'y' or B eq 'Y' or B eq 'yes' or B eq 'Yes' or $
                 B eq 'YES' then begin
                 dontuseb = 1
              endif
              endif
              print, ''
              
              if dontuseb eq 1 then begin
                 
                 ;Check if there's a file with points to fit to:
                 file = file_search( newtime + points_b + '.csv')
                 if strlen(file[0]) gt 7 then begin
                    array = READ_CSV( newtime + points_b + '.csv', count=count)
                    b_points = fltarr(2, n_elements(array.(0)))
                    for i=0, 1 do begin
                       b_points[i,*] = array.(i)
                    endfor
                    oplot, b_points[0,*], b_points[1,*], color=cgcolor('Red'),$
                           psym=1, symsize=1
                 endif
                 ;If no, ask user to pick:
                 if strlen(file[0]) lt 8 then begin
                    ;choose the points to be used for fitting the sphere.
                    pointsonthecircle, points=b_points
                    write_csv, newtime + points_b + '.csv', b_points
                 endif
 
                 ;Satellite location:
                 wcsb = fitshead2wcs( bindex1 )
                 bsatph = wcsb.position.hglt_obs 
                 bsatph = 90 - bsatph
                 bsatth = wcsb.position.hgln_obs
                 bsatdist = wcsb.position.dsun_obs
                 
                 ;print, "sat phi(colat) =", bsatph
                 ;print, "sat theta =", bsatth
    
                 givenorigo = [th_o, ph_o, Ar_o + Br_o *moment]
                 radius = Arad + Brad *moment
                 ;Find the projection and plot it.
                 sphere, satth=bsatth, satph=bsatph, satdist=bsatdist,$
                         origin=givenorigo, radius=radius, kuvax=bkuvax, $
                         kuvay=bkuvay
                 oplot, bkuvax, bkuvay, color=cgcolor('Blue'), psym=1,$
                        linestyle=0, symsize=1
              endif
         
           endif
           
           if bdiff_frame eq -1 then begin
              dontuseb = -1
           endif
           if frame1 eq -1 then begin
              dontuseb = -1
           endif
           
        endif
        
        if dontuseb eq 1 then begin
           framesb = [framesb, newtime]
           diffframesb = [diffframesb, obsdateb[0,bdiff_frame]]
        endif
        
        dontuseb = 0
        time = nexttime
        print, '---'
        
   endwhile

  endif
  
  if stereofilesb[0] eq '' then begin
     print, ' '
     print, 'No data from STEREO B found.'
     print, ' '
  endif  

  if sohofiles[0] ne '' then begin
     print, ' '
     print, ' + SOHO '
     print, '---------'
     print, ' '
   
     tmp = strsplit(stop, ':', /extract, /regex)
     endtime = tmp[0]*3600 + tmp[1]*60 -t0
     tmp = strsplit(start, ':', /extract, /regex)
     moment = tmp[0]*3600 + tmp[1]*60 -t0
     time = start
     
     while moment lt endtime do begin

        print, ''            
        
        ;Find the frame closest to the given time:
        findfile, obsdate=obsdatec, time=time, frame1=frame1, newtime=newtime, $
                nexttime=nexttime
        tmp = strsplit(newtime, ':', /extract, /regex)
        moment = tmp[0]*3600 + tmp[1]*60 -t0
        
        if frame1 ge 0 then begin
           img1 = sohofiles[frame1]
           mreadfits, img1, index1, image1, /quiet
           ;with this time look for the frame to be subtracted:
           basetime = newtime
           polarisationc = index1.POLAR
           detectorc = index1.DETECTOR
           
           ;base time difference substraction frame
           if basetimediff eq 1 then begin
              for i=0, n_elements(obsdatec[0,*])-1 do begin
                 if obsdatec[1,i] eq polarisationc and $
                    obsdatec[2,i] eq detectorc then begin
                    sohodiff_frame=i
                    print, 'Found a time difference frame at: ', obsdatec[0,i]
                    i=n_elements(obsdatec)
                 endif
              endfor
           endif
        
           ;runtime difference subtraction frame
           if runtimediff eq 1 then begin
              runtimediff, obsdate=obsdatec, time=basetime, frame=frame,$
                           polarisation=polarisationc, detector=detectorc
              sohodiff_frame=frame
           endif

           if sohodiff_frame ge 0 then begin
              ;Find the time difference frame:
              img2 = sohofiles[sohodiff_frame]
              mreadfits, img2, index2, image2, /quiet
           
              ;to maps
              index2map, index1, image1, map1
              index2map, index2, image2, map2

              ;plot
              diff=diff_map(map1, map2, rotate=rotate)
              wdel, window
              wdef, window, 600, /uright
              window = window +1
              plot_map, diff, /log, /cbar

              ;Check if the user wants to use this frame:
              B=''
              READ, B, PROMPT='Use this frame from SOHO? [y/n]: '
              if B eq 'n' or B eq 'N' or B eq 'no' or B eq 'No' or $
                 B eq 'NO' then begin
                 dontusec = -1
                 window = window-1
                 wdel, window
              endif
              if B eq 'y' or B eq 'Y' or B eq 'yes' or B eq 'Yes' or $
                 B eq 'YES' then begin
                 dontusec = 1
              endif
              if (B ne 'n') && (B ne 'N') && (B ne 'no') && (B ne 'No') && $
                 (B ne 'y') && (B ne 'Y') && (B ne 'yes') && (B ne 'Yes') && $
                 (B ne 'YES') && (B ne 'NO') then begin
                 READ, B, PROMPT='Answer [y/n]: '
                 if B eq 'n' or B eq 'N' or B eq 'no' or B eq 'No' or $
                    B eq 'NO' then begin
                    dontusec = -1
                    window = window-1
                    wdel, window
                 endif
                 if B eq 'y' or B eq 'Y' or B eq 'yes' or B eq 'Yes' or $
                    B eq 'YES' then begin
                    dontusec = 1
                 endif
              endif
              print, ''
              
              if dontusec eq 1 then begin
                 
                 ;Check if there's a file with points to fit to:
                 file = file_search(newtime + points_c + '.csv')
                 if strlen(file[0]) gt 7 then begin
                    array = READ_CSV(newtime + points_c + '.csv', count=count)
                    c_points = fltarr(2, n_elements(array.(0)))
                    for i=0, 1 do begin
                       c_points[i,*] = array.(i)
                    endfor
                    oplot, c_points[0,*], c_points[1,*], color=cgcolor('Red'),$
                           psym=1, symsize=1
                 endif
                ;If no, ask user to pick:
                 if strlen(file[0]) lt 8 then begin
                    ;choose the points to be used for fitting the sphere.
                    pointsonthecircle, points=c_points
                    write_csv, newtime + points_c + '.csv', c_points
                 endif
                 
                 ;Satellite location:
                 wcsc = fitshead2wcs( index1 )
                 csatph = wcsc.position.hglt_obs
                 csatph = 90 - csatph
                 csatth = wcsc.position.hgln_obs
                 csatdist = wcsc.position.dsun_obs
            
                 ;print, "sat phi(colat) =", csatph
                 ;print, "sat theta =", csatth

                 givenorigo = [th_o, ph_o, Ar_o + Br_o *moment]
                 radius = Arad + Brad *moment
                 ;find the projection and plot it.
                 sphere, satth=csatth, satph=csatph, satdist=csatdist,$
                          origin=givenorigo, radius=radius, kuvax=ckuvax,$
                          kuvay=ckuvay
                 oplot, ckuvax, ckuvay, color=cgcolor('Blue'), psym=1,$
                        linestyle=0, symsize=1
              endif
              
           endif
           
           if sohodiff_frame eq -1 then begin
              dontusec = -1
           endif
           if frame1 eq -1 then begin
              dontusec = -1
           endif
           
        endif
        
        if dontusec eq 1 then begin
           framesc = [framesc, newtime]
           diffframesc = [diffframesc, obsdatec[0,sohodiff_frame]]
        endif
        dontusec = 0
        time = nexttime
        print, '---'
        
     endwhile
     
  endif
  if sohofiles[0] eq '' then begin
     print, ' '
     print, 'No data from SOHO found.'
     print, ' '
     dontusec = -1
  endif

  print, ''
  print, 'Chosen frames:'
  print, 'a', framesa, diffframesa
  print, 'b', framesb, diffframesb
  print, 'c', framesc, diffframesc

  edellinenminimir = 1e+09
  edellinenminimidir = 1e+09
  avalir = 3e+05
  bvalir = 3e+05
  validir = 10

  
  for p=0, kierroksia-1 do begin

     print, ''
     print, p, ' out of ', strtrim(kierroksia, 1),' rounds done now.'
  
     r_iterointi, th_0=th_o, ph_0=ph_o, Ar_o=Ar_o, Br_o=Br_o, A_rad=Arad,$
                  B_rad=Brad, framesa=framesa, framesb=framesb,$
                  framesc=framesc,obsdatea=obsdatea, obsdateb=obsdateb, $
                  obsdatec=obsdatec, stereofilesa=stereofilesa,$
                  stereofilesb=stereofilesb, sohofiles=sohofiles, $
                  points_a=points_a, points_b=points_b,  points_c=points_c,$
                  Arcoord=Arcoord, Brcoord=Brcoord,$
                  Aradius=Aradius, Bradius=Bradius, t0=t0, edellinenminimir,$
                  avalir, bvalir

     print, ' '
     print, 'Aradius', Aradius, ' Bradius', Bradius, ' Arcoord', Arcoord, $
            ' Brcoord', Brcoord
     
     Arad = Aradius 
     Brad = Bradius
     Ar_o = Arcoord
     Br_o = Brcoord
     avalir = avalir*1.5
     if avalir gt Ar_o or avalir gt Arad then begin
        avalir = avalir/2.0
     endif
     bvalir = bvalir*1.5
     if bvalir gt Br_o or bvalir gt Brad then begin
        bvalir = bvalir/2.0
     endif
    
     dir_iterointi, th_0=th_o, ph_0=ph_o, framesa=framesa, framesb=framesb, $
                    framesc=framesc, obsdatea=obsdatea, obsdateb=obsdateb, $
                    obsdatec=obsdatec, stereofilesa=stereofilesa, $
                    stereofilesb=stereofilesb, sohofiles=sohofiles, $
                    points_a=points_a, points_b=points_b, points_c=points_c, $
                    Arcoord=Arcoord, Brcoord=Brcoord, Aradius=Aradius, $
                    Bradius=Bradius, t0=t0, direction, edellinenminimidir, $
                    validir
  
     th_o = direction[0]
     ph_o = direction[1]
     validir = validir*1.5
     if validir gt 90 then begin
        validir = 90
     endif
     
     print,''
     print, 'th_0', th_o, ' ph_o', ph_o
     print, ''

  endfor

  print, 'Final parameters:'
  print, 'th_0 ', STRTRIM(th_o, 1), ' ph_o ', STRTRIM(ph_o, 1), ' Aradius ', $
         STRTRIM(Aradius, 1), ' Bradius ', STRTRIM(Bradius, 1), ' Arcoord ', $
         STRTRIM(Arcoord, 1), ' Brcoord ', STRTRIM(Brcoord, 1)
  
  
  ;Plotting the new circles:
  ;A
  for k=1, n_elements(framesa)-1 do begin

     if window gt 28 then begin
        window = 0
     endif
     
     tmp = strsplit(framesa[k], ':', /extract, /regex)
     moment = tmp[0]*3600 + tmp[1]*60 -t0
     
     ;Look for the frame:
     frame1 = where(strmatch(obsdatea[0,*], '*'+framesa[k]+':*'))
     aimg1 = stereofilesa[frame1[0]]
     mreadfits, aimg1, aindex1, aimage1, /quiet
     polarisationa = aindex1.POLAR
     detectora = aindex1.DETECTOR
     
     ;timedifference frame:
     frame2 = where(strmatch(obsdatea[0,*], diffframesa[k]))
     for i=0, n_elements(frame2)-1 do begin
        difframe = where(obsdatea[1,frame2[i]] eq polarisationa)
        detect = where(obsdatea[2,frame2[i]] eq detectora)
        if difframe ne -1 and detect ne -1 then begin
           tmpi = i
           i=n_elements(frame2)
        endif
     endfor

     aimg2 = stereofilesa[frame2[tmpi]]
     mreadfits, aimg2, aindex2, aimage2, /quiet
     
     ;to maps
     index2map, aindex1, aimage1, amap1
     index2map, aindex2, aimage2, amap2
     
     ;plot
     adiff = diff_map(amap1, amap2, rotate=rotate)
     wdel, window 
     wdef, window, 600, /lright
     window = window + 1
     plot_map, adiff, /log, /cbar
     
     ; file with points to fit to:
     array = READ_CSV( framesa[k] + points_a + '.csv', count=count)
     a_points = fltarr(2, n_elements(array.(0)))
     for i=0, 1 do begin
        a_points[i,*] = array.(i)
     endfor
     oplot, a_points[0,*], a_points[1,*], color=cgcolor('Red'), psym=1,$
            symsize=1
     
     ;  Satellite location:
     wcsa = fitshead2wcs( aindex1 )
     asatph = wcsa.position.hglt_obs
     asatph = 90 - asatph
     asatth = wcsa.position.hgln_obs
     asatdist = wcsa.position.dsun_obs
     
     origo = [th_o, ph_o, Arcoord + Brcoord *moment]
     radius = Aradius + Bradius *moment
     ;find the new projection and plot it:
     sphere, satth=asatth, satph=asatph, satdist=asatdist, origin=origo,$
             radius=radius, kuvax=akuvax, kuvay=akuvay
     oplot, akuvax, akuvay, color=cgcolor('Blue'), psym=1, symsize=1
     
  endfor
  ;B
  for k=1, n_elements(framesb)-1 do begin
     
     tmp = strsplit(framesb[k], ':', /extract, /regex)
     moment = tmp[0]*3600 + tmp[1]*60-t0
     
     ;Look for the frame:
     frame1 = where(strmatch(obsdateb[0,*], '*'+framesb[k]+':*'))
     bimg1 = stereofilesb[frame1[0]]
     mreadfits, bimg1, bindex1, bimage1, /quiet
     polarisationb = bindex1.POLAR
     detectorb = bindex1.DETECTOR
     
     ;timedifference frame:
     frame2 = where(strmatch(obsdateb[0,*], diffframesb[k]))
     for i=0, n_elements(frame2)-1 do begin
        difframe = where(obsdateb[1,frame2[i]] eq polarisationb)
        detect = where(obsdateb[2,frame2[i]] eq detectorb)
        if difframe ne -1 and detect ne -1 then begin
           tmpi = i
           i=n_elements(frame2)
        endif
     endfor

     bimg2 = stereofilesb[frame2[tmpi]]
     mreadfits, bimg2, bindex2, bimage2, /quiet
     
     ;to maps
     index2map, bindex1, bimage1, bmap1
     index2map, bindex2, bimage2, bmap2
     
     ;plot
     bdiff = diff_map(bmap1, bmap2, rotate=rotate)
     wdel, window 
     wdef, window, 600, /uright
     window = window + 1
     plot_map, bdiff, /log, /cbar
     
     ; file with points to fit to:
     array = READ_CSV( framesb[k] + points_b + '.csv', count=count)
     b_points = fltarr(2, n_elements(array.(0)))
     for i=0, 1 do begin
        b_points[i,*] = array.(i)
     endfor
     oplot, b_points[0,*], b_points[1,*], color=cgcolor('Red'), psym=1,$
            symsize=1
     
     ;  Satellite location:
     wcsb = fitshead2wcs( bindex1 )
     bsatph = wcsb.position.hglt_obs
     bsatph = 90 - bsatph
     bsatth = wcsb.position.hgln_obs
     bsatdist = wcsb.position.dsun_obs
     
     origo = [th_o, ph_o, Arcoord + Brcoord *moment]
     radius = Aradius + Bradius *moment 
     ;find the new projection and plot it:
     sphere, satth=bsatth, satph=bsatph, satdist=bsatdist, origin=origo,$
             radius=radius, kuvax=bkuvax, kuvay=bkuvay
     oplot, bkuvax, bkuvay, color=cgcolor('Blue'), psym=1, symsize=1
  endfor
  
  ;SOHO
  for k=1, n_elements(framesc)-1 do begin
     
     tmp = strsplit(framesc[k], ':', /extract, /regex)
     moment = tmp[0]*3600 + tmp[1]*60 -t0
     
     ;Look for the frame:
     frame1 = where(strmatch(obsdatec[0,*], '*'+framesc[k]+':*'))
     img1 = sohofiles[frame1[0]]
     mreadfits, img1, index1, image1, /quiet
     polarisation = index1.POLAR
     detector = index1.DETECTOR
     
     ;timedifference frame:
     frame2 = where(strmatch(obsdatec[0,*], diffframesc[k]))
     for i=0, n_elements(frame2)-1 do begin
        difframe = where(obsdatec[1,frame2[i]] eq polarisation)
        detect = where(obsdatec[2,frame2[i]] eq detector)
        if difframe ne -1 and detect ne -1 then begin
           tmpi = i
           i=n_elements(frame2)
        endif
     endfor
     
     img2 = sohofiles[frame2[tmpi]]
     mreadfits, img2, index2, image2, /quiet
     
     ;to maps
     index2map, index1, image1, map1
     index2map, index2, image2, map2
     
     ;plot
     diff = diff_map(map1, map2, rotate=rotate)
     wdel, window 
     wdef, window, 600, /lright
     window = window + 1
     plot_map, diff, /log, /cbar
     
     ; file with points to fit to:
     array = READ_CSV( framesc[k] + points_c + '.csv', count=count)
     c_points = fltarr(2, n_elements(array.(0)))
     for i=0, 1 do begin
        c_points[i,*] = array.(i)
     endfor
     oplot, c_points[0,*], c_points[1,*], color=cgcolor('Red'), psym=1,$
            symsize=1
     
     ;  Satellite location:
     wcs = fitshead2wcs( index1 )
     satph = wcs.position.hglt_obs
     satph = 90 - satph
     satth = wcs.position.hgln_obs
     satdist = wcs.position.dsun_obs
     
     origo = [th_o, ph_o, Arcoord + Brcoord *moment]
     radius = Aradius + Bradius *moment
     ;find the new projection and plot it:
     sphere, satth=satth, satph=satph, satdist=satdist, origin=origo,$
             radius=radius, kuvax=kuvax, kuvay=kuvay
     oplot, kuvax, kuvay, color=cgcolor('Blue'), psym=1, symsize=1
  endfor          

END
