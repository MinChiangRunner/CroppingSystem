PRO MosaicBatch, inputdir=inputdir, outdir=outdir
  ;将modis数据镶嵌
  ;用ENVI5的方式
  COMPILE_OPT IDL2
  ;找到文件所在:文件存放结构为：
  ;inputdir = 'E:\jim\HantsInput\360_180_120_90BSQHantsResult'
  inputdir = 'E:\jim\HantsInput\46_23_15_12\46_23_15_12SZRESULT'
  ;outdir = 'E:\jim\HantsInput\360_180_120_90BSQMosaic'
  outdir = 'E:\jim\HantsInput\46_23_15_12SZMosaic'
  ;  inputdir = 'E:\paddy_extr\site\SampleALL'
  ;  outdir = 'E:\paddy_extr\Processing\RawResult\0000'
;  IF ~(KEYWORD_SET(inputdir) AND KEYWORD_SET(inputdir)) THEN BEGIN
;    WHILE 1 DO BEGIN
;      inputdir = DIALOG_PICKFILE(/directory, title = "选择要镶嵌的文件路径")
;      IF inputdir EQ '' THEN BEGIN
;        ok = DIALOG_MESSAGE('未选择文件夹,退出?',/question)
;        IF ok EQ 'Yes' THEN RETURN
;      ENDIF ELSE BREAK
;    ENDWHILE
;    ;
;    WHILE 1 DO BEGIN
;      outdir = DIALOG_PICKFILE(/DIRECTORY,title = "选择输出文件路径")
;      IF outdir EQ '' THEN BEGIN
;        ok = DIALOG_MESSAGE('未选择文件夹,退出?',/question)
;        IF ok EQ 'Yes' THEN RETURN
;      ENDIF ELSE BREAK
;    ENDWHILE
;  ENDIF
  ;记录时间
  starttime = SYSTIME(1)
  ;state envi 5.3
  e = ENVI()
  pfiles = FILE_SEARCH(inputdir,'*[0-9]???',count=nsub,/TEST_DIRECTORY)

  ;FOR j=0, num-1 DO BEGIN
  ;选择evi | lswi| ndvi等文件夹
  ;   spfiles = FILE_SEARCH(pfiles[j],'*i',count = nsub,/TEST_DIRECTORY)
  ;    year = STRMID(pfiles[j],STRPOS(pfiles[j],'\',/REVERSE_SEARCH)+1)
  ;    ;按年份建立输出文件夹，存放结果
  ;    IF ~FILE_TEST(outdir + year) THEN FILE_MKDIR, outdir + year
  ;    ;在每个evi lswi 或者 ndvi 文件夹内搜索.img文件，进行融合
  FOR k = 0, nsub-1 DO BEGIN
    files = FILE_SEARCH(pfiles[k],'numpeak*.dat',/TEST_REGULAR);
    scenes = !NULL
    ;将每个Raster 放在一个scenes中
    FOR i=0, N_ELEMENTS(files)-1 DO BEGIN
      raster = e.OPENRASTER(files[i])
      scenes = [scenes,raster]
    ENDFOR
    ;创建ENVIMosaicRaster对象
    mosaicRaster = ENVIMOSAICRASTER(scenes, $
      background = 0, $
;      color_matching_method = 'histogram matching', $
;      color_matching_stats = 'overlapping area', $
;      feathering_distance = 20, $
      feathering_method = 'seamline', $
      resampling = 'Nearest Neighbor', $
      seamline_method = 'geometry')

    ;设置输出路径
    ;newfile = ''
    OutFile = outdir + PATH_SEP() + $
      STREGEX(files[0],'numpeak_[0-9]{4}',/EXTRACT)+'.dat'
    ;OutFile = outdir + PATH_SEP() + 'Paddy_Mask'+'.dat'
    ;下面一条本机可以，其机器报错
    ;       newfile = outdir + year + PATH_SEP() $
    ;        + files[0].EXTRACT('[0-9]{4}_(evi|lswi|ndvi).img$')
    IF FILE_TEST(OutFile) THEN FILE_DELETE, OutFile

    ;输出镶嵌结果
    mosaicRaster.Export, outfile, 'envi'

    ;裁剪
    ;研究区地理范围
    georect = [10184540.1284,2249383.3172,12043813.9935,3853371.8846]
    Task = ENVITask('GeographicSubsetRaster')
    ; Define inputs
    Task.INPUT_RASTER = mosaicRaster
    Task.SUB_RECT = geoRect
    ; Define outputs
    Task.OUTPUT_RASTER_URI = FILE_DIRNAME(OutFile)+ $
      PATH_SEP()+FILE_BASENAME(outfile,'.dat')+'_subset.dat';+''
    ; Run the task
    Task.Execute
    
    ;用CommonPaddy 进行获取Paddy
    PaddyFile = 'E:\jim\PaddyMask\Paddy_Mask.dat'
    PaddyRaster = e.openraster(PaddyFile)
    paddy = PaddyRaster.getdata()
    spatialref = PaddyRaster.spatialref
    SZraster = task.output_Raster
    SZ = SZraster.getdata()
    SZIN= sz*paddy
    outfile = outdir+PATH_SEP() + $
      STREGEX(files[0],'numpeak_[0-9]{4}',/EXTRACT)+'_Paddy.dat'
    outRaster = enviraster(szin,uri=outfile,spatialref=spatialref)
    outraster.save
    ;保存接边线
    ;      mosaicRaster.SAVESEAMPOLYGONS, $
    ;        newfile.EXTRACT('.*[0-9]{4}')+'_seamline.shp';_(evi|lswi|ndvi)
    ;      ;      vector = e.OPENVECTOR(newfile+'_seamline.shp')
    ;      ;
    ;      ;      ;打开并显示栅格和接边线
    ;      ;      mosaicRaster = e.OPENRASTER(newfile)
    ;      ;      view = e.GETVIEW()
    ;      ;      layer = view.CREATELAYER(mosaicRaster)
    ;      ;      vlayer = view.CREATELAYER(vector)
  ENDFOR
  ;ENDFOR
  proctime = STRING(ROUND((SYSTIME(1) - starttime)/60.0))
  e.CLOSE
  print,'Mosaic Finished,用时'+proctime.COMPRESS()+'分钟!'
  ;OK = DIALOG_MESSAGE('完成了,用时'+proctime.COMPRESS()+'分钟!',/INFORMATION)
END