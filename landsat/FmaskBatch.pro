PRO FmaskBatch, filedir
  COMPILE_OPT idl2
  filedir = "E:\Landsat\RawData\120040\2014"
  files = file_search(filedir,"*_MTL.txt",/TEST_REGULAR)
  e =envi(/current)
  Outdir = "E:\Landsat\Processing\Fmask"
  CloudRaster = !NULL
  FOREACH file, files DO BEGIN
    Raster = e.OpenRaster(file)
    MetaData = (Raster[0]).METADATA
    SENSOR_TYPE = MetaData["SENSOR TYPE"]
    CASE SENSOR_TYPE OF
      "Landsat OLI": BEGIN
        OLIBands = raster[0]
        CirrusBand = raster[2]
        ThermalBands = Raster[3]
        Cirrus = 1
      END
      "Landsat TM": BEGIN
        OLIBands = raster[0]
        ;CirrusBand = raster[2]
        ThermalBands = Raster[1]
        Cirrus = 0
      END
    ENDCASE

    ; Calibrater OLI bands to TOA reflectance
    ;RadOutfile = Outdir + PATH_SEP() + $
    ;  FILE_BASENAME(file,".dat")+"Rad.dat"
    RadTask = ENVITask('RadiometricCalibration')
    RadTask.INPUT_RASTER = OLIBands
    RadTask.CALIBRATION_TYPE = 'Top-of-Atmosphere Reflectance'
    ;RadTask.OUTPUT_RASTER_URI = RadOutfile
    RadTask.Execute

    ; Calibrate Cirrus band to TOA reflectance Only for Landsat OLI
    ;CirrusRadOutfile = Outdir + PATH_SEP() + $
    ;  FILE_BASENAME(file,".dat") +"CirrusRad.dat"
    IF Cirrus THEN BEGIN
      CirrusRadTask = ENVITask('RadiometricCalibration')
      CirrusRadTask.INPUT_RASTER = CirrusBand
      CirrusRadTask.CALIBRATION_TYPE = 'Top-of-Atmosphere Reflectance'
      ;RadTask.OUTPUT_RASTER_URI = CirrusRadOutfile
      CirrusRadTask.Execute
    ENDIF

    ; Calibrate thermal bands to brightness temperature
    ;BTOutfile = Outdir + PATH_SEP() + $
    ;  FILE_BASENAME(file,".dat")+"BT.dat"
    BTTask = ENVITask('RadiometricCalibration')
    BTTask.INPUT_RASTER = ThermalBands
    BTTask.CALIBRATION_TYPE = 'Brightness Temperature'
    ;RadTask.OUTPUT_RASTER_URI = BTOutfile
    BTTask.Execute

    ; Calculate cloud mask
    Outfile = Outdir + PATH_SEP() + $
      FILE_BASENAME(file,".dat")+"Fmask.dat"
    CloudTask = ENVITask('CalculateCloudMaskUsingFmask')
    CloudTask.INPUT_BRIGHTNESS_TEMPERATURE_RASTER = BTTask.OUTPUT_RASTER
    CloudTask.INPUT_CIRRUS_RASTER = CirrusRadTask.OUTPUT_RASTER
    CloudTask.INPUT_REFLECTANCE_RASTER = RadTask.OUTPUT_RASTER
    CloudTask.OUTPUT_RASTER_URI = Outfile
    CloudTask.Execute

    ; Composite rasters for LayerStacking
    CloudRaster = [CloudRaster,CloudTask.OUTPUT_RASTER]
  ENDFOREACH
  layerstackfile = Outdir + path_sep()+ "fmask1200402014.dat"
  layerstacking, CloudRaster, CLOUDLAYERSTACKING
  CLOUDLAYERSTACKING.Export, layerstackfile, 'ENVI'



  PRINT,"Fmask All Done"
  e.Close
END