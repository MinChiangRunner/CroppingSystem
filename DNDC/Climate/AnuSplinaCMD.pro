;+
  ; :AUTHOR: chiangmin
  ;- 在CMD里运行Anuspline 插值过程
  ;需要修改的参数为： 存放Lapgrd.exe、splina.exe以及高程.txt数据的文件夹地址；
PRO AnusplinaCMD, splinecmd, lapgrdcmd
  COMPILE_OPT idl2
  ;splinecmd = $
  ;  "E:\基础地理数据\气象数据\Test\1990\Temp-1990-2-2\splinaTemp-1990-2-2.cmd" 
  
  ;修改的变量
  copydir = "E:\基础地理数据\气象数据\BeCopied"
  copydir = file_dirname(ROUTINE_FILEPATH("AnusplinaCMD")) + "\" + "BeCopied"
  cmdfile = splinecmd
  ;构建cmd运行命令
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

  ; lapgrdcmd 参数设置
 
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

  ;用python裁剪到研究区范围
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