;+
  ; :AUTHOR: chiangmin
  ;- ��CMD������Anuspline ��ֵ����
  ;��Ҫ�޸ĵĲ���Ϊ�� ���Lapgrd.exe��splina.exe�Լ��߳�.txt���ݵ��ļ��е�ַ��
PRO AnusplinaCMD, splinecmd, lapgrdcmd
  COMPILE_OPT idl2
  ;splinecmd = $
  ;  "E:\������������\��������\Test\1990\Temp-1990-2-2\splinaTemp-1990-2-2.cmd" 
  
  ;�޸ĵı���
  copydir = "E:\������������\��������\BeCopied"
  copydir = file_dirname(ROUTINE_FILEPATH("AnusplinaCMD")) + "\" + "BeCopied"
  cmdfile = splinecmd
  ;����cmd��������
  ;  cmd = [[cmdfile.substring(0,1)],["cd "+ file_dirname(cmdfile)], $
  ;    ["splina<"+file_basename(splinecmd)>file_basename(splinecmd, ".cmd")+".log"], $
  ;    ["lapgrd<"+file_basename(lapgrdcmd)>file_basename(lapgrdcmd, ".cmd")+".log"]]
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
  printf,lun, "del chinadem_km_albescq_studyarea.txt"
  printf,lun, "del lapgrd.exe"
  printf,lun, "del splina.exe"
  ; printf,lun,"pause"
  free_lun,lun
  Spawn,"call " + batfile

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
END