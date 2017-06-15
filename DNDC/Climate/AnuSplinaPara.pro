PRO AnuSplinaPara, Climatefile, extent, surcount, cellsize = cellsize, splinafile,lapgrdfile
  COMPILE_OPT idl2
  ;Splina CMD file
  ;climatefile = "E:\基础地理数据\气象数据\Test\1990\Temp-1990-2-2\Temp-1990-2-2.dat"
  outfilename = file_basename(Climatefile,".dat")
  splinafile = file_dirname(Climatefile) + "\splina" + outfilename + ".cmd"
  ;研究区范围及高差
  EXTENT = [[extent[0,0], extent[1,0], 0, 1], $
    [extent[0,1], extent[1,1], 0, 1]]
  ; hightdif = [-2, 4102, 1, 1]
  hightdif = [-2, 3053, 1, 1]
  IF ~keyword_set(cellsize) THEN cellsize = 1000
  ;surcount = 2 ; 输出面的个数
  nsamples = 400
  IF (surcount EQ 2) THEN BEGIN
    outfiles = [["(a5,f12.2,f12.2,f8.1,f7.1,f7.1)"], $
      [outfilename +".res"], $
      [outfilename +".opt"], $
      [outfilename +".sur"], $
      [outfilename +".lis"], $
      [outfilename +".cov"]]
  ENDIF ELSE  BEGIN
    outfiles = [["(a5,f12.2,f12.2,f8.1,f7.1)"], $
      [outfilename +".res"], $
      [outfilename +".opt"], $
      [outfilename +".sur"], $
      [outfilename +".lis"], $
      [outfilename +".cov"]]
  ENDELSE

  openw,lun, splinafile, /get_lun
  ;文件名称
  printf,lun,outfilename
  printf,lun,[5,2,1,0,0],format = "(I1)"
  printf,lun,FORMAT = '(f0.5," ",D0.5," ",i-2,I1)', extent[*,0]
  printf,lun,FORMAT = '(f0.5," ",D0.5," ",i-2,I1)', extent[*,1]
  printf,lun,strtrim(string(hightdif),2)
  printf, lun,strtrim(string(cellsize),2)
  printf, lun,[0,3,surcount,0,1,1],format = "(I1)"
  printf,lun, file_basename(Climatefile)
  printf,lun,strtrim(string(nsamples),2)
  printf,lun, strtrim(string(5),2)
  printf, lun,outfiles
  printF, lun, ["","","","",""],FORMAT="(/A)"
  free_lun,lun

  ; Lapgrd cmd file
  lapgrdfile = file_dirname(Climatefile) + "\lapgrd" + outfilename + ".cmd"
  openw, lun, lapgrdfile,/GET_LUN
  printf,lun, outfilename +".sur"
  printf,lun, strtrim(string(indgen(surcount)+1), 1)
  PRINTF, lun, [1], format = "(I1)"
  PRINTF,lun, ""
  printf,lun,[[1],[1]], format = "(I1)"
  PRINTF,lun,FORMAT= '(f0.5," ", D0.5," ",I0)', extent[0:1,0], cellsize
  printf,lun, [2], format = "(I1)"
  PRINTF,lun,FORMAT= '(f0.5," ", D0.5," ",I0)', extent[0:1,1], cellsize
  printf,lun,[0,2],format = "(I1)"
  printf,lun,"chinadem_km_albescq_studyarea.txt"
  printf,lun,[2], format = "(I1)"
  printf, lun,[-9999.0], format="(f7.1)"

  IF (surcount EQ 2) THEN BEGIN
    printf, lun, outfilename + "max.grd"
    printf, lun, outfilename + "min.grd"
  ENDIF ELSE printf, lun, outfilename + ".grd"

  printf, lun, "(100f10.3)"
  printf, lun, ["","","","",""],FORMAT="(/A)"
  free_lun,lun

  ;AnusplinaCMD, splinafile, lapgrdfile

END