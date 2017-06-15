
PRO RunAnusplinaCMD, splinecmd, lapgrdcmd
  COMPILE_OPT idl2
  ;copydir = "E:\������������\��������\BeCopied"
  copydir = file_dirname(ROUTINE_FILEPATH()) + "\" + "BeCopied"
  cmdfile = splinecmd
  ;����cmd��������
  batfile = file_dirname(splinecmd) + "\splinacmdbat.bat"
  spawn,"copy " + copydir + "\* " + file_dirname(splinecmd)
  openw,lun, batfile, /get_lun
  printf,lun, cmdfile.substring(0,1)
  printf,lun, "cd "+ file_dirname(cmdfile)
  printf,lun, "splina<"+file_basename(splinecmd)+">"+file_basename(splinecmd, ".cmd")+".log"
  ; printf,lun,"pause"
  free_lun,lun
  Spawn,"call " + batfile

  ; lapgrdcmd ��������

  batfile = file_dirname(splinecmd) + "\lapgrdcmdbat.bat"
  openw,lun, batfile, /get_lun
  printf,lun, cmdfile.substring(0,1)
  printf,lun, "cd "+ file_dirname(cmdfile)
  printf,lun, "lapgrd<"+file_basename(lapgrdcmd)+">"+file_basename(lapgrdcmd, ".cmd")+".log"
  ;  printf,lun, "del chinadem_km_albescq_studyarea.txt"
  ;  printf,lun, "del lapgrd.exe"
  ;  printf,lun, "del splina.exe"
  ; printf,lun,"pause"
  free_lun,lun
  Spawn,"call " + batfile

  if 0 then begin
    ;��python�ü����о�����Χ
    batfile = file_dirname(splinecmd) + "\pythoncmdbat.bat"
    openw,lun, batfile, /get_lun
    grdfiles = FILE_SEARCH(file_dirname(cmdfile), '*.grd', /TEST_REGULAR)
    FOREACH grdfile, grdfiles DO BEGIN
      print, grdfile
      command = "py -2 E:\Landsat\PythonCode\DNDC_EXTRACTION.py " + $
        file_dirname(grdfile) + " " + file_basename(grdfile) + " " + file_basename(grdfile,".grd")+ "_sd.tif"
      printf,lun, command
    ENDFOREACH
    free_lun,lun
    Spawn,"call " + batfile
    ;spawn," del chinadem_km_albescq_studyarea.txt"
  endif
END

;AnuSplinaPara���ò���
PRO SetAnuSplinaPara, Climatefile, extent, surcount, cellsize = cellsize, splinafile,lapgrdfile
  COMPILE_OPT idl2
  ;Splina CMD file
  ;climatefile = "E:\������������\��������\Test\1990\Temp-1990-2-2\Temp-1990-2-2.dat"
  outfilename = file_basename(Climatefile,".dat")
  splinafile = file_dirname(Climatefile) + "\splina" + outfilename + ".cmd"
  ;�о�����Χ���߲�
  EXTENT = [[extent[0,0], extent[1,0], 0, 1], $
    [extent[0,1], extent[1,1], 0, 1]]
  
  ; hightdif = [-2, 4102, 1, 1]
  ;-----�޸ĸ߲Χ
  ;�߲Χ,�޸�ǰ������
  hightdif = [-2, 3053, 1, 1] ;�߲Χ
  ;----------------------------------
  ;-------�޸ķֱ��ʼ���������--------
  IF ~keyword_set(cellsize) THEN cellsize = 1000
  nsamples = 400 ;��������
  ;------------------------------------
  outfiles = [["(a5,f12.2,f12.2,f8.1,"+ strtrim(string(surcount),2) + "f7.1)"], $
    [outfilename +".res"], $
    [outfilename +".opt"], $
    [outfilename +".sur"], $
    [outfilename +".lis"], $
    [outfilename +".cov"]]
  ;

  openw,lun, splinafile, /get_lun
  ;�ļ�����
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
  demname = file_basename(file_search(file_dirname(ROUTINE_FILEPATH("AnusplineProcesStart",/EITHER))+"\Becopied","*.txt"))
  printf,lun, demname
  printf,lun,[2], format = "(I1)"
  printf, lun,[-9999.0], format="(f7.1)"


  IF (surcount GE 2) THEN BEGIN
    FOR k =1 , surcount DO BEGIN
      printf,lun, outfilename +'-'+ strtrim(string(k),2) +".grd"
    ENDFOR
  ENDIF ELSE printf, lun, outfilename + ".grd"

  printf, lun, "(100f10.3)"
  printf, lun, ["","","","",""],FORMAT="(/A)"
  free_lun,lun

  ;AnusplinaCMD, splinafile, lapgrdfile

END
;GenerateAnusplineData ��ԭʼ����ת��ΪAnusplineʶ������ݸ�ʽ
PRO GenerateAnusplineData, file , extent = extent
  COMPILE_OPT idl2
  OUTdir = file_dirname(ROUTINE_FILEPATH()) + "\" + "Result"
  vecoterfile = file_search(file_dirname(ROUTINE_FILEPATH()) + "\" + "SpatialRef","*.shp");"E:\������������\��������\����\����վ��λ��_ALBERSCQ.shp"
  ;cellsize = 1000
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
  
  ;------------����Ϊ��Ҫ�޸ĵ�����----------
  ;ѡ���ֵ���������У������㹫ʽ��Data�±������Ϊ������ԭ�ļ��е�����-1��
  ;��������ԭ�����ļ��ĵ�10����Data���±��ΪData[9,*]
  ;��Ҫ��ֵ�������������ü���Data1,Data2,����Outdata������������ӽ�ȥ��
  ;��[data[0,*], Mapx, MapY, Elevation, data[4:6,*], Data1,data2,data3,datan]
  
  Data1 = ((fix(data[9,*]/10000) EQ 3)*0 + (fix(data[9,*]/10000) NE 3)*data[9,*])*0.1
  ;Data2 = data[9,*]*0.1
  outdata = [data[0,*], Mapx, MapY, Elevation, data[4:6,*], Data1]
  profixname = 'preci' ;�����������ļ�ǰ׺����Ϊ�����ַ�����''���޸�
  ;------------����Ϊ��Ҫ�޸ĵ�����---------
  
  ;Date = fix(data[4:6,*])
  ;����ת����Ľ������

  ;��ȡ�о�����Χ�ڵ�����
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
    suboutdir = outdir + "\" + strtrim(string(fix(outprint[4,0])),2)+ "\"+ profixname +"-" + $
      strtrim(string(fix(outprint[4,0])),2)+ $
      "-"+strtrim(string(fix(outprint[5,0])),2) $
      +"-"+strtrim(string(fix(outprint[6,0])),2)
    IF ~file_test(suboutdir) THEN file_mkdir, suboutdir
    ;����ļ�
    printfile = suboutdir +"\"+ profixname +"-" + $
      strtrim(string(fix(outprint[4,0])),2)+ $
      "-"+strtrim(string(fix(outprint[5,0])),2) $
      +"-"+strtrim(string(fix(outprint[6,0])),2)+'.dat'
    surcount = n_elements(outprint[*,0]) - 7
    openw,lun,printfile, /GET_LUN
    PRINTF,lun,FORMAT = $
      '(I5, F12.2, F12.2, F8.1,'+strtrim(string(surcount),2)+'F7.1)',$
      outprint[[0,1,2,3,[7:(7+surcount-1)]],*]
    free_lun, lun
    ;nsamples = n_elements(outprint[0,*]) + 40
    SetAnuSplinaPara, printfile, extent, surcount,cellsize = cellsize, splinafile,lapgrdfile
    ;print,splinafile ,lapgrdfile
    RunAnusplinaCMD, splinafile, lapgrdfile

  ENDFOREACH
  print,"finish"
  e.close
END


PRO AnusplineProcesStart
  COMPILE_OPT idl2
  ;-----------�޸��о�����Χ----------
  ;������λС��
  EXTENT = [[-79000, 1704000],[2080000, 3804000]]
  ;----------------

  filedir = file_dirname(ROUTINE_FILEPATH()) + "\" + "Rawdata"
  files = file_search(filedir,"*",count=n,/TEST_REGULAR)
  i = 0
  FOREACH file, files DO BEGIN
    i = i+1
    print, i
    GenerateAnusplineData, file, extent = extent
    ;spawn,"xcopy E:\������������\��������\Test\temperature H:\Data_For_DocArtical\ClimateData\temperature /e"
    ;filedir = file_search("E:\������������\��������\Test\temperature\*",/TEST_DIRECTORY)
   ; Spawn,"rd /s/q " + filedir
  ENDFOREACH

  ;spawn,"shutdown -s -t 600"

  print,"finished"

END