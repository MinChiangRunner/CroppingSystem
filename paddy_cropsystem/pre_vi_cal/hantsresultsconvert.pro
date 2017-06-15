PRO HantsResultsConvert
  COMPILE_OPT idl2
  e = ENVI(/HEADLESS)
  ; Create an ENVIRaster
  ;file = FILEPATH('qb_boulder_pan', ROOT_DIR=e.ROOT_DIR, $
  ;  SUBDIRECTORY = ['data'])
  ;参考投影坐标系文件
  Refile = 'E:\paddy_extr\index\2014\h28v06_2014_evi.dat'
  raster = e.OPENRASTER(Refile)
  SpatialReF = raster.SPATIALREF
  
  ;需要转的文件
  file = 'HANtEVI2014360B_psf'
  data = raster.GETDATA()
  ;将数据转为BYTE 和 bil格式,并输出
  IF 0 THEN BEGIN
    OutFile = FILE_DIRNAME(file)+ PATH_SEP() + FILE_BASENAME(file,'.dat') +'BIL.dat'
    OutRaster = ENVIRaster(transpose(byte(round(data/100.0)),[0,2,1]), $
      DATA_TYPE = 1,INTERLEAVE='bil',SpatialReF =SPATIALREF ,URI=Outfile)
    outraster.SAVE
  ENDIF


END