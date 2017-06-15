PRO MosaicBatch, inputdir=inputdir, outdir=outdir
  ;��modis������Ƕ
  ;��ENVI5�ķ�ʽ
  COMPILE_OPT IDL2
  ;�ҵ��ļ�����:�ļ���ŽṹΪ��
  ;inputdir = 'E:\jim\HantsInput\360_180_120_90BSQHantsResult'
  inputdir = 'E:\jim\HantsInput\46_23_15_12\46_23_15_12SZRESULT'
  ;outdir = 'E:\jim\HantsInput\360_180_120_90BSQMosaic'
  outdir = 'E:\jim\HantsInput\46_23_15_12SZMosaic'
  ;  inputdir = 'E:\paddy_extr\site\SampleALL'
  ;  outdir = 'E:\paddy_extr\Processing\RawResult\0000'
;  IF ~(KEYWORD_SET(inputdir) AND KEYWORD_SET(inputdir)) THEN BEGIN
;    WHILE 1 DO BEGIN
;      inputdir = DIALOG_PICKFILE(/directory, title = "ѡ��Ҫ��Ƕ���ļ�·��")
;      IF inputdir EQ '' THEN BEGIN
;        ok = DIALOG_MESSAGE('δѡ���ļ���,�˳�?',/question)
;        IF ok EQ 'Yes' THEN RETURN
;      ENDIF ELSE BREAK
;    ENDWHILE
;    ;
;    WHILE 1 DO BEGIN
;      outdir = DIALOG_PICKFILE(/DIRECTORY,title = "ѡ������ļ�·��")
;      IF outdir EQ '' THEN BEGIN
;        ok = DIALOG_MESSAGE('δѡ���ļ���,�˳�?',/question)
;        IF ok EQ 'Yes' THEN RETURN
;      ENDIF ELSE BREAK
;    ENDWHILE
;  ENDIF
  ;��¼ʱ��
  starttime = SYSTIME(1)
  ;state envi 5.3
  e = ENVI()
  pfiles = FILE_SEARCH(inputdir,'*[0-9]???',count=nsub,/TEST_DIRECTORY)

  ;FOR j=0, num-1 DO BEGIN
  ;ѡ��evi | lswi| ndvi���ļ���
  ;   spfiles = FILE_SEARCH(pfiles[j],'*i',count = nsub,/TEST_DIRECTORY)
  ;    year = STRMID(pfiles[j],STRPOS(pfiles[j],'\',/REVERSE_SEARCH)+1)
  ;    ;����ݽ�������ļ��У���Ž��
  ;    IF ~FILE_TEST(outdir + year) THEN FILE_MKDIR, outdir + year
  ;    ;��ÿ��evi lswi ���� ndvi �ļ���������.img�ļ��������ں�
  FOR k = 0, nsub-1 DO BEGIN
    files = FILE_SEARCH(pfiles[k],'numpeak*.dat',/TEST_REGULAR);
    scenes = !NULL
    ;��ÿ��Raster ����һ��scenes��
    FOR i=0, N_ELEMENTS(files)-1 DO BEGIN
      raster = e.OPENRASTER(files[i])
      scenes = [scenes,raster]
    ENDFOR
    ;����ENVIMosaicRaster����
    mosaicRaster = ENVIMOSAICRASTER(scenes, $
      background = 0, $
;      color_matching_method = 'histogram matching', $
;      color_matching_stats = 'overlapping area', $
;      feathering_distance = 20, $
      feathering_method = 'seamline', $
      resampling = 'Nearest Neighbor', $
      seamline_method = 'geometry')

    ;�������·��
    ;newfile = ''
    OutFile = outdir + PATH_SEP() + $
      STREGEX(files[0],'numpeak_[0-9]{4}',/EXTRACT)+'.dat'
    ;OutFile = outdir + PATH_SEP() + 'Paddy_Mask'+'.dat'
    ;����һ���������ԣ����������
    ;       newfile = outdir + year + PATH_SEP() $
    ;        + files[0].EXTRACT('[0-9]{4}_(evi|lswi|ndvi).img$')
    IF FILE_TEST(OutFile) THEN FILE_DELETE, OutFile

    ;�����Ƕ���
    mosaicRaster.Export, outfile, 'envi'

    ;�ü�
    ;�о�������Χ
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
    
    ;��CommonPaddy ���л�ȡPaddy
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
    ;����ӱ���
    ;      mosaicRaster.SAVESEAMPOLYGONS, $
    ;        newfile.EXTRACT('.*[0-9]{4}')+'_seamline.shp';_(evi|lswi|ndvi)
    ;      ;      vector = e.OPENVECTOR(newfile+'_seamline.shp')
    ;      ;
    ;      ;      ;�򿪲���ʾդ��ͽӱ���
    ;      ;      mosaicRaster = e.OPENRASTER(newfile)
    ;      ;      view = e.GETVIEW()
    ;      ;      layer = view.CREATELAYER(mosaicRaster)
    ;      ;      vlayer = view.CREATELAYER(vector)
  ENDFOR
  ;ENDFOR
  proctime = STRING(ROUND((SYSTIME(1) - starttime)/60.0))
  e.CLOSE
  print,'Mosaic Finished,��ʱ'+proctime.COMPRESS()+'����!'
  ;OK = DIALOG_MESSAGE('�����,��ʱ'+proctime.COMPRESS()+'����!',/INFORMATION)
END