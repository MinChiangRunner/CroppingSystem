PRO LandSatVICal, file, outfile ,NDVIImage, sensor = sensor
  COMPILE_OPT idl2
  ;  file = $
  ;    "H:\Landsat\Processing\Completed\118039\1990\Flaash\LT05_L1TP_118039_19900611_20170129_01_T1_MTLRadFlaash.dat"
  ;  ;outfile = FILE_DIRNAME(file) + path_Sep() + "TEMP1\1180391990NDVI.dat"
  ;  outfile = "E:\Landsat\Processing\Temp" + path_Sep()+ FILE_BASENAME(file,".dat") + "NDVI.dat"
  e = envi(/current)
  Raster = e.OpenRaster(file)
  ;sensor = 'Landsat OLI'
  print, " LandSat Vi Cal" + sensor
  CASE sensor OF
    'Landsat TM':BEGIN
      SWIR = Raster.getdata(bands=[3])
      NIR  = Raster.getdata(bands=[2])
    END
    'Landsat OLI': BEGIN
      SWIR = Raster.getdata(bands=[4])
      NIR  = Raster.getdata(bands=[3])
    END
    'Landsat ETM':BEGIN
      SWIR = Raster.getdata(bands=[3])
      NIR  = Raster.getdata(bands=[2])
    END
  ENDCASE

  NDVI = FLOAT((SWIR GT 0)*(SWIR - NIR)) / FLOAT((SWIR + NIR)*(SWIR GT 0))
  NDVIImage = ENVIRaster(NDVI, URI=OUTFILE, SPATIALREF=Raster.SPATIALREF)
  NDVIImage.SAVE
  ;e.close
END