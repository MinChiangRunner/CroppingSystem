PRO GenDNDCClimateFile, rowcolnum
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


  poses = where(PaddyCS NE 3)
  FOREACH rowcolnum, poses DO BEGIN
    year = MaxTempfile[0].extract('[0-9]{4}')
    ;outdir  = "E:\DNDC\ClimateData\Weather\" + year
    outdir  = "H:\Data_For_DocArtical\ClimateData\weather\" + year
    IF ~file_test(outdir) THEN file_mkdir, outdir
    outfile = outdir + path_sep()+ "SC" + string(rowcolnum,format="(I07)") + ".txt"
    IF file_test(outfile) THEN CONTINUE
    ;构建数列，存放结果
    Maxdate = make_array(2,n1)
    Mindate = make_array(2,n2)
    Precidate = make_array(2,n3)
    FOR i = 0, (n1-1) DO BEGIN
      ;读取数据
      MaxTempData = read_tiff(MaxTempfile[i])
      MinTempData = read_tiff(MinTempfile[i])
      PreciData = read_tiff(Precifile[i])

      ; 最大温度
      RQ = MaxTempfile[i].extract('[0-9]{4}-[0-9]+-[0-9]+')
      temprq = rq.split("-")
      jul = julday(temprq[1],temprq[2],temprq[0]) - julday(1,1,temprq[0]) + 1
      Maxdate[*,i] = [jul,MaxTempData[rowcolnum]]

      ;最小温度
      RQ = MinTempfile[i].extract('[0-9]{4}-[0-9]+-[0-9]+')
      temprq = rq.split("-")
      jul = julday(temprq[1],temprq[2],temprq[0]) - julday(1,1,temprq[0]) + 1
      Mindate[*,i] = [jul,MinTempData[rowcolnum]]

      ;降雨
      RQ = Precifile[i].extract('[0-9]{4}-[0-9]+-[0-9]+')
      temprq = rq.split("-")
      jul = julday(temprq[1],temprq[2],temprq[0]) - julday(1,1,temprq[0]) + 1
      Precidate[*,i] = [jul,PreciData[rowcolnum]]
    ENDFOR

    ;按照如略日排序
    Maxdate = ArrSort(Maxdate)
    Mindate = ArrSort(Mindate)
    PreciDate = Arrsort(PreciDate)
    Result = [maxdate[0,*],maxdate[1,*],Mindate[1,*],PreciDate[1,*]]

    ;判断是否闰年
    IF (n1 EQ 366) THEN BEGIN
      Result = [[Result[*,0:58]],[result[*,60:365]]]
      Result[0,59:364] = Result[0,59:364] - 1
    ENDIF


    data = MaxTempData[rowcolnum]
    openw,lun, outfile, /get_lun, /APPEND
    printf,lun,"SC" + string(rowcolnum,format="(I07)")
    FOR i =0 , 364 DO BEGIN
      printf, lun, format="(I-4,F8.3, F8.3, F8.3)", result[*,i]
    ENDFOR
    free_lun, lun
  ENDFOREACH
  print,"finished"

END