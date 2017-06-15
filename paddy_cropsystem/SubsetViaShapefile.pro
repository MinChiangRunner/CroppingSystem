PRO SubsetViaShapefile, Inputfile
  COMPILE_OPT idl2
  e = ENVI()
  file = 'E:\paddy_extr\Processing\RawResult\2010\numpeak_2010h27v0518_39_DE2_8_T33.dat'
  raster = e.OpenRaster(file)

  georec = [10184540.1284,2249383.3172,12043813.9935,3853371.8846]
  
  Task = ENVITask('GeographicSubsetRaster')

  ; Define inputs
  Task.INPUT_RASTER = Raster
  Task.SUB_RECT = geoRec

  ; Define outputs
  Task.OUTPUT_RASTER_URI = FILE_DIRNAME(file)+'\numpeak_2010h27v05_geosubset.dat'

  ; Run the task
  Task.Execute
  
END