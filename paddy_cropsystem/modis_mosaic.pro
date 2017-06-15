PRO MODIS_MOSAIC
  ;将modis数据镶嵌
  ;用ENVI5的方式
  COMPILE_OPT IDL2
  ;找到文件所在:文件存放结构为：
  ;--file dir
  ; |--year1 (2010)
  ;   |--evi
  ;     |--行列号_年份_evi.img 按行列号4多个
  ;   |--ndvi
  ;     |--行列号_年份_ndvi.img 按行列号4多个
  ;   |--lswi
  ;     |--行列号_年份_lswi.img 按行列号4多个
  ; |--year2 (2011)
  ;   |--evi
  ;     |--行列号_年份_evi.img 按行列号4多个
  ;   |--ndvi
  ;     |--行列号_年份_ndvi.img 按行列号4多个
  ;   |--lswi
  ;     |--行列号_年份_lswi.img 按行列号4多个
  ; |......
  ;选一级路径pfiles -> 一级内多个少year的文件夹路径pfiles ->
  ;spfiles每个pfiles内3个文件夹 -> 每个spfiles子文件夹内的files
  ;选择输入输出文件夹：
  WHILE 1 DO BEGIN
    inputdir = DIALOG_PICKFILE(/directory, title = "选择要镶嵌的文件路径")
    IF inputdir EQ '' THEN BEGIN
      ok = DIALOG_MESSAGE('未选择文件夹,退出?',/question)
      IF ok EQ 'Yes' THEN RETURN
    ENDIF ELSE BREAK
  ENDWHILE
  ;
  WHILE 1 DO BEGIN
    outdir = DIALOG_PICKFILE(/DIRECTORY,title = "选择输出文件路径")
    IF outdir EQ '' THEN BEGIN
      ok = DIALOG_MESSAGE('未选择文件夹,退出?',/question)
      IF ok EQ 'Yes' THEN RETURN
    ENDIF ELSE BREAK
  ENDWHILE
  ;记录时间
  starttime = SYSTIME(1)
  ;state envi 5.3
  e = ENVI()
  pfiles = FILE_SEARCH(inputdir,'*[0-9]???',count=num,/TEST_DIRECTORY)

  FOR j=0, num-1 DO BEGIN
    ;选择evi | lswi| ndvi等文件夹
    spfiles = FILE_SEARCH(pfiles[j],'*i',count = nsub,/TEST_DIRECTORY)
    year = STRMID(pfiles[j],STRPOS(pfiles[j],'\',/REVERSE_SEARCH)+1)
    ;按年份建立输出文件夹，存放结果
    IF ~FILE_TEST(outdir + year) THEN FILE_MKDIR, outdir + year
    ;在每个evi lswi 或者 ndvi 文件夹内搜索.img文件，进行融合
    FOR k = 0, nsub-1 DO BEGIN

      files = FILE_SEARCH(spfiles[k],'*.dat',/TEST_REGULAR)
      scenes = !NULL
      ;将每个Raster 放在一个scenes中
      FOR i=0, N_ELEMENTS(files)-1 DO BEGIN
        raster = e.OPENRASTER(files[i])
        scenes = [scenes,raster]
      ENDFOR
      ;创建ENVIMosaicRaster对象
      mosaicRaster = ENVIMOSAICRASTER(scenes, $
        background = 0, $
        color_matching_method = 'histogram matching', $
        color_matching_stats = 'overlapping area', $
        feathering_distance = 20, $
        feathering_method = 'seamline', $
        resampling = 'Nearest Neighbor', $
        seamline_method = 'geometry')

      ;设置输出路径
      newfile = ''
      newfile = outdir + year + PATH_SEP() + $
        STREGEX(files[0],'[0-9]{4}.dat$',/EXTRACT);_(evi|lswi|ndvi)
      ;下面一条本机可以，其机器报错
      ;       newfile = outdir + year + PATH_SEP() $
      ;        + files[0].EXTRACT('[0-9]{4}_(evi|lswi|ndvi).img$')
      IF FILE_TEST(newfile) THEN FILE_DELETE, newfile

      ;输出镶嵌结果
      mosaicRaster.EXPORT, newfile, 'ENVI'


      ;保存接边线
      mosaicRaster.SAVESEAMPOLYGONS, $
        newfile.EXTRACT('.*[0-9]{4}')+'_seamline.shp';_(evi|lswi|ndvi)
      ;      vector = e.OPENVECTOR(newfile+'_seamline.shp')
      ;
      ;      ;打开并显示栅格和接边线
      ;      mosaicRaster = e.OPENRASTER(newfile)
      ;      view = e.GETVIEW()
      ;      layer = view.CREATELAYER(mosaicRaster)
      ;      vlayer = view.CREATELAYER(vector)
    ENDFOR
  ENDFOR
  proctime = STRING(ROUND((SYSTIME(1) - starttime)/60.0))
  e.CLOSE
  OK = DIALOG_MESSAGE('完成了,用时'+proctime.COMPRESS()+'分钟!',/INFORMATION)
END