
;事件响应程序
PRO PADDY_CROPSYSTEM_EVENT, ev
  COMPILE_OPT idl2
  ;e = ENVI(/headless)
  WIDGET_CONTROL, ev.TOP, get_uvalue = pstate
  PRINT,*pstate
  ; 如果点了 × 则询问是否关闭，是这关闭 不是则继续
  IF TAG_NAMES(ev, /Structure_Name) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
    status = DIALOG_MESSAGE('是否退出?',/QUESTION)
    PRINT, status
    IF status EQ 'No' THEN RETURN; return指的是终止这个子程序，进行下次选择
    WIDGET_CONTROL, ev.TOP, /DESTROY; 销毁指针
    RETURN;
  ENDIF

  uname = WIDGET_INFO(ev.ID,/uname)
  PRINT,uname

  ;判断组件
  CASE uname OF
    ;*********************************************
    ;文件
    ;打开研究区范围，同时显示改矢量
    'openras': BEGIN
      file = DIALOG_PICKFILE( title = !SYS_TITLE+' 选择数据源',$
        path = (*pstate).INPATH, /MULTIPLE_FILES)

      IF file[0] NE '' THEN BEGIN
        (*pstate).INPATH = FILE_DIRNAME(file[0])
        ;(*pstate).INPUTFILES = PTR_NEW(file[0])
      ENDIF
      PRINT, (*pstate).INPATH
    END
    'openvec': BEGIN
      file = DIALOG_PICKFILE( title = !SYS_TITLE+' 选择研究区范围',$
        path = (*pstate).INPATH)
      (*pstate).INPATH = FILE_DIRNAME(file)
      ;在文本框里显示文件路径 (*pstate).ttxt 想在哪儿显示就填哪儿的ID
      WIDGET_CONTROL, (*pstate).TTXT, set_value = file
      ;显示添加的矢量文件
      ;data = READ_IMAGE(file)
      ;WSET,(*pstate).WINID
      ;ERASE, 'ffffff'x
      ;TV,data,/TRUE
      ;打开研究区范围，同时显示改矢量
    END
    'stuarea': BEGIN
      PRINT,'开始'+(*pstate).INPATH
      file = DIALOG_PICKFILE( title = !SYS_TITLE+' 选择研究区范围',$
        path = (*pstate).INPATH)
      (*pstate).INPATH = FILE_DIRNAME(file)
      PRINT,(*pstate).INPATH
      ;在文本框里显示文件路径 (*pstate).ttxt 想在哪儿显示就填哪儿的ID
      WIDGET_CONTROL, (*pstate).TTXT, set_value = file
      ;显示添加的矢量文件
      ;data = READ_IMAGE(file)
      ;WSET,(*pstate).WINID
      ;ERASE, 'ffffff'x
      ;TV,data,/TRUE
    END

    'exit': BEGIN
      WIDGET_CONTROL, ev.TOP,/destroy
      RETURN
    END
    ;*********************************************
    ;数据预处理
    ;指数计算
    'bindice':BEGIN
      BATCH_VI_CAL_MODIS
      ;      ;file = DIALOG_PICKFILE( title = !SYS_TITLE+' 选择研究区范围',$
      ;        path = (*pstate).INPATH)
      ;      (*pstate).INPATH = FILE_DIRNAME(file)
      ;      ;在文本框里显示文件路径 (*pstate).ttxt 想在哪儿显示就填哪儿的ID
      ;      WIDGET_CONTROL, (*pstate).TTXT, set_value = file
      ;      ;显示添加的矢量文件
      ;      ;data = READ_IMAGE(file)
      ;      ;WSET,(*pstate).WINID
      ;      ;ERASE, 'ffffff'x
      ;      ;TV,data,/TRUE
    END
    ;融合
    'pmosaic':BEGIN
      MODIS_MOSAIC
    END
    ;裁剪
    'psubset':BEGIN
      e = ENVI()
      ui = e.UI
      task = ENVITASK('RasterSubsetViaShapefileClassicDu')
      UI = e.UI
      R = UI.SELECTTASKPARAMETERS(task)
      IF R NE 'Ok' THEN BEGIN
        e.CLOSE
        RETURN
      ENDIF
      task.EXECUTE
    END
    ;云检测
    'cloud': BEGIN
      CROPSYS_CLOUD_DECTION
    END
    ;平滑去噪
    'smooth': BEGIN
      CROPSYS_SMOOTH
    END
    ;*************************
    ;种植制度提取
    'multi':BEGIN
      CROPSYS_PEAK_CAL
    END
    ;生育期检测
    'phon':BEGIN
      PRINT,'UNFINISHED'
    END
    ;*************************
    ;水稻信息提取
    ;水稻像元识别
    'area': BEGIN
    
    END
    ;单、双季稻识别
    'dousin': BEGIN
    print,'dousin_unfinished'
    END
    ;*************************
    ;精度验证
    'asz': BEGIN
      CROPSYS_FILTER_ACCURACY
    END
    'apaddy': BEGIN
      PRINT,'unfinshed'
      Validation
    END
    ;*************************
    ;关于
    'about': BEGIN
      void = DIALOG_MESSAGE(!SYS_TITLE+' V1.0'+STRING(13b)+ $
        '欢迎使用，有问题联系jiangm.15b@igsnrr.ac.cn！' ,/information)
    END
    ELSE:
  ENDCASE
END



PRO PADDY_CROPSYSTEM
  COMPILE_OPT idl2
  ;初始化组件
  sz = [60,40]
  ;设置系统变量，可方便修改系统标题
  DEFSYSV,'!SYS_Title','水稻种植制度提取系统'
  ;创建界面的代码
  ;
  tlb = WIDGET_BASE(MBAR=mbar,/column, $
    TITLE=!SYS_TITLE,  $
    /Tlb_Kill_Request_Events, $
    tlb_frame_attr = 1, map=0)
  ;WIDGET_CONTROL,tlb,/realize
  ;创建菜单
  ;文件菜单
  fMenu = WIDGET_BUTTON(mbar, value="文件", /Menu)
  fopen = WIDGET_BUTTON(fmenu, value = '选择影像', $
    uname="openras")
  fopen = WIDGET_BUTTON(fmenu, value = '打开矢量', $
    uname="openvec")
  fexit = WIDGET_BUTTON(fmenu, value ="退出", $
    uname= "exit",/Sep)
  ;数据预处理
  pMenu = WIDGET_BUTTON(mbar,value = "数据预处理",/menu)
  ;镶嵌
  mmosaic = WIDGET_BUTTON(pmenu, value = '图像镶嵌',uname= 'pmosaic')
  ;  psmosaic = WIDGET_BUTTON(mmosaic, value = '镶嵌图像', $
  ;    uname= 'smosaic')
  ;  pbmosaic = WIDGET_BUTTON(mmosaic, value = '批量镶嵌', $
  ;    uname= 'bmosaic')
  ;裁剪
  psubset = WIDGET_BUTTON(pmenu, value = '图像裁剪',uname='psubset')
  ;去噪
  denoise = WIDGET_BUTTON(pmenu, value ='图像去噪',/menu)
  psdenoise = WIDGET_BUTTON(denoise, value='云检测',$
    uname='cloud')
  pbdenoise = WIDGET_BUTTON(denoise, value='波谱平滑', $
    uname='smooth')
  ;指数计算
  pindice = WIDGET_BUTTON(pmenu, value ='指数计算',uname='bindice')
  ;  pevi = WIDGET_BUTTON(pindice, value='EVI',$
  ;    uname='evi')
  ;  plswi = WIDGET_BUTTON(pindice, value='LSWI', $
  ;    uname='lswi')
  ;  pbindice = WIDGET_BUTTON(pindice, value='批量计算', $
  ;    uname='bindice')
  ;种植制度信息提取
  sMenu = WIDGET_BUTTON(mbar,value = "种植制度提取",/menu)
  smulti = WIDGET_BUTTON(smenu, value="熟制检测",uname='multi')
  sphon = WIDGET_BUTTON(smenu, value="生育期检测",uname='phon')
  ;水稻信息提取
  cMenu = WIDGET_BUTTON(mbar,value = "水稻信息提取",/menu)
  carea = WIDGET_BUTTON(cmenu, value="水稻像元识别",uname='area')
  cdousin = WIDGET_BUTTON(cmenu, value='单双季稻提取',uname='dousin')
  ;精度验证
  aMenu = WIDGET_BUTTON(mbar,value = "精度验证",/menu)
  asz = WIDGET_BUTTON(amenu, value="熟制验证",uname='asz')
  apaddy = WIDGET_BUTTON(amenu, value='水稻验证',uname='apaddy')
  ;帮助
  hMenu =  WIDGET_BUTTON(mBar, value ='帮助',/Menu)
  hHelp = WIDGET_BUTTON(hmenu, value = '关于', $
    uName = 'about')

  ;打开裁剪的矢量文件
  toolbar = WIDGET_BASE(tlb,/frame,/row)
  topen = WIDGET_BUTTON(toolbar, $
    value = "研究区范围",uname="stuarea")
  ttxt = WIDGET_TEXT(toolbar,value='',$
    xsize=84,/frame,/Editable)

  ;绘制区-绘制研究区范围
  wdraw = WIDGET_DRAW(tlb,/frame,xsize=600,ysize=400); /MOTION_EVENTS

  ;在框里显示图片
  ;Wdraw = WIDGET_BASE(tlb,/frame,/row)
  ;hyy = WIDGET_BUTTON(wdraw,value='E:\paddy_extr\system\icon.bmp', $
  ;  /bitmap, xsize=600,ysize=400,/frame)
  ;进度条s
  ;  pbr = WIDGET_BASE(tlb,/frame,/row,xsize=84,ysize=20)
  ;  prsbar = IDLITWDPROGRESSBAR1( pbr ,$
  ;    title ='进度', $
  ;    CANCEL =0)
  WIDGET_CONTROL, tlb,/Realize ,/map;,set_uValue = pState
  WIDGET_CONTROL, WDRAW,get_value=winID
  WSET, winID
  DEVICE, decomposed=1
  data = READ_IMAGE('E:\paddy_extr\system\icon.bmp')
  TV,data,/true
  ;ERASE, 'ffffff'x ; 背景色设为白色
  pstate = {WINID: WINID, $
    ORIROOT: '',    $
    INPATH : '',    $
    OUTPATH : '',    $
    TTXT: TTXT         $
  };用于参数的传入传出PRSBAR : prsbar,      $

  ;操作界面居中
  CENTERTLB,tlb

  WIDGET_CONTROL, tlb,SET_UVALUE = PTR_NEW(pstate)
  XMANAGER, 'PADDY_CROPSYSTEM', tlb, /NO_BLOCK

END