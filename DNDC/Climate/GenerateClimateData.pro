PRO GenerateClimateData, file , extent = extent
  COMPILE_OPT idl2
  ;ʹ��ALBERS CQ ����Զ����ͶӰ
  ;file = "E:\������������\��������\����\temperture\SURF_CLI_CHN_MUL_DAY-TEM-12001-199002.TXT"
  OUTdir = "E:\������������\��������\Test\temperature"
  vecoterfile = "E:\������������\��������\����\����վ��λ��_ALBERSCQ.shp"
  cellsize = 1000
  data = fltarr(13,file_lines(file))
  e = envi(/headless)
  vector1 = e.OpenVector(vecoterfile)
  spatialref = vector1.COORD_SYS
  openr,lun,file,/get_lun
  readf,lun,data
  free_lun,lun
  ;��������,ת��Ϊ��
  lon = fix(data[2,*]/100) + (data[2,*] - fix(data[2,*]/100)*100)/60d
  ;  lonmin = strmid(string(data[2,*]),strpos(string(data[2,*]),".")-2,2)
  ;  londg = strmid(string(data[2,*]),0,strpos(string(data[2,*]),".") - 2)
  ;  lon = float(londg) + float(lonmin)/60
  ;γ��
  lat = fix(data[1,*]/100) + (data[1,*] - fix(data[1,*]/100)*100)/60d
  ;  latmin = strmid(string(data[1,*]),strpos(string(data[1,*]),".")-2,2)
  ;  latdg = strmid(string(data[1,*]),0,strpos(string(data[1,*]),".") - 2)
  ;  lat = float(latdg) + float(latmin)/60
  ;ת��Ϊ����
  spatialRef.ConvertLonLatToMap, Lon, Lat, MapX, MapY
  ;�߳�
  Elevation = (data[3,*] - fix(data[3,*]/100000)*100000)*0.1
  ;��ߺ��������
  TempMax = data[8,*]*0.1
  TempMin = data[9,*]*0.1
  ;Date = fix(data[4:6,*])
  ;����ת����Ľ������
  outdata = [data[0,*], Mapx, MapY, Elevation, data[4:6,*], TempMax, TempMin]
  ;��ȡ�о�����Χ�ڵ�����
  ;EXTENT = [[-79000, 1704000],[2080000, 3804000]]
  ;EXTENT = [[-52705.307034, 1699294.69297],[2101820.71722,3755820.71722]]
  outdata = outdata[*, where((outdata[2,*] GE extent[0,1]) $
    AND (outdata[2,*] LE extent[1,1]) AND $
    (outdata[1,*] GE extent[0,0]) AND (outdata[1,*] LE extent[1,0]))]
  ;���ÿ�µ���������
  DAY = outdata[6,*]
  dayindice = DAY[UNIQ(DAY, SORT(DAY))]

  ;����ļ�
  FOREACH DayIndex, dayindice DO BEGIN
    ;����ÿ�����ڹ���ÿһ����¶��ļ���������"���\�¶�����"��֯�ļ�
    dayin = where(Outdata[6,*] EQ Dayindex)
    outprint = Outdata[*,dayin]
    suboutdir = outdir + "\" + strtrim(string(fix(outprint[4,0])),2)+ "\Temp-" + $
      strtrim(string(fix(outprint[4,0])),2)+ $
      "-"+strtrim(string(fix(outprint[5,0])),2) $
      +"-"+strtrim(string(fix(outprint[6,0])),2)
    IF ~file_test(suboutdir) THEN file_mkdir, suboutdir
    ;����ļ�
    printfile = suboutdir +"\Temp-" + $
      strtrim(string(fix(outprint[4,0])),2)+ $
      "-"+strtrim(string(fix(outprint[5,0])),2) $
      +"-"+strtrim(string(fix(outprint[6,0])),2)+'.dat'
    openw,lun,printfile, /GET_LUN
    PRINTF,lun,FORMAT = $
      '(I5, F12.2, F12.2, F8.1, F7.1, F7.1)',$
      outprint[[0,1,2,3,7,8],*]
    free_lun, lun
    surcount = 2
    AnuSplinaPara, printfile, extent, surcount,cellsize = cellsize, splinafile,lapgrdfile
    ;print,splinafile ,lapgrdfile
    AnusplinaCMD, splinafile, lapgrdfile

  ENDFOREACH
  print,"finish"
  e.close
END
