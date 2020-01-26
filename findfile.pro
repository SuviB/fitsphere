;+
;Using a list of observation times finds the index in the list that is
;closest to the given time and returns it.
;-

pro findfile, obsdate=obsdate, time=time, frame1=frame1, newtime=newtime, nexttime=nexttime

  ;Look for the frame:
  sciframe = where(strmatch(obsdate[0,*], '*'+time+':*'))
  
  ;if found, return:
  if sciframe[0] ne -1 then begin
     frame1=sciframe[0]
     newtime=time
     print, 'Found a frame at: ', obsdate[0,frame1]
     goto, jump
  endif
  
  ;if not found, look with earlier times:
  if sciframe[0] eq -1 then begin
     print, 'Looking for a frame with different time:'
     tmp = strsplit(time, ':', /extract, /regex)
     min = tmp[1]
     hour = tmp[0]
     for i=0, 30 do begin
        min = min +1
        if min gt 59 then begin
           min = min - 60
           hour = hour + 1 
           if hour lt 10 then begin
              hour= '0' + strtrim(string(hour),1)
           endif
        endif
        if min lt 10 then begin
           min= '0' + strtrim(string(min),1)
        endif
        if min gt 9 then begin
           min = strtrim(string(min),1)
        endif
        frametime = strtrim(string(hour), 1) +':'+ strtrim(string(min), 1)
        ;Look for the frame again:
        sciframe = where(strmatch(obsdate[0,*], '*'+frametime+':*'))
        if sciframe[0] ne -1 then begin
           frame1=sciframe[0]
           print, 'Found a frame at: ', obsdate[0,frame1]
           newtime=frametime
           goto, jump
        endif
     endfor
     frame1 = -1
     print, 'Frame not found.'
     print, '----------------'
     newtime=frametime
  endif

     jump:
     tmp = strsplit(newtime, ':', /extract, /regex)
     min2 = tmp[1]
     hour2 = tmp[0]
     min2 = min2 +1
     if min2 gt 59 then begin
        min2 = min2 - 60
        hour2 = hour2 + 1 
        if hour2 lt 10 then begin
           hour2 = '0' + strtrim(string(hour2),1)
        endif
     endif
     if min2 lt 10 then begin
        min2 = '0' + strtrim(string(min2),1)
     endif
     if min2 gt 9 then begin
        min2 = strtrim(string(min2),1)
     endif
     nexttime = strtrim(string(hour2), 1) +':'+ strtrim(string(min2), 1)
  
  
END
