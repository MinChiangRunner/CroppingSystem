
PRO NewDNDCClimateFileGenerate
  COMPILE_OPT idl2

  ;读取熟制数据
  e = envi(/headless)
  Paddyfile = "E:\DNDC\PaddyCS\2015\Results\2015sPaddySZ1kmSoil(Majority)_SD.tif"
  PaddyRaster = e.OpenRaster(Paddyfile)
  PaddyCS = PaddyRaster.Getdata()
  e.close

  MaxTempfile = file_search("E:\基础地理数据\气象数据\Test\temperature\1992","Temp*max_sd.tif",count = n1,/TEST_REGULAR)
  MinTempfile = file_search("E:\基础地理数据\气象数据\Test\temperature\1992","Temp*min_sd.tif",count = n2,/TEST_REGULAR)
  Precifile = file_search("E:\基础地理数据\气象数据\Test\precipitation\1992","Prec*_sd.tif",count = n3,/TEST_REGULAR)

  IF ((n1 NE n2) OR (n2 NE n3)) THEN BEGIN
    print, "文件数不同，请检查!"
    stop
  ENDIF

  Maxtempfile = rotate([[maxtempfile],[Maxtempfile.extract('[0-9]{4}-[0-9]+-[0-9]+')],[strarr(n1)]],1)
  MinTempfile = rotate([[MinTempfile],[MinTempfile.extract('[0-9]{4}-[0-9]+-[0-9]+')],[strarr(n1)]],1)
  Precifile = rotate([[Precifile],[Precifile.extract('[0-9]{4}-[0-9]+-[0-9]+')],[strarr(n1)]],1)
  FOR i=0, n1-1 DO BEGIN
    maxtempfile[0,i] = $
      julday(((maxtempfile[1,i]).split("-"))[1],$
      ((maxtempfile[1,i]).split("-"))[2],((maxtempfile[1,i]).split("-"))[0])
    MinTempfile[0,i] = $
      julday(((MinTempfile[1,i]).split("-"))[1],$
      ((MinTempfile[1,i]).split("-"))[2],((MinTempfile[1,i]).split("-"))[0])
    Precifile[0,i] = $
      julday(((Precifile[1,i]).split("-"))[1],$
      ((Precifile[1,i]).split("-"))[2],((Precifile[1,i]).split("-"))[0])
  ENDFOR
  maxtempfile = arrsort(maxtempfile)
  MinTempfile = arrsort(MinTempfile)
  Precifile = arrsort(Precifile)
  IF (n1 EQ 366) THEN BEGIN
    maxtempfile = [[maxtempfile[*,0:58]],[maxtempfile[*,60:365]]]
    ;maxtempfile[0,59:364] = maxtempfile[0,59:364] - 1
    MinTempfile = [[MinTempfile[*,0:58]],[MinTempfile[*,60:365]]]
    ;MinTempfile[0,59:364] = MinTempfile[0,59:364] - 1
    Precifile = [[Precifile[*,0:58]],[Precifile[*,60:365]]]
    ;Precifile[0,59:364] = Precifile[0,59:364] - 1
  ENDIF
  poses = where(PaddyCS NE 3)
  FOREACH rowcolnum, poses DO BEGIN
    year = MaxTempfile[1,0].extract('[0-9]{4}')
    ;outdir  = "E:\DNDC\ClimateData\Weather\" + year
    outdir  = "E:\DNDC\ClimateData\Weather\" + year
    IF ~file_test(outdir) THEN file_mkdir, outdir
    outfile = outdir + path_sep()+ "SC" + string(rowcolnum,format="(I07)") + ".txt"
    openw,lun, outfile, /get_lun
    printf,lun,"SC" + string(rowcolnum,format="(I07)")
    free_lun,lun
  ENDFOREACH


  Maxtempdata = !NULL
  mintempdata = !NULL
  precidata = !NULL
  time00 = systime(1)
  FOR j=0, 5 DO BEGIN
    startvalue = j*60
    IF (j EQ 5) THEN (endvalue = 364) ELSE (endvalue = j*60 + 59)
    time0 = systime(1)
    FOR i = startvalue, endvalue DO BEGIN
      print,i+1
      Maxtempdata = [[[Maxtempdata]],[[read_tiff(MaxTempfile[2,i])]]]
      mintempdata = [[[mintempdata]],[[read_tiff(MinTempfile[2,i])]]]
      precidata = [[[precidata]],[[read_tiff(Precifile[2,i])]]]
    ENDFOR
    time1 = systime(1)
    print,'读取数据：' , time1 - time0

    FOREACH rowcolnum, poses DO BEGIN
      year = MaxTempfile[1,0].extract('[0-9]{4}')
      ;outdir  = "E:\DNDC\ClimateData\Weather\" + year
      outdir  = "E:\DNDC\ClimateData\Weather\" + year
      IF ~file_test(outdir) THEN file_mkdir, outdir
      outfile = outdir + path_sep()+ "SC" + string(rowcolnum,format="(I07)") + ".txt"
      ;IF file_test(outfile) THEN CONTINUE
      colnum = rowcolnum MOD 1752
      rownum = rowcolnum / 1752
      openw,lun, outfile, /get_lun, /APPEND
      ;printf,lun,"SC" + string(rowcolnum,format="(I07)")
      FOR i =0 , (endvalue - startvalue) DO BEGIN
        printf, lun, format="(I-4,F8.3, F8.3, F8.3)", startvalue + i+1, Maxtempdata[colnum,rownum,i], $
          mintempdata[colnum,rownum,i], precidata[colnum,rownum,i]
      ENDFOR
      free_lun, lun
    ENDFOREACH
    print,'打印60个数据: ', systime(1)- time1
    Maxtempdata = !NULL
    mintempdata = !NULL
    precidata = !NULL
  ENDFOR
  print, '共用时', systime(1) - time00
  print, 134
END