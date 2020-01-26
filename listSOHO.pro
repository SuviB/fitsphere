;+
;finds the files in the directory and returns a list.
;-

pro listSOHO, date=date, sohofiles

  ;fix date into right form:
  sohodate = STRMID(date, 2, 7)
  
  dir = 'archive/soho/private/data/processed/lasco/level_05/'+ sohodate+ '/c2/*'
  sohofiles = file_search(dir)
  dir = 'archive/soho/private/data/processed/lasco/level_05/'+ sohodate+ '/c3/*'
  sohofiles = [sohofiles, file_search(dir)]
  
END
