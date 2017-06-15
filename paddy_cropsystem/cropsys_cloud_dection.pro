PRO CROPSYS_CLOUD_DECTION
  ; 获取modis 云检测状态
  ; author:jim
  COMPILE_OPT IDL2
  ;********获取文件modis 存储路径，定义结果云状态变量s
  file = DIALOG_PICKFILE(/DIRECTORY,TITLE='选择输入文件路径',path='e:\')
  IF file EQ "" THEN RETURN
  OUTDIRPICK: outdir = DIALOG_PICKFILE(/DIRECTORY,TITLE='选择输出路径')
  IF outdir EQ "" THEN BEGIN
    ok=DIALOG_MESSAGE('未选择输出路径，要退出吗?',/QUESTION)
    IF ok EQ 'Yes' THEN BEGIN
      RETURN
    ENDIF ELSE GOTO , outdirpick
  ENDIF

  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT

  fpath = FILE_SEARCH(file,'*.hdf',count=n)
  cloud = MAKE_ARRAY(2400,2400,46,/integer)
  ;进度条
  wtlb = WIDGET_BASE(xsize=200,ysize=200, $
    TITLE='检测进度')
  WIDGET_CONTROL, wtlb,/REALIZE
  process = IDLITWDPROGRESSBAR($
    group_leader=wtlb, $
    TIME=0,cancel=cancelin, $
    TITLE = '保存中... 请稍等')
  IDLITWDPROGRESSBAR_SETVALUE, process, 0
  ; 主程序
  FOR k = 0 ,45 DO BEGIN

    ;打开文件，获取ref_sur_500m QA文件数据
    ENVI_OPEN_DATA_FILE,fpath[k],/hdf_sd,HDFSD_DATASET = 11,r_fid=fid
    ENVI_FILE_QUERY,fid,dims=dims,nb=nb
    QA =ENVI_GET_DATA(fid=fid,dims=dims,pos=0)
    ENVI_OPEN_DATA_FILE,fpath[k],/hdf_sd,HDFSD_DATASET = 2,r_fid=fid
    ENVI_FILE_QUERY,fid,dims=dims,nb=nb
    BAND_3 =ENVI_GET_DATA(fid=fid,dims=dims,pos=0)

    ;开始检测 云（10）云阴影
    FOR j = 0, 2399 DO BEGIN
      FOR i = 0 ,2399 DO BEGIN
        R0=QA[i,j] MOD 2 ;求余数，QA最后一位
        c1=FLOOR(QA[i,j]/2) ;
        R1= c1 MOD 2; 倒数第二位
        c2 = FLOOR(c1/2)
        R2 = c2 MOD 2 ; 倒数第三位， 云阴影
        cloud[i,j,k] = ((R0 EQ 1)AND(R1 EQ 0)) $
          OR (R2 EQ 1) OR (band_3[i,j] GE 2000) ;检测云及云阴影
      ENDFOR
    ENDFOR
    IDLITWDPROGRESSBAR_SETVALUE,process,(i+1)*100.0/n
  ENDFOR
  map_info=ENVI_GET_MAP_INFO(fid=fid) ; 获取头文件信息
  ;PRINT,'输出'
  year = fpath[0].EXTRACT('[0-9]{4}')
  ENVI_WRITE_ENVI_FILE,cloud,out_name=outdir + year $
    + '_cloud_blue.img',$
    r_fid=w_fid,map_info=map_info
  ;   ENVI_FILE_QUERY,w_fid,dims=dims,nb=nb
  ;   ENVI_OUTPUT_TO_EXTERNAL_FORMAT,dims=dims,out_name='E:\paddy_extr\cloud\cloud1.tif',$
  ;     pos=INDGEN(nb),/tiff,fid=w_fid
  ENVI_BATCH_EXIT
  finish = DIALOG_MESSAGE('处理结束!',/INFORMATION)
END
