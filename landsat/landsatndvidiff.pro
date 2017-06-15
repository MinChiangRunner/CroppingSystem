;+
; :AUTHOR: chiangmin
;两幅影像时计算NDVI差值，单幅影像计算单独影像

PRO landsatNDVIDiff, FlaashDir = FlaashDir, SEQ = SEQ, $
  sensor = sensor, TValue = TValue
  COMPILE_OPT IDL2

  ;���璁剧疆

  ;SEQ = 2 ;1 --���骞达�宸��澶т�0涓哄�瀛ｇ�锛��浜�涓哄�瀛ｇ�锛�2 -- ���骞达�宸��灏��0涓哄�瀛ｇ�锛�ぇ浜�涓哄�瀛ｇ�
  ;澶ф�������浠�
  ;FlaashDir = "E:\Landsat\Processing\119040\2014\Flaash"
  ;  FlaashDir = "H:\Landsat\Processing\2015s\119039\2016\Flaash"
  ;  SEQ = 1
  ;  sensor = 'Landsat OLI'
  ;  IF SEQ = "" THEN BEGIN
  ;    OK = DIALOG_MESSAGE("Please input Image sequence....",/ERROR )
  ;    stop
  ;  ENDIF
  ;Get the colums and Year
  COLROW = FlaashDir.extract('[0-9]{6}')
  YEAR = strmid(FlaashDir,STRPOS(FlaashDir,'\',/REVERSE_SEARCH)-4,4)

  files = file_search(FlaashDir, "*Flaash.dat",/TEST_REGULAR)
  IF FILES[0] EQ "" THEN BEGIN
    openu,lun,'E:\Landsat\Processing\NoFlaash.txt',/get_lun,/APPEND
    printf,lun,COLROW
    free_lun,lun
    return
  ENDIF

  ;Out Dir
  outdir = FILE_DIRNAME(FlaashDir) + PATH_SEP() + "Result"
  ;  outdir = "E:\Landsat\Processing\NewNDVI\" + COLROW + PATH_SEP() + YEAR + PATH_SEP() $
  ;    + "Result"
  NDVIDIR = outdir + path_sep()+ 'NDVI'
  ;Output files
  NDVIdifOUTFILE = outdir + PATH_SEP()+'NDVIDIFF\'+ COLROW +Year + 'NDVIDiff.dat'
  NDVISZOUTFILE = outdir + PATH_SEP()+'SZResult\'+ COLROW +Year  + 'NDVISZ0.7.dat'
  ;create files
  IF ~FILE_TEST(outdir) THEN FILE_MKDIR,outdir
  IF ~FILE_TEST(FILE_DIRNAME(NDVIdifOUTFILE)) THEN FILE_MKDIR,FILE_DIRNAME(NDVIdifOUTFILE)
  IF ~FILE_TEST(FILE_DIRNAME(NDVISZOUTFILE)) THEN FILE_MKDIR,FILE_DIRNAME(NDVISZOUTFILE)
  IF ~FILE_TEST(NDVIDIR) THEN FILE_MKDIR, NDVIDIR

  ;姘寸��╄���欢
  ;  Paddymask2010 = 'E:\Landsat\landsatBase\PaddyMask\2010\study_area_2010_Project.shp'
  ;  PaddymaskCommon = 'E:\Landsat\landsatBase\PaddyMask\CommonPaddy\COMMON_PADDY_wgs.shp'
  ;  paddymask2000 = 'E:\Landsat\landsatBase\PaddyMask\2000\study_area_paddy_2000_Project.shp'
  Paddymask2010 = 'E:\Landsat\landsatBase\PaddyMask\WBFPaddyMask2010.tif'
  PaddymaskCommon = 'E:\Landsat\landsatBase\PaddyMask\CommonPaddy\COMMON_PADDY_wgs.shp'
  paddymask2000 = 'E:\Landsat\landsatBase\PaddyMask\WBFPaddyMask1990.tif'
  ;e = envi()
  e = envi(/current);/current/headless

  NDVIRasters = !NULL
  FOREACH file, files DO BEGIN
    ;    SPATIALREF = Raster.SPATIALREF
    outfile = NDVIDIR + path_sep()+ $
      file_basename(file,".dat")+"NDVI.dat"
    IF ~file_test(outfile) THEN $
      LandSatVICal, file, outfile , NDVIImage, sensor = sensor ELSE $
      NDVIImage = e.OpenRaster(outfile)


    ;    NDVIImage = ENVISpectralIndexRaster(raster, 'NDVI')
    ;    NDVIImage.Export, outfile, 'ENVI'
    NDVIRasters =[NDVIRasters,NDVIImage]
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

  ENDFOREACH

  IF (N_ELEMENTS(NDVIRasters) EQ 2) THEN BEGIN
    ;layer stacking
    IF ~file_Test(NDVIdifOUTFILE) THEN BEGIN
      layerstacking, NDVIRasters, layerStackRaster
      fid = ENVIRasterToFID(layerStackRaster)
      ;Calculate DIFF OF NDVI
      ENVI_FILE_QUERY, fid, DIMS = dims
      ENVI_Doit, 'Math_Doit', $
        FID = [fid, fid], $
        DIMS = dims, $
        POS = [0,1], $
        EXP = 'float(((b1 ne 0.0) and (b2 ne 0.0))*(b1 - b2))/float((b1 ne 0.0) and (b2 ne 0.0))', $
        OUT_NAME = NDVIdifOUTFILE, $
        R_FID = diffid
    ENDIF ELSE envi_open_file, NDVIdifOUTFILE, r_fid=diffid
    ;
    ;Calculate SZ
    ;  rasterdiff = e.openraster(NDVIdifOUTFILE)
    ;  diffid = ENVIRasterToFID(rasterdiff)
    ENVI_FILE_QUERY, diffid, DIMS = dims
    ;'(b1 le 0)*1 + (b1 gt 0)*2'
    IF (SEQ EQ 1) THEN EXP = '(b1 le -0.1)*1 + (b1 gt 0.1)*2' ELSE $
      EXP = '(b1 le -0.1)*2 + (b1 gt 0.1)*1'
    ENVI_Doit, 'Math_Doit', $
      FID = [diffid], $
      DIMS = dims, $
      POS = [0], $
      EXP = EXP, $
      OUT_NAME = NDVISZOUTFILE, $
      R_FID = szfid
  ENDIF ELSE BEGIN
    ;单幅影像
    fid = ENVIRasterToFID(NDVIRasters)
    ENVI_FILE_QUERY, fid, DIMS = dims
    ; 对于单幅影像：7-8月份SEQ 1(大于T值的为单季稻，小于T值的为双季稻); 6 月或者10月 SEQ = 2，(与1相反)
    IF (SEQ EQ 1) THEN EXP = '((b1 lt 1) and (b1 ge 0.7))*1 + ((b1 lt 0.7) and (b1 ge -1))*2' $
    ELSE EXP = '((b1 lt 1) and (b1 ge 0.7))*2 + ((b1 lt 0.7) and (b1 ge -1))*1'
    ENVI_Doit, 'Math_Doit', $
      FID = [fid], $
      DIMS = dims, $
      POS = [0], $
      EXP = EXP, $
      OUT_NAME = NDVISZOUTFILE, $
      R_FID = szfid
  ENDELSE
  ;CLOUD MASK
  ;  OrSZRASTER = ENVIFIDToRaster(SZFID)
  ;  CirrMask = e.OpenRaster(Cirrs)
  ;  ;���涓���╄�锛�氨���娆℃���������ayerstacking ���浜��)
  ;  FOR i=0, CirrMask.BANDS DO BEGIN
  ;    ENVIMaskRasterTask(OrSZRASTER,
  ;  ENDFOR


  ;e.close
  ;利用PYTHON程序提取水稻掩膜的熟制
  ;Input Raster
  ;根据年份选择后缀名称
  arg1 = STRJOIN(NDVISZOUTFILE.split('\\'),"/")
  IF (year/1 GT 2010) THEN BEGIN
    arg2 = Paddymask2010
    profix = 'mask2010.tif'
  ENDIF ELSE BEGIN
    arg2 = paddymask2000
    profix = 'mask2000.tif'
  ENDELSE
  ;output files
  arg3 = strmid(arg1,0,strpos(arg1,"/",/REVERSE_SEARCH))+"/"+ $
    file_basename(arg1,'.dat')  + profix
  cmd = strjoin(["py -2 E:\\Landsat\\PythonCode\\Extraction.py",arg1,arg2,arg3]," ")
  spawn, cmd
  ;
  ;  ;COMMON PADDY Mask
  ;  arg2 = PaddymaskCommon
  ;  arg3 = strmid(arg1,0,strpos(arg1,"/",/REVERSE_SEARCH))+"/"+ $
  ;    file_basename(arg1,'.dat')  + 'maskcommon.tif'
  ;  cmd = strjoin(["py -2 E:\\Landsat\\PythonCode\\Extraction.py",arg1,arg2,arg3]," ")
  ;  spawn, cmd

  print,'landsatNDVIDiff finished'

END

