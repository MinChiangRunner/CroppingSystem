;+
; :DESCRIPTION:
;    裁剪-> 分解合并 -> 合成；
;    由于直接合并有46波段的evi数据量太大，IDL输出不了结果.
;    于是先裁剪，然后再一个波段一个波段合并，最后再合并；
;    注意：一个波段一个波段合并没有中间输出文件；
;    结果好像有问题。
; :AUTHOR: chiangmin
;-
PRO SubsetThenMOsaic
  COMPILE_OPT IDL2
  starttime = SYSTIME(1)
  indir ='E:\paddy_extr\FourMosaic'
  outdir = 'E:\paddy_extr\FourMosaic\2010\result'

  indirs = FILE_SEARCH(indir,'*[0-9]???', count=nsub,/TEST_DIRECTORY)
  e = ENVI()
  FOR i=0, nsub-1 DO BEGIN
    pfiles = FILE_SEARCH(indirs[i],'*_psf_BSQ.dat', count=nfile,/TEST_REGULAR);
    SubRaster = !NULL
    FOR j=0, nfile-1 DO BEGIN
      Raster = e.openraster(pfiles[j])
      georect = [10184540.1284,2249383.3172,12043813.9935,3853371.8846]
      Task = ENVITask('GeographicSubsetRaster')
      ; Define inputs
      Task.INPUT_RASTER = Raster
      Task.SUB_RECT = geoRect
      ; Define outputs
      Task.OUTPUT_RASTER_URI = outdir +'\Subset\' $
        +FILE_BASENAME(pfiles[j],'.dat')+'_subset1.dat'
      ; Run the task
      Task.Execute
      SubRaster = [SubRaster, Task.OUTPUT_RASTER]
    ENDFOR

    ;镶嵌
    ;    nbs = SubRaster[0].NBANDS
    ;    sences = !NULL
    ;    mosaic = !NULL
    ;    FOR k=0, nbs-1 DO BEGIN
    ;      raster0 = ENVISubsetRaster(SubRaster[0], BANDS = k)
    ;      raster1 = ENVISubsetRaster(SubRaster[1], BANDS = k)
    ;      raster2 = ENVISubsetRaster(SubRaster[2], BANDS = k)
    ;      raster3 = ENVISubsetRaster(SubRaster[3], BANDS = k)
    ;      sences = [raster0, raster1,raster2,raster3]
    ;      mosaicRaster = ENVIMOSAICRASTER(sences, $
    ;        background = 0, $
    ;        color_matching_method = 'histogram matching', $
    ;        color_matching_stats = 'overlapping area', $
    ;        feathering_distance = 20, $
    ;        feathering_method = 'seamline', $
    ;        resampling = 'Nearest Neighbor', $
    ;        seamline_method = 'geometry')
    ;      mosaic  = [mosaic, mosaicRaster]
    ;    ENDFOR
    ;    ;组合起来



    ; Get the task from the catalog of ENVITasks
    Task = ENVITask('BuildMosaicRaster')
    ; Define inputs
    Task.INPUT_RASTERS = SubRaster
    Task.COLOR_MATCHING_METHOD = 'Histogram Matching'
    Task.COLOR_MATCHING_STATISTICS = 'Entire Scene'
    Task.FEATHERING_METHOD = 'Edge'
    Task.FEATHERING_DISTANCE = [20,20,20,20]

    ; Define outputs
    OutFile = outdir + PATH_SEP() + $
      STREGEX(pfiles[0],'[0-9]{4}',/EXTRACT)+'_evi1.dat'
    IF FILE_TEST(OutFile) THEN FILE_DELETE, OutFile
    Task.OUTPUT_RASTER_URI = OutFile

    ; Run the task
    Task.Execute

;
;    Task = ENVITask('BuildBandStack')
;    ; Define inputs
;    Task.INPUT_RASTERS = mosaic
;    ; Define outputs
;    Task.OUTPUT_RASTER_URI = OutFile
;    ; Run the task
;    Task.Execute
  ENDFOR
  proctime = STRING(ROUND((SYSTIME(1) - starttime)/60.0))
  e.CLOSE
  OK = DIALOG_MESSAGE('完成了,用时'+proctime.COMPRESS()+'分钟!',/INFORMATION)

END