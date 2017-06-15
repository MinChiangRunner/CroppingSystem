PRO ClimateDataProcesStart
  COMPILE_OPT idl2
  ;EXTENT = [[-52705.307034D, 1699294.69297D],[2101820.71722D,3755820.71722D]]
  ;EXTENT = [[-52705.3D, 1699294.7D],[2101820.7D,3755820.7D]]
  EXTENT = [[-79000, 1704000],[2080000, 3804000]]


  filedir = "E:\基础地理数据\气象数据\数据\temperture\BatchWork"
  files = file_search(filedir,"*",count=n,/TEST_REGULAR)
  i = 0
  FOREACH file, files DO BEGIN
    i = i+1
    print, i
    GenerateClimateData, file, extent = extent
    spawn,"xcopy E:\基础地理数据\气象数据\Test\temperature H:\Data_For_DocArtical\ClimateData\temperature /e"
    filedir = file_search("E:\基础地理数据\气象数据\Test\temperature\*",/TEST_DIRECTORY)
    Spawn,"rd /s/q " + filedir
  ENDFOREACH
  
 
  filedir = "E:\基础地理数据\气象数据\数据\precipitation\BatchWork"
  files = file_search(filedir,"*",count=n,/TEST_REGULAR)
  i = 0
  FOREACH file, files DO BEGIN
    i = i+1
    print, i
    GeneratePrecipitation, file, extent = extent
    spawn,"xcopy E:\基础地理数据\气象数据\Test\precipitation H:\Data_For_DocArtical\ClimateData\precipitation /e"
    filedir = file_search("E:\基础地理数据\气象数据\Test\precipitation\*",/TEST_DIRECTORY)
    Spawn,"rd /s/q " + filedir
  ENDFOREACH

  spawn,"shutdown -s -t 600"

  print,"finished"

END