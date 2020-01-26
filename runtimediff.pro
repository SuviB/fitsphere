;+
;finds the index of a frame 12 mins (or more) before the time.
;From the obsdatelist. Takes polarisation into consideration.
;-

pro runtimediff, obsdate=obsdate, time=time, frame=frame, polarisation=polarisation, detector=detector

  ;find the time 12 mins earlier
  tmp = strsplit(time, ':', /extract, /regex)
  min = tmp[1]
  hour = tmp[0]
  min = min - 10
  if min lt 0 then begin
     min = min + 60
     hour = hour - 1
  endif
  if hour lt 10 and hour ge 0 then begin
     hour = strtrim(string(hour),1)
  endif
  if hour ge 10 then begin
     hour =  strtrim(string(hour),1)
  endif
  if min lt 10 then begin
     min= '0' + strtrim(string(min),1)
  endif
  if min gt 9 then begin
     min = strtrim(string(min),1)
  endif

  ;the time of the frame to be subtracted:
  runtime = hour +':'+ min
  
  ;Look for the frame:
  runframe = where(strmatch(obsdate[0,*], '*'+runtime+'*'))

  if runframe[0] ne -1 then begin
     for i=0,n_elements(runframe)-1 do begin
        frame=runframe[i]
        if obsdate[1,frame] eq polarisation and $
           obsdate[2,frame] eq detector then begin
           print, ' Found a time difference frame at: ', obsdate[0,frame]
           return
        endif
     endfor 
  endif
  
  ;if not found, look with earlier times:
  print, 'Looking for a running time difference frame from earlier than ',$
         runtime, ' :'
  for i=1, 60 do begin
     min = min -1
     if min lt 0 then begin
        min = min + 60
        hour = hour - 1
     endif
     
     if hour lt 10 then begin
        hour1 = '0' + strtrim(string(hour),1)
     endif
     if hour gt 9 then begin
        hour1 = strtrim(string(hour),1)
     endif
     
     if min lt 10 then begin
        min1 = '0' + strtrim(string(min),1)
     endif
     if min gt 9 then begin
        min1 = strtrim(string(min),1)
     endif
     
     runtime = hour1 +':'+ min1
     ;Look for the frame again:
     runframe = where(strmatch(obsdate[0,*], '*'+runtime+'*'))
     
     if runframe[0] ne -1 then begin
        for i=0,n_elements(runframe)-1 do begin
           frame=runframe[i]
           if obsdate[1,frame] eq polarisation and $
              obsdate[2,frame] eq detector then begin
              print, ' Found a time difference frame at: ', obsdate[0,frame]
              print, ''
              print, ''
              return
           endif
        endfor
     endif
  endfor
  frame = -1
  print, ' Frame for running time difference image not found!'
  print, ''

END
