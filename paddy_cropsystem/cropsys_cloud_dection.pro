PRO CROPSYS_CLOUD_DECTION
  ; ��ȡmodis �Ƽ��״̬
  ; author:jim
  COMPILE_OPT IDL2
  ;********��ȡ�ļ�modis �洢·������������״̬����s
  file = DIALOG_PICKFILE(/DIRECTORY,TITLE='ѡ�������ļ�·��',path='e:\')
  IF file EQ "" THEN RETURN
  OUTDIRPICK: outdir = DIALOG_PICKFILE(/DIRECTORY,TITLE='ѡ�����·��')
  IF outdir EQ "" THEN BEGIN
    ok=DIALOG_MESSAGE('δѡ�����·����Ҫ�˳���?',/QUESTION)
    IF ok EQ 'Yes' THEN BEGIN
      RETURN
    ENDIF ELSE GOTO , outdirpick
  ENDIF

  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT

  fpath = FILE_SEARCH(file,'*.hdf',count=n)
  cloud = MAKE_ARRAY(2400,2400,46,/integer)
  ;������
  wtlb = WIDGET_BASE(xsize=200,ysize=200, $
    TITLE='������')
  WIDGET_CONTROL, wtlb,/REALIZE
  process = IDLITWDPROGRESSBAR($
    group_leader=wtlb, $
    TIME=0,cancel=cancelin, $
    TITLE = '������... ���Ե�')
  IDLITWDPROGRESSBAR_SETVALUE, process, 0
  ; ������
  FOR k = 0 ,45 DO BEGIN

    ;���ļ�����ȡref_sur_500m QA�ļ�����
    ENVI_OPEN_DATA_FILE,fpath[k],/hdf_sd,HDFSD_DATASET = 11,r_fid=fid
    ENVI_FILE_QUERY,fid,dims=dims,nb=nb
    QA =ENVI_GET_DATA(fid=fid,dims=dims,pos=0)
    ENVI_OPEN_DATA_FILE,fpath[k],/hdf_sd,HDFSD_DATASET = 2,r_fid=fid
    ENVI_FILE_QUERY,fid,dims=dims,nb=nb
    BAND_3 =ENVI_GET_DATA(fid=fid,dims=dims,pos=0)

    ;��ʼ��� �ƣ�10������Ӱ
    FOR j = 0, 2399 DO BEGIN
      FOR i = 0 ,2399 DO BEGIN
        R0=QA[i,j] MOD 2 ;��������QA���һλ
        c1=FLOOR(QA[i,j]/2) ;
        R1= c1 MOD 2; �����ڶ�λ
        c2 = FLOOR(c1/2)
        R2 = c2 MOD 2 ; ��������λ�� ����Ӱ
        cloud[i,j,k] = ((R0 EQ 1)AND(R1 EQ 0)) $
          OR (R2 EQ 1) OR (band_3[i,j] GE 2000) ;����Ƽ�����Ӱ
      ENDFOR
    ENDFOR
    IDLITWDPROGRESSBAR_SETVALUE,process,(i+1)*100.0/n
  ENDFOR
  map_info=ENVI_GET_MAP_INFO(fid=fid) ; ��ȡͷ�ļ���Ϣ
  ;PRINT,'���'
  year = fpath[0].EXTRACT('[0-9]{4}')
  ENVI_WRITE_ENVI_FILE,cloud,out_name=outdir + year $
    + '_cloud_blue.img',$
    r_fid=w_fid,map_info=map_info
  ;   ENVI_FILE_QUERY,w_fid,dims=dims,nb=nb
  ;   ENVI_OUTPUT_TO_EXTERNAL_FORMAT,dims=dims,out_name='E:\paddy_extr\cloud\cloud1.tif',$
  ;     pos=INDGEN(nb),/tiff,fid=w_fid
  ENVI_BATCH_EXIT
  finish = DIALOG_MESSAGE('�������!',/INFORMATION)
END
