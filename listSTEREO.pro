;+
;Finds and returns a list of filenames from the directory.
;-

pro listSTEREO, stereoa=stereoa, stereob=stereob, date=date, stereofilesa, stereofilesb

  ;STERO A
  if stereoa eq 1 then begin
     ;COR2n
        directory = 'archive/secchi/L0/a/seq/cor2/'+date+'/*'
        stereofilesa = file_search(directory)
     ;COR1n
        directory = 'archive/secchi/L0/a/seq/cor1/'+date+'/*'
        stereofilesa = [stereofilesa , file_search(directory)]
  endif

  ;STERO B
  if stereob eq 1 then begin
     ;COR2
        directory = 'archive/secchi/L0/b/seq/cor2/'+date+'/*'
        stereofilesb = file_search(directory)
     ;COR1
        directory = 'archive/secchi/L0/b/seq/cor1/'+date+'/*'
        stereofilesb = [stereofilesb, file_search(directory)]
  endif
  
END
