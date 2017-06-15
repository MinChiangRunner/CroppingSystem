PRO GeneratePrecipitation, file ,extent = extent
  COMPILE_OPT idl2
  ;ʹ��ALBERS CQ ����Զ����ͶӰ
  ;file = "E:\������������\��������\����\precipitation\SURF_CLI_CHN_MUL_DAY-PRE-13011-198603.TXT"
  OUTdir = "E:\������������\��������\Test\precipitation"
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
  ;γ��
  lat = fix(data[1,*]/100) + (data[1,*] - fix(data[1,*]/100)*100)/60d
  ;ת��Ϊ����
  spatialRef.ConvertLonLatToMap, Lon, Lat, MapX, MapY
  ;�߳�
  Elevation = (data[3,*] - fix(data[3,*]/100000)*100000)*0.1
  ;��ߺ��������
  ;��ˮ��  32700 ��ʾ��ˮ"΢��"; 32XXX XXXΪ����¶˪; 31XXX XXXΪ���ѩ������; 30XXX XXXΪѩ��(���������ѩ��ѩ����
  Precip = ((fix(data[9,*]/10000) EQ 3)*0 + (fix(data[9,*]/10000) NE 3)*data[9,*])*0.1
  ;����ת����Ľ������
  outdata = [data[0,*], Mapx, MapY, Elevation, data[4:6,*], Precip]
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
    suboutdir = outdir + "\" + strtrim(string(fix(outprint[4,0])),2)+ "\Prec-" + $
      strtrim(string(fix(outprint[4,0])),2)+ $
      "-"+strtrim(string(fix(outprint[5,0])),2) $
      +"-"+strtrim(string(fix(outprint[6,0])),2)
    IF ~file_test(suboutdir) THEN file_mkdir, suboutdir
    ;����ļ�
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
