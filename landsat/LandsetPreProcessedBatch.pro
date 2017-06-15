PRO LandsetPreProcessedBatch, filedir
  COMPILE_OPT idl2
  ;filedir = "E:\Landsat\RawData\119040"
  ;  COLROW = '' ; 图副号
  ;  Year = '' ; 年份
  filedir = "D:\LandSat\Processing\120040\2014\RAWDATA"
  files = file_search(filedir,"*_MTL.txt", count=n, /TEST_REGULAR)

  ;建立文件夹，存放输出文件
  RadDir = FILE_DIRNAME(filedir) + "\Rad" ;Rad file directory
  FlasshDir = FILE_DIRNAME(filedir) + "\Flaash"
  IF ~FILE_TEST(RadDir) THEN FILE_MKDIR,RadDir
  IF ~FILE_TEST(FlasshDir) THEN FILE_MKDIR,FlasshDir
  e = envi()

  FOREACH file, files DO BEGIN
    OutURI =RadDir + path_sep()+ $
      file_basename(file,".txt")+"Rad.dat"
    raster = e.OpenRaster(file)

    ;提取头文件中获取时间，用于Flaash
    meta = strarr(file_lines(file))
    OpenR,lun,file,/get_lun
    readf,lun,meta
    free_lun,lun
    Yd = meta.extract('DATE_ACQUIRED = [0-9]{4}-[0-9]{2}-[0-9]{2}')
    Yd = Yd[where(yd NE "")].extract('[0-9]{4}-[0-9]{2}-[0-9]{2}')
    HS = meta.extract('SCENE_CENTER_TIME = "?[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]+Z"?')
    HS = HS[where(HS NE "")].extract('[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]+Z')

    ; 辐射定标
    Task = ENVITask('RadiometricCalibration')
    Task.INPUT_RASTER = Raster[0] ; Bands 1-7
    Task.OUTPUT_DATA_TYPE = 'Float'
    ;Task.OUTPUT_RASTER_URI =  OutURI
    Task.SCALE_FACTOR = 0.10
    Task.Execute
    Task.OUTPUT_RASTER.Export, OutURI, 'envi', INTERLEAVE= 'bil'
    Raster.close

    raster = e.OpenRaster(OutURI)
    Remeta = raster.METADATA
    IF where(Remeta.TAGS EQ 'acquisition time') EQ -1 THEN BEGIN
      outfile = OutURI.split('.dat')
      outfile = outfile[0] + '.hdr'
      OpenU,lun,outfile,/get_lun, /APPEND
      printf,lun,'acquisition time = ', Yd+'T'+HS
      free_lun,lun
    ENDIF
    Raster.Close
    
    ; 开始大气矫正 Flaash
    FlaashBatch, radiance_file = OutURI, outdir = FlasshDir


  ENDFOREACH

  print, "wc"
  e.Close

END
