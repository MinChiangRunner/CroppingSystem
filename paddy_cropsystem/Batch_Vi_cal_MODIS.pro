;+
;:DESCRIPTION:
;   ENVI二次开发的批处理模版
;   默认为数据格式转换为tiff格式
;
; Author: DYQ
;-
;析构函数
PRO BATCH_VI_CAL_MODIS_CLEANUP,tlb
  WIDGET_CONTROL,tlb,get_UValue = pState
  PTR_FREE,pState
END
;事件响应函数
PRO BATCH_VI_CAL_MODIS_EVENT,event
  COMPILE_OPT idl2
  WIDGET_CONTROL,event.TOP, get_UValue = pState

  ;关闭事件
  IF TAG_NAMES(event, /Structure_Name) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
    ;
    status = DIALOG_MESSAGE('关闭?',/Question)
    IF status EQ 'No' THEN RETURN
    ;销毁指针
    ; PTR_FREE, pState
    WIDGET_CONTROL, event.TOP,/Destroy
    RETURN;
  ENDIF
  ;根据系统的uname进行判断点击的组件
  uName = WIDGET_INFO(event.ID,/uName)
  ;
  CASE uname OF
    ;打开文件
    'open': BEGIN
      files = DIALOG_PICKFILE(/directory, $
        title = !SYS_TITLE+' 选择数据源', $
        path = (*pState).ORIROOT)
      IF N_ELEMENTS(files) EQ 0 THEN RETURN
      ;设置显示文件
      WIDGET_CONTROL, (*pState).WLIST, set_value = files
      (*pState).INPUTFILES = PTR_NEW(files)
      (*pState).ORIROOT = FILE_DIRNAME(files[0])
      ;重置进度条进度
      IDLITWDPROGRESSBAR1_SETVALUE,(*pState).PRSBAR,0

    END
    ;退出
    'exit': BEGIN
      status = DIALOG_MESSAGE('关闭?',$
        title = !SYS_TITLE, $
        /Question)
      IF status EQ 'No' THEN RETURN
      WIDGET_CONTROL, event.TOP,/Destroy
    END
    ;关于
    'about': BEGIN
      void = DIALOG_MESSAGE(!SYS_TITLE+' V1.0'+STRING(13b)+ $
        '欢迎使用，有问题联系jiangm.15b@igsnrr.ac.cn！' ,/information)
    END
    ;
    ;路径选择按钮
    'filepathsele': BEGIN
      WIDGET_CONTROL, event.ID,get_value = value
      WIDGET_CONTROL,(*pState).WSELE, Sensitive= value
      WIDGET_CONTROL,(*pState).OUTPATH, Sensitive= value
    END
    ;选择输出路径
    'selePath' : BEGIN
      outroot = DIALOG_PICKFILE(/dire,title = !SYS_TITLE)
      WIDGET_CONTROL,(*pState).OUTPATH,set_value = outRoot
    END

    ;功能执行
    'execute': BEGIN
      ;获取选择的方法
      WIDGET_CONTROL,(*pState).BGROUP, get_Value = mValue
      IF PTR_VALID((*pState).INPUTFILES) EQ 0 THEN RETURN
      ;初始化ENVI
      ENVI, /restore_base_save_files
      ENVI_BATCH_INIT,/NO_Status_Window

      ;获取文件名
      files = *((*pState).INPUTFILES)
      ;获取影像的个数，计算进度条时间
      pfiles = FILE_SEARCH(files,'*.hdf',count=num,/test_regular)
      ;判断输入文件夹是否为空
      IF num EQ 0 THEN BEGIN
        tmp = DIALOG_MESSAGE('文件夹为空', $
          title=!SYS_TITLE,/error)
        RETURN
      ENDIF
      ;判断是否需要选择输出路径
      IF mValue NE 0 THEN BEGIN
        ;构建输出文件名
        WIDGET_CONTROL, (*pState).OUTPATH,get_value= outfiledir
        IF (outfiledir[0] EQ ' ') THEN  outfiledir = $
          DIALOG_PICKFILE(/dire, title =!SYS_TITLE+' 输出路径')
      ENDIF  ELSE outfiledir = FILE_DIRNAME(files[0])
     
      per = 100./num ;每个影响的进度条时间
      ;获取各景影像所在子文件夹
      pfiles = FILE_SEARCH(files,'*',count=num,/test_directory)


      FOR i=0,num-1 DO BEGIN
        ;输入文件地址：先找到大文件夹内各个子文件Pfile, 然后进入各个子文件夹遍历
        files =FILE_SEARCH(pfiles[i] $
          +'\*.hdf',count=n)
        IF n EQ 0 THEN BEGIN
          tmp=DIALOG_MESSAGE(pfiles[i]+'文件夹为空', $
            title=!SYS_TITLE,/error)
          CONTINUE
        ENDIF
        crname = STRMID(files[0],27,6,/reverse_offset);获取行列号作为文件名称
        year =  STRMID(files[0],35,4,/reverse_offset)
        ofname = outfiledir + PATH_SEP()+ year + PATH_SEP() ;构建子文件路径
        ;建立以年份为名字的路径
        IF ~FILE_TEST(ofname) THEN BEGIN
          FILE_MKDIR, ofname
          FILE_MKDIR, ofname + 'ndvi'
          FILE_MKDIR, ofname + 'evi'
          FILE_MKDIR, ofname + 'lswi'
        ENDIF


        ;建立存储数组
        NDVI=MAKE_ARRAY(2400,2400,n,/INTEGER)
        EVI=MAKE_ARRAY(2400,2400,n,/INTEGER)
        LSWI=MAKE_ARRAY(2400,2400,n,/INTEGER)
        ;开始计算
        FOR k=0, n-1 DO BEGIN
          ENVI_OPEN_DATA_FILE,files[k],/modis,r_fid=fid
          IF (fid EQ -1) THEN BEGIN
            tmp=DIALOG_MESSAGE(files[k]+'文件读取错误', $
              title=!SYS_TITLE,/error)
            CONTINUE
          ENDIF
          ENVI_FILE_QUERY,fid,dims=dims
          map_info=ENVI_GET_MAP_INFO(fid=fid)
          band_1=ENVI_GET_DATA(fid=fid,dims=dims,pos=0)
          band_2=ENVI_GET_DATA(fid=fid,dims=dims,pos=1)
          band_3=ENVI_GET_DATA(fid=fid,dims=dims,pos=2)
          band_6=ENVI_GET_DATA(fid=fid,dims=dims,pos=5)

          NDVI[*,*,k] = fix(round((float(round(band_2*10000))- $
            round(band_1*10000))/ (float(round(band_2*10000))+ $
            band_1*10000))*10000)
          evi[*,*,k] = fix(2.5*(round(band_2*10000)- $
            round(band_1*10000))*10000/(round(band_2*10000)+ $
            6*round(band_1*10000)-7.5*round(band_3*10000)+10000))
          lswi[*,*,k] = fix((float(round(band_2*10000))-round(band_6*10000)) $
            *10000/(FLOAT(round(band_2*10000))+round(band_6*10000)))
          ;
          ;          NDVI[*,*,k] = (FLOAT(band_2)-band_1)/ $
          ;            (FLOAT(band_2)+band_1)
          ;          evi[*,*,k] = 2.5*(band_2-band_1)/(band_2+ $
          ;            6*band_1-7.5*band_3+1)
          ;          lswi[*,*,k] =(FLOAT(band_2)-band_6)/(FLOAT(band_2)+band_6)


          ENVI_FILE_MNG,id=fid,/remove; 关闭文件
          jd = (FLOAT(i)*100)/num + (k+1)*per;显示进度条
          IDLITWDPROGRESSBAR1_SETVALUE,(*pState).PRSBAR,jd
        ENDFOR
        ;将 Inf 或者 -Inf 改为 Nan
        ndvi = FINITE(ndvi)*ndvi
        evi = FINITE(evi)*evi
        lswi = FINITE(lswi)*lswi
        ;大于1的设置为1，小于0的设置为0
        evi = (evi LT 0)*0 + (evi GT 10000)*10000 + $
          ((evi GE 0) AND (evi LE 10000))*evi
        ;输出img
       
        bnames=STRING([1:n])

        ;先在年份文件夹内 建立指数名的文件夹然后输出文件
        outfile = ofname +'ndvi'+ $
          PATH_SEP()+ crname + '_'+year+'_ndvi.dat'
        ENVI_WRITE_ENVI_FILE, ndvi, OUT_NAME= outfile, BNAMES = bnames,$
          nb=n,r_fid=xfid,map_info=map_info
        outfile = ofname +'evi'+ $
          PATH_SEP()+ crname + '_'+year+ '_evi.dat'
        ENVI_WRITE_ENVI_FILE, evi, OUT_NAME= outfile, BNAMES = bnames,$
          nb=n,r_fid=xfid,map_info=map_info
        outfile = ofname + 'lswi'+ $
          PATH_SEP()+ crname + '_'+year+'_lswi.dat'
        ENVI_WRITE_ENVI_FILE, LSWI, OUT_NAME= outfile, BNAMES = bnames,$
          nb=n,r_fid=xfid,map_info=map_info
      ENDFOR
      void = DIALOG_MESSAGE('处理完成 ',title = !SYS_TITLE,/infor)
      ;关闭ENVI二次开发模式
      ENVI_BATCH_EXIT
    END
    ELSE:
  ENDCASE
END
;
;--------------------------
;ENVI二次开发批处理模版
PRO BATCH_VI_CAL_MODIS
  ;
  COMPILE_OPT idl2
  ;初始化组件大小
  sz = [600,400]
  ;设置系统变量，可方便修改系统标题
  DEFSYSV,'!SYS_Title','MODIS指数计算批处理'
  ;创建界面的代码
  tlb = WIDGET_BASE(MBAR= mBar, $
    /COLUMN , $
    title = !SYS_TITLE, $
    /Tlb_Kill_Request_Events, $
    tlb_frame_attr = 1, $
    Map = 0)
  ;创建菜单
  fMenu = WIDGET_BUTTON(mBar, value ='文件',/Menu)
  wButton = WIDGET_BUTTON(fMenu,value ='打开数据输入路径', $
    uName = 'open')
  fExit = WIDGET_BUTTON(fMenu, value = '退出', $
    uName = 'exit',/Sep)
  eMenu = WIDGET_BUTTON(mBar,value ='功能',/Menu)
  wButton = WIDGET_BUTTON(eMenu,$
    value ='运行批处理', $
    uName = 'execute')
  hMenu =  WIDGET_BUTTON(mBar, value ='帮助',/Menu)
  hHelp = WIDGET_BUTTON(hmenu, value = '关于', $
    uName = 'about',/Sep)
  ;上面的输入base
  wInputBase = WIDGET_BASE(tlb, $
    xSize =sz[0], $
    /Frame, $
    /Align_Center,$
    /Column)


  wLabel= WIDGET_LABEL(wInputBase, $
    value ='文件夹名称')
  wList = WIDGET_LIST(wInputBase, $
    YSize = sz[1]/(2*15),$
    XSize = sz[0]/8)

  ;输出路径设置
  wLabel= WIDGET_LABEL(tlb, $
    value ='输出参数设置')

  ;输出参数控制界面
  wSetBase = WIDGET_BASE(tlb, $
    xSize =sz[0], $
    /Row)
  values = ['源文件路径', $
    '另选择路径']
  bgroup = CW_BGROUP(wSetBase, values, $
    /ROW, /EXCLUSIVE, $
    /No_Release, $
    SET_VALUE=1, $
    uName = 'filepathsele', $
    /FRAME)
  outPath = WIDGET_TEXT(wSetBase, $
    value =' ', $
    xSize =30, $
    /Editable, $
    uName = 'outroot')
  wSele = WIDGET_BUTTON(wSetBase, $
    value ='选择路径', $
    uName ='selePath')
  ;
  ;执行按钮base
  wExecuteBase = WIDGET_BASE(tlb,$
    /align_center,$
    /row)
  wButton = WIDGET_BUTTON(wExecuteBase, $
    ysize =40,$
    value ='打开数据输入路径', $
    uName = 'open')
  wButton = WIDGET_BUTTON(wExecuteBase,$
    value ='运行批处理', $
    uName = 'execute')
  ;状态栏，仅显示进度条
  wStatus = WIDGET_BASE(tlb,/align_right)
  prsbar = IDLITWDPROGRESSBAR1( wExecuteBase ,$
    title ='进度', $
    CANCEL =0)
  ;结构体传递参数
  state = {WBUTTON:wButton, $
    TLB : tlb, $
    ORIROOT: '', $
    OUTPATH: outPath, $
    WSELE : wSele, $
    BGROUP : bgroup , $
    INPUTFILES : PTR_NEW(), $
    PRSBAR : prsbar , $
    WLIST : WLIST }

  pState = PTR_NEW(state,/no_copy)
  ;操作界面居中
  CENTERTLB,tlb
  ;
  WIDGET_CONTROL, tlb,/Realize,/map,set_uValue = pState
  XMANAGER,'Batch_Vi_cal_MODIS',tlb,/No_Block,$
    cleanup ='Batch_Vi_cal_MODIS_Cleanup'
END
