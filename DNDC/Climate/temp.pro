PRO temp
  files = file_search("E:\������������\��������\Test\1990","splinaTemp-1990-6-*.cmd",count=n,/TEST_REGULAR)
  ;files = file_search("E:\������������\��������\Test\1990","splinacmdbat.bat",count=n,/TEST_REGULAR)
  FOR i= 0,29 DO BEGIN
    splinecmd = files[i]
    extfile = file_dirname(splinecmd) +"\"+ file_basename(file_dirname(splinecmd)) + "max.grd"
    IF ~file_test(extfile) THEN BEGIN
      print, file_basename(file_dirname(splinecmd))
      spawn,"copy E:\������������\��������\BeCopied\* " + file_dirname(splinecmd)
      spawn, file_dirname(splinecmd) + "\splinacmdbat.bat"
      spawn, file_dirname(splinecmd) + "\lapgrdcmdbat.bat"
    ENDIF
  ENDFOR

END
