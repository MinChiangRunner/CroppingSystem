PRO MODIS_MOSAIC
  ;��modis������Ƕ
  ;��ENVI5�ķ�ʽ
  COMPILE_OPT IDL2
  ;�ҵ��ļ�����:�ļ���ŽṹΪ��
  ;--file dir
  ; |--year1 (2010)
  ;   |--evi
  ;     |--���к�_���_evi.img �����к�4���
  ;   |--ndvi
  ;     |--���к�_���_ndvi.img �����к�4���
  ;   |--lswi
  ;     |--���к�_���_lswi.img �����к�4���
  ; |--year2 (2011)
  ;   |--evi
  ;     |--���к�_���_evi.img �����к�4���
  ;   |--ndvi
  ;     |--���к�_���_ndvi.img �����к�4���
  ;   |--lswi
  ;     |--���к�_���_lswi.img �����к�4���
  ; |......
  ;ѡһ��·��pfiles -> һ���ڶ����year���ļ���·��pfiles ->
  ;spfilesÿ��pfiles��3���ļ��� -> ÿ��spfiles���ļ����ڵ�files
  ;ѡ����������ļ��У�
  WHILE 1 DO BEGIN
    inputdir = DIALOG_PICKFILE(/directory, title = "ѡ��Ҫ��Ƕ���ļ�·��")
    IF inputdir EQ '' THEN BEGIN
      ok = DIALOG_MESSAGE('δѡ���ļ���,�˳�?',/question)
      IF ok EQ 'Yes' THEN RETURN
    ENDIF ELSE BREAK
  ENDWHILE
  ;
  WHILE 1 DO BEGIN
    outdir = DIALOG_PICKFILE(/DIRECTORY,title = "ѡ������ļ�·��")
    IF outdir EQ '' THEN BEGIN
      ok = DIALOG_MESSAGE('δѡ���ļ���,�˳�?',/question)
      IF ok EQ 'Yes' THEN RETURN
    ENDIF ELSE BREAK
  ENDWHILE
  ;��¼ʱ��
  starttime = SYSTIME(1)
  ;state envi 5.3
  e = ENVI()
  pfiles = FILE_SEARCH(inputdir,'*[0-9]???',count=num,/TEST_DIRECTORY)

  FOR j=0, num-1 DO BEGIN
    ;ѡ��evi | lswi| ndvi���ļ���
    spfiles = FILE_SEARCH(pfiles[j],'*i',count = nsub,/TEST_DIRECTORY)
    year = STRMID(pfiles[j],STRPOS(pfiles[j],'\',/REVERSE_SEARCH)+1)
    ;����ݽ�������ļ��У���Ž��
    IF ~FILE_TEST(outdir + year) THEN FILE_MKDIR, outdir + year
    ;��ÿ��evi lswi ���� ndvi �ļ���������.img�ļ��������ں�
    FOR k = 0, nsub-1 DO BEGIN

      files = FILE_SEARCH(spfiles[k],'*.dat',/TEST_REGULAR)
      scenes = !NULL
      ;��ÿ��Raster ����һ��scenes��
      FOR i=0, N_ELEMENTS(files)-1 DO BEGIN
        raster = e.OPENRASTER(files[i])
        scenes = [scenes,raster]
      ENDFOR
      ;����ENVIMosaicRaster����
      mosaicRaster = ENVIMOSAICRASTER(scenes, $
        background = 0, $
        color_matching_method = 'histogram matching', $
        color_matching_stats = 'overlapping area', $
        feathering_distance = 20, $
        feathering_method = 'seamline', $
        resampling = 'Nearest Neighbor', $
        seamline_method = 'geometry')

      ;�������·��
      newfile = ''
      newfile = outdir + year + PATH_SEP() + $
        STREGEX(files[0],'[0-9]{4}.dat$',/EXTRACT);_(evi|lswi|ndvi)
      ;����һ���������ԣ����������
      ;       newfile = outdir + year + PATH_SEP() $
      ;        + files[0].EXTRACT('[0-9]{4}_(evi|lswi|ndvi).img$')
      IF FILE_TEST(newfile) THEN FILE_DELETE, newfile

      ;�����Ƕ���
      mosaicRaster.EXPORT, newfile, 'ENVI'


      ;����ӱ���
      mosaicRaster.SAVESEAMPOLYGONS, $
        newfile.EXTRACT('.*[0-9]{4}')+'_seamline.shp';_(evi|lswi|ndvi)
      ;      vector = e.OPENVECTOR(newfile+'_seamline.shp')
      ;
      ;      ;�򿪲���ʾդ��ͽӱ���
      ;      mosaicRaster = e.OPENRASTER(newfile)
      ;      view = e.GETVIEW()
      ;      layer = view.CREATELAYER(mosaicRaster)
      ;      vlayer = view.CREATELAYER(vector)
    ENDFOR
  ENDFOR
  proctime = STRING(ROUND((SYSTIME(1) - starttime)/60.0))
  e.CLOSE
  OK = DIALOG_MESSAGE('�����,��ʱ'+proctime.COMPRESS()+'����!',/INFORMATION)
END