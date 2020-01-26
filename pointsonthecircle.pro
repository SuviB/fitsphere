;+
;Saves 10 points that are clicked in the image to an array,
;that will be returned.
;-


pro pointsonthecircle, points=points

  lkm=7

  points=fltarr(2,lkm)
  print, " "
  print, "Click a point on the eruption front, please."
  cursor, x, y, /down
  oplot, [x], [y],  color=cgcolor('Red'), psym=1, symsize=1
  for i=0, lkm-1 do begin
     cursor, x1, y1, /down
     points[0,i]=x1
     points[1,i]=y1
     x=x1
     y=y1
  oplot, [x], [y],  color=cgcolor('Red'), psym=1, symsize=1
     ;laskuri:
     esc = string(27B)
     print, esc + '[13D' + esc + '[K', format='(A, $)'
     print, lkm-i-1, format='(I1, " more times.", $)' 
  endfor
  print, esc + '[13D' + esc + '[K', format='(A, $)'
  print, 0, format='(I1, " more times.", $)' 
  print, " Thank you!"

END
