PRO GrdtoTiffBatch
  COMPILE_OPT idl2
  ;files = FILE_SEARCH("E:\基础地理数据\气象数据\Test\temperature\1992","*1992*.grd",/TEST_REGULAR)
  ;files = FILE_SEARCH("E:\基础地理数据\气象数据\Test\precipitation\1992","*1992*.grd",/TEST_REGULAR)
  i = 0
  files = file_search("E:\基础地理数据\气象数据\Test\temperature\1992","*",/TEST_REGULAR)
  ;files = file_search("E:\基础地理数据\气象数据\Test\precipitation\1992","*",/TEST_REGULAR)
  
  FOREACH file, files DO BEGIN
    print,i+1
    i = i+1
    ;    command = "py -2 E:\Landsat\PythonCode\DNDC_EXTRACTION.py " + $
    ;      file_dirname(file) + " " + file_basename(file) + " " + file_basename(file,".grd")+ "_sd.tif"
    ;    spawn,command
    ;    spawn,"del " + file
    copyfiledir = "H:\Data_For_DocArtical\ClimateData\temperature\" + file.extract("[0-9]{4}")+ path_sep() + $
      file.extract("Temp-[0-9]{4}-[0-9]+-[0-9]+")
    print, file.extract("Temp-[0-9]{4}-[0-9]+-[0-9]+")
;    copyfiledir = "H:\Data_For_DocArtical\ClimateData\precipitation\" + file.extract("[0-9]{4}")+ path_sep() + $
;      file.extract("Prec-[0-9]{4}-[0-9]+-[0-9]+")
    desfile = copyfiledir + "\" + file_Basename(file)
    if ~file_test(desfile) then spawn,"copy " + file + " " + copyfiledir
    ;spawn, "copy " + file_dirname(file)+"\"+file_basename(file,".grd")+ "_sd*.* " +copyfiledir
  ENDFOREACH
  print, "finished"
END