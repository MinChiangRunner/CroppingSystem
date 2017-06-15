PRO layerstacking,rasters,layerStackRaster
  COMPILE_OPT idl2
  ;    e =envi(/HEADLESS)
  ;    Rasters =!NULL
  ;    raster1 = e.openraster('E:\Landsat\Processing\NewNDVI\127043\1992\Result\NDVI\LT05_L1TP_127043_19920818_20170123_01_T1_MTLRadFlaashNDVI.dat')
  ;    raster2 = e.openraster('E:\Landsat\Processing\NewNDVI\127043\1992\Result\NDVI\LT05_L1TP_127043_19931008_20170117_01_T1_MTLRadFlaashNDVI.dat')
  ;    Rasters = [raster1,raster2]
  ;ignore data
  ;  igdatas = !NULL
  ;  fids = !NULL

  ;  FOREACH raster, rasters THEN BEGIN
  ;    fid = ENVIRasterToFID(raster)
  ;    fids = [fids,fid]
  ;    IF (raster.METADATA.Hastag("DATA IGNORE VALUE")) THEN BEGIN
  ;      igdata = Raster.METADATA["DATA IGNORE VALUE"]
  ;    ENDIF ELSE BEGIN
  ;      igdata = 0.0
  ;    ENDELSE
  ;    igdatas = [igdatas,igdata]
  ;    GetFourCoor, Fid, coord,igdata
  ;  ENDFOREACH
  xmap_temp = !NULL
  ymap_temp = !NULL
  FOREACH raster, rasters DO BEGIN
    fid = ENVIRasterToFID(raster)
    ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, dims=dims
    ENVI_CONVERT_FILE_COORDINATES, fid, [0, ns-1], [0, nl-1], xmap, ymap, /to_map
    xmap_temp = [xmap_temp,xmap]
    ymap_temp = [ymap_temp,ymap]
  ENDFOREACH

  ;获取重叠区域的左上和右下地理坐标 - xmap和ymap
  ;xmap_tmp = [xmap1, xmap2]
  ;xmap = (xmap_tmp[SORT(xmap_tmp)])[1:2]
  xmap = [min(xmap_temp),max(xmap_temp)]
  ymap = [min(ymap_temp),max(ymap_temp)]
  ;ymap = (ymap_tmp[SORT(ymap_tmp)])[1:2]

  ;  oProj = ENVI_PROJ_CREATE(/GEOGRAPHIC)
  ;  iProj = ENVI_GET_PROJECTION(fid = fid)
  ;
  ;  ENVI_CONVERT_PROJECTION_COORDINATES,  $
  ;    xmap, ymap, iProj,    $
  ;    oXgeo, oYgeo, oProj
  ;
  SpatialRef = Rasters[-1].SPATIALREF
  ;  SpatialRef.covertlonlattomap, oXgeo[0],oYgeo[1],Mapx,Mapy
  Grid = ENVIGridDefinition(SPATIALREF.COORD_SYS_STR, $
    EXTENTS=[xmap[0],ymap[1],xmap[1],ymap[0]], $
    PIXEL_SIZE= [30.0D,30.0D])

  layerRasters = !NULL
  FOREACH raster, rasters DO BEGIN
    layerRaster = ENVISpatialGridRaster(raster, $
      GRID_DEFINITION=Grid)
    layerRasters = [layerRasters, layerRaster]
  ENDFOREACH

  layerStackRaster = ENVIMetaspectralRaster(layerRasters,SPATIALREF=layerRaster.SPATIALREF)
  ;layerStackRaster.EXPORT,"E:\Landsat\Processing\Temp\127043ndvilayerstack.dat","ENVI"
  ;
  ;  NDVIdifOUTFILE = 'E:\Landsat\Processing\VI\120040\NDVI\DIFFIDL.DAT'
  ;  NDVISZOUTFILE = 'E:\Landsat\Processing\VI\120040\NDVI\DIFFIDLsz1.DAT'

  ; Add

  ;  view = e.getview()
  ;  Layer1 = View.CreateLayer(LayerStackRaster, BANDS=0)
  ;  Layer2 = View.CreateLayer(LayerStackRaster, BANDS=1)
  PRINT,'Layer Stack Has Finished!'
  ;e.close
END