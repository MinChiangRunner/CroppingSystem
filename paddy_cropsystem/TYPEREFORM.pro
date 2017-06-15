PRO TYPEREFORM
  COMPILE_OPT IDL2
  e = ENVI(/headless);
;  task = ENVITASK('RasterSubsetViaShapefileClassicDu')
;  task.INPUT_RASTERS = raster
;  task.input_vector = 
  file = 'E:\paddy_extr\index\2014\h28v06_2014_evi.dat'
  raster = e.OPENRASTER(file)
  SpatialReF = raster.SPATIALREF
  data = raster.GETDATA()
  ;´Ó³¤Õ÷
  PRINT, MAX(data), MIN(data)
  outfile  = ''

  ;
  Spatialref = raster.SPATIALREF
  OutName = 'E:\paddy_extr\index\2010\evi\h28v06_2010_evi_int10000'
  intdata =   FIX(ROUND(((data LT 0)*0 + (data GT 1)*1 + $
    ((data GE 0) AND (data LE 1))*data)*10000))
  OutRaster = ENVIRASTER(intdata, URI=OutName, SPATIALREF=SPATIALREF)
  OutRaster.SAVE
  e.CLOSE
END