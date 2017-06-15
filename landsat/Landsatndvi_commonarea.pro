;+
; :AUTHOR: chiangmin
;-试图通过寻找公共区域，计算NDVI的差值，效果不好


PRO landsatNDVI_commonarea
  COMPILE_OPT IDL2
  ;indir = "E:\Landsat\Processing\FLAASH\119040"
  indir = 'E:\Landsat\Processing\FLAASH\120040\2014'
  files = file_search(indir, "*Flaash.dat", /TEST_REGULAR)
  ;outdir = "E:\Landsat\Processing\VI\119040\1992"
  outdir = "E:\Landsat\Processing\VI\120040\NDVI"
  outshapefile = $
    "E:\Landsat\Processing\FLAASH\120040\2014\COMMONSHIPE\2014162210Overlay124.shp
  e = envi();/headless
  Rasters = !NULL
  FOREACH file, files DO BEGIN
    Raster = e.OpenRaster(file)
    SPATIALREF = Raster.SPATIALREF
    ;    outfile = outdir + path_sep()+ $
    ;      file_basename(file,".dat")+"NDVI.dat"
    ;    NDVIImage = ENVISpectralIndexRaster(raster, 'NDVI')
    ;    NDVIImage.Export, outfile, 'ENVI'

    ;    ;Calculate LSWI
    ;    sensor = 'Landsat TM'
    ;    ;sensor = 'Landsat OLI'
    ;    outfile = outdir + path_sep()+ $
    ;      file_basename(file,".dat")+"LSWI.dat"
    ;    ;Calculate LSWI
    ;    CASE sensor OF
    ;      'Landsat TM':BEGIN
    ;        SWIR = Raster.getdata(bands=[4])
    ;        NIR  = Raster.getdata(bands=[3])
    ;      END
    ;      'Landsat OLI': BEGIN
    ;        SWIR = Raster.getdata(bands=[5])
    ;        NIR  = Raster.getdata(bands=[4])
    ;      END
    ;    ENDCASE
    ;    LSWI = FLOAT(NIR - SWIR)/FLOAT(NIR + SWIR)
    ;    LswiRaster = ENVIRaster(LSWI, URI= outfile, SPATIALREF= SPATIALREF)
    ;    LswiRaster.Save
    Rasters = [Rasters,Raster]
  ENDFOREACH



    ; get the overlap shapefile of images
    fid11 = ENVIRasterToFID(Rasters[0])
    fid22 = ENVIRasterToFID(RasterS[1])
    fids = [fid11,fid22]
    ;Get "Data ignore value" for each raster
  
    IF (Rasters[0].METADATA.Hastag("DATA IGNORE VALUE")) THEN BEGIN
      igdata11 = Rasters[0].METADATA["DATA IGNORE VALUE"]
    ENDIF ELSE BEGIN
      igdata11 = 0.0
    ENDELSE
    IF (RasterS[1].METADATA.Hastag("DATA IGNORE VALUE")) THEN BEGIN
      igdata22 = RasterS[1].METADATA["DATA IGNORE VALUE"]
    ENDIF ELSE BEGIN
      igdata22 = 0.0
    ENDELSE
    igdatas = [igdata11,igdata22]
    OverlayShapefile, fids, outshapefile, igdatas

  ; Diff = NDVI_T1 - NDVI_T2
  NDVIDIFSZ, outdir, outshapefile

  e.close
  print,'finished'

END