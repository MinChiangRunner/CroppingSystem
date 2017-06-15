PRO LayerStack
  COMPILE_OPT idl2
  e = ENVI(/headless)
  RefRaster = e.OpenRaster('D:\HANTEVI2014R_psf')
  SpatialRef = RefRaster.SPATIALREF
  bbRaster = e.OpenRaster('D:\M\MStacked',SPATIALREF_OVERRIDE= SpatialRef)
  bbRaster.Export,'D:\M\MStackedRef','envi'


  files = FILE_SEARCH('D:\M','*[0-9]',COUNT=n,/TEST_REGULAR)
  rasters =!NULL
  FOR i = 0, n-1 DO BEGIN
    raster1 = e.OpenRaster(files[i])
    rasters = [rasters, raster1]
  ENDFOR

  ; Get the task from the catalog of ENVITasks
  Task = ENVITask('BuildBandStack')

  ; Define inputs
  Task.INPUT_RASTERS = rasters

  ; Define outputs
  Task.OUTPUT_RASTER_URI = 'D:\M\MStacked'

  ; Run the task
  Task.Execute

  e.Close



END