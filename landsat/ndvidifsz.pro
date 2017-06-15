PRO NDVIDIFSZ,NDVIdir,outshapefile
  COMPILE_OPT idl2
  ;  NDVIDIR = "E:\Landsat\Processing\VI\120040\NDVI"
  ;  NDVIDIR = "E:\Landsat\Processing\FLAASH\120040\2014"
  NDVIFILES = file_search(NDVIDIR,'*ndvi.dat',/TEST_REGULAR)
  ;  outshapefile = $
  ;    'E:\Landsat\Processing\FLAASH\120040\2014\COMMONSHIPE\1200402014comm2.shp'
  e = envi(/CURRENT)
  Raster1 = e.OpenRaster(NDVIFILES[0])
  ;  fid11 = ENVIRasterToFID(Raster1)
  Raster2 = e.OpenRaster(NDVIFILES[1])
  ;  fid22 = ENVIRasterToFID(Raster2)
  ;  fids = [fid11,fid22]
  ;  ;Get Data ignore value" for each raster
  ;
  ;  IF (raster1.METADATA.Hastag("DATA IGNORE VALUE")) THEN BEGIN
  ;    igdata11 = raster1.METADATA["DATA IGNORE VALUE"]
  ;  ENDIF ELSE BEGIN
  ;    igdata11 = 0.0
  ;  ENDELSE
  ;  IF (raster2.METADATA.Hastag("DATA IGNORE VALUE")) THEN BEGIN
  ;    igdata22 = raster2.METADATA["DATA IGNORE VALUE"]
  ;  ENDIF ELSE BEGIN
  ;    igdata22 = 0.0
  ;  ENDELSE
  ;  igdatas = [igdata11,igdata22]
  ;  OverlayShapefile,fids, outshapefile, igdatas


  ;Subset data via shapefile

  ;  Vectorfile = "E:\Landsat\Processing\FLAASH\120040\2014\COMMONSHIPE\1200402014Overlayshapefile.shp"
  vectorob = e.OpenVector(outshapefile)
  ;Raster = e.OpenRaster(ndvifiles[0])
  ; mask the input raster using all the records from the vector data
;  rasterWithMask1 = ENVIVectorMaskRaster(raster1, vectorob)
;  rasterWithMask2 = ENVIVectorMaskRaster(raster2, vectorob)
  
  ;Calculate the diff of NDVI
  URI = NDVIdir + PATH_SEP()+FILE_BASENAME(NDVIFILES[0],'.dat')+'diff.dat'
  diff = rasterWithMask1.getdata() - rasterWithMask2.getdata()
  diffRaster = ENVIRaster(diff,URI=URI, SPATIALREF= Raster1.SPATIALREF)
  diffRaster.Save
  ; display the new raster, the masked areas are transparent
  ;  view = e.GetView()
  ;  layer1 = view.CreateLayer(rasterWithMask1)
  ;  layer2 = view.CreateLayer(rasterWithMask2)
  print,"wanc"
  ;  ;SPATIALREF1 = Raster1.SPATIALREF
  ;  ;NDVIRaster2 = ENVISubsetRaster(Raster1, SPATIALREF=SPATIALREF1,SUB_RECT=[xmap[0], ymap[1], xmap[1], ymap[0]])
  ;  diff = NDVIRaster1.getdata() - NDVIRaster2.getdata()
  ;  diffRaster = ENVIRaster(diff,URI='E:\Landsat\Processing\VI\120040\NDVI\diff.dat', SPATIALREF= Raster1.SPATIALREF)
  ;  diffRaster.Save
END