PRO GeneratePrecipitation, file ,extent = extent
  COMPILE_OPT idl2
  ;使用ALBERS CQ 刘纪远数据投影
  ;file = "E:\基础地理数据\气象数据\数据\precipitation\SURF_CLI_CHN_MUL_DAY-PRE-13011-198603.TXT"
  OUTdir = "E:\基础地理数据\气象数据\Test\precipitation"
  vecoterfile = "E:\基础地理数据\气象数据\数据\气象站点位置_ALBERSCQ.shp"
  cellsize = 1000
  data = fltarr(13,file_lines(file))
  e = envi(/headless)
  vector1 = e.OpenVector(vecoterfile)
  spatialref = vector1.COORD_SYS
  openr,lun,file,/get_lun
  readf,lun,data
  free_lun,lun
  ;解析经度,转化为度
  lon = fix(data[2,*]/100) + (data[2,*] - fix(data[2,*]/100)*100)/60d
  ;纬度
  lat = fix(data[1,*]/100) + (data[1,*] - fix(data[1,*]/100)*100)/60d
  ;转换为坐标
  spatialRef.ConvertLonLatToMap, Lon, Lat, MapX, MapY
  ;高程
  Elevation = (data[3,*] - fix(data[3,*]/100000)*100000)*0.1
  ;最高和最低气温
  ;降水量  32700 表示降水"微量"; 32XXX XXX为纯雾露霜; 31XXX XXX为雨和雪的总量; 30XXX XXX为雪量(仅包括雨夹雪，雪暴）
  Precip = ((fix(data[9,*]/10000) EQ 3)*0 + (fix(data[9,*]/10000) NE 3)*data[9,*])*0.1
  ;构建转换后的结果数组
  outdata = [data[0,*], Mapx, MapY, Elevation, data[4:6,*], Precip]
  ;获取研究区范围内的数据
  ;EXTENT = [[-79000, 1704000],[2080000, 3804000]]
  ;EXTENT = [[-52705.307034, 1699294.69297],[2101820.71722,3755820.71722]]
  outdata = outdata[*, where((outdata[2,*] GE extent[0,1]) $
    AND (outdata[2,*] LE extent[1,1]) AND $
    (outdata[1,*] GE extent[0,0]) AND (outdata[1,*] LE extent[1,0]))]

  ;求得每月的日期索引
  DAY = outdata[6,*]
  dayindice = DAY[UNIQ(DAY, SORT(DAY))]

  ;输出文件
  FOREACH DayIndex, dayindice DO BEGIN
    ;根据每月日期构建每一天的温度文件，并按照"年份\温度数据"组织文件
    dayin = where(Outdata[6,*] EQ Dayindex)
    outprint = Outdata[*,dayin]
    suboutdir = outdir + "\" + strtrim(string(fix(outprint[4,0])),2)+ "\Prec-" + $
      strtrim(string(fix(outprint[4,0])),2)+ $
      "-"+strtrim(string(fix(outprint[5,0])),2) $
      +"-"+strtrim(string(fix(outprint[6,0])),2)
    IF ~file_test(suboutdir) THEN file_mkdir, suboutdir
    ;输出文件
    printfile = suboutdir +"\Prec-" + $
      strtrim(string(fix(outprint[4,0])),2)+ $
      "-"+strtrim(string(fix(outprint[5,0])),2) $
      +"-"+strtrim(string(fix(outprint[6,0])),2)+'.dat'
    IF ~file_test(printfile) THEN BEGIN
      openw,lun,printfile, /GET_LUN
      PRINTF,lun,FORMAT = $
        '(I5, F12.2, F12.2, F8.1, F7.1)',$
        outprint[[0,1,2,3,7],*]
      free_lun, lun
    ENDIF
    surcount = 1
    AnuSplinaPara, printfile, extent, surcount, cellsize = cellsize, splinafile, lapgrdfile
    ;print,splinafile ,lapgrdfile
    AnusplinaCMD, splinafile, lapgrdfile

  ENDFOREACH
  print,"finished"
  e.close
END
