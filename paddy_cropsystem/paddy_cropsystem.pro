
;�¼���Ӧ����
PRO PADDY_CROPSYSTEM_EVENT, ev
  COMPILE_OPT idl2
  ;e = ENVI(/headless)
  WIDGET_CONTROL, ev.TOP, get_uvalue = pstate
  PRINT,*pstate
  ; ������� �� ��ѯ���Ƿ�رգ�����ر� ���������
  IF TAG_NAMES(ev, /Structure_Name) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
    status = DIALOG_MESSAGE('�Ƿ��˳�?',/QUESTION)
    PRINT, status
    IF status EQ 'No' THEN RETURN; returnָ������ֹ����ӳ��򣬽����´�ѡ��
    WIDGET_CONTROL, ev.TOP, /DESTROY; ����ָ��
    RETURN;
  ENDIF

  uname = WIDGET_INFO(ev.ID,/uname)
  PRINT,uname

  ;�ж����
  CASE uname OF
    ;*********************************************
    ;�ļ�
    ;���о�����Χ��ͬʱ��ʾ��ʸ��
    'openras': BEGIN
      file = DIALOG_PICKFILE( title = !SYS_TITLE+' ѡ������Դ',$
        path = (*pstate).INPATH, /MULTIPLE_FILES)

      IF file[0] NE '' THEN BEGIN
        (*pstate).INPATH = FILE_DIRNAME(file[0])
        ;(*pstate).INPUTFILES = PTR_NEW(file[0])
      ENDIF
      PRINT, (*pstate).INPATH
    END
    'openvec': BEGIN
      file = DIALOG_PICKFILE( title = !SYS_TITLE+' ѡ���о�����Χ',$
        path = (*pstate).INPATH)
      (*pstate).INPATH = FILE_DIRNAME(file)
      ;���ı�������ʾ�ļ�·�� (*pstate).ttxt �����Ķ���ʾ�����Ķ���ID
      WIDGET_CONTROL, (*pstate).TTXT, set_value = file
      ;��ʾ��ӵ�ʸ���ļ�
      ;data = READ_IMAGE(file)
      ;WSET,(*pstate).WINID
      ;ERASE, 'ffffff'x
      ;TV,data,/TRUE
      ;���о�����Χ��ͬʱ��ʾ��ʸ��
    END
    'stuarea': BEGIN
      PRINT,'��ʼ'+(*pstate).INPATH
      file = DIALOG_PICKFILE( title = !SYS_TITLE+' ѡ���о�����Χ',$
        path = (*pstate).INPATH)
      (*pstate).INPATH = FILE_DIRNAME(file)
      PRINT,(*pstate).INPATH
      ;���ı�������ʾ�ļ�·�� (*pstate).ttxt �����Ķ���ʾ�����Ķ���ID
      WIDGET_CONTROL, (*pstate).TTXT, set_value = file
      ;��ʾ��ӵ�ʸ���ļ�
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
    ;����Ԥ����
    ;ָ������
    'bindice':BEGIN
      BATCH_VI_CAL_MODIS
      ;      ;file = DIALOG_PICKFILE( title = !SYS_TITLE+' ѡ���о�����Χ',$
      ;        path = (*pstate).INPATH)
      ;      (*pstate).INPATH = FILE_DIRNAME(file)
      ;      ;���ı�������ʾ�ļ�·�� (*pstate).ttxt �����Ķ���ʾ�����Ķ���ID
      ;      WIDGET_CONTROL, (*pstate).TTXT, set_value = file
      ;      ;��ʾ��ӵ�ʸ���ļ�
      ;      ;data = READ_IMAGE(file)
      ;      ;WSET,(*pstate).WINID
      ;      ;ERASE, 'ffffff'x
      ;      ;TV,data,/TRUE
    END
    ;�ں�
    'pmosaic':BEGIN
      MODIS_MOSAIC
    END
    ;�ü�
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
    ;�Ƽ��
    'cloud': BEGIN
      CROPSYS_CLOUD_DECTION
    END
    ;ƽ��ȥ��
    'smooth': BEGIN
      CROPSYS_SMOOTH
    END
    ;*************************
    ;��ֲ�ƶ���ȡ
    'multi':BEGIN
      CROPSYS_PEAK_CAL
    END
    ;�����ڼ��
    'phon':BEGIN
      PRINT,'UNFINISHED'
    END
    ;*************************
    ;ˮ����Ϣ��ȡ
    ;ˮ����Ԫʶ��
    'area': BEGIN
    
    END
    ;����˫����ʶ��
    'dousin': BEGIN
    print,'dousin_unfinished'
    END
    ;*************************
    ;������֤
    'asz': BEGIN
      CROPSYS_FILTER_ACCURACY
    END
    'apaddy': BEGIN
      PRINT,'unfinshed'
      Validation
    END
    ;*************************
    ;����
    'about': BEGIN
      void = DIALOG_MESSAGE(!SYS_TITLE+' V1.0'+STRING(13b)+ $
        '��ӭʹ�ã���������ϵjiangm.15b@igsnrr.ac.cn��' ,/information)
    END
    ELSE:
  ENDCASE
END



PRO PADDY_CROPSYSTEM
  COMPILE_OPT idl2
  ;��ʼ�����
  sz = [60,40]
  ;����ϵͳ�������ɷ����޸�ϵͳ����
  DEFSYSV,'!SYS_Title','ˮ����ֲ�ƶ���ȡϵͳ'
  ;��������Ĵ���
  ;
  tlb = WIDGET_BASE(MBAR=mbar,/column, $
    TITLE=!SYS_TITLE,  $
    /Tlb_Kill_Request_Events, $
    tlb_frame_attr = 1, map=0)
  ;WIDGET_CONTROL,tlb,/realize
  ;�����˵�
  ;�ļ��˵�
  fMenu = WIDGET_BUTTON(mbar, value="�ļ�", /Menu)
  fopen = WIDGET_BUTTON(fmenu, value = 'ѡ��Ӱ��', $
    uname="openras")
  fopen = WIDGET_BUTTON(fmenu, value = '��ʸ��', $
    uname="openvec")
  fexit = WIDGET_BUTTON(fmenu, value ="�˳�", $
    uname= "exit",/Sep)
  ;����Ԥ����
  pMenu = WIDGET_BUTTON(mbar,value = "����Ԥ����",/menu)
  ;��Ƕ
  mmosaic = WIDGET_BUTTON(pmenu, value = 'ͼ����Ƕ',uname= 'pmosaic')
  ;  psmosaic = WIDGET_BUTTON(mmosaic, value = '��Ƕͼ��', $
  ;    uname= 'smosaic')
  ;  pbmosaic = WIDGET_BUTTON(mmosaic, value = '������Ƕ', $
  ;    uname= 'bmosaic')
  ;�ü�
  psubset = WIDGET_BUTTON(pmenu, value = 'ͼ��ü�',uname='psubset')
  ;ȥ��
  denoise = WIDGET_BUTTON(pmenu, value ='ͼ��ȥ��',/menu)
  psdenoise = WIDGET_BUTTON(denoise, value='�Ƽ��',$
    uname='cloud')
  pbdenoise = WIDGET_BUTTON(denoise, value='����ƽ��', $
    uname='smooth')
  ;ָ������
  pindice = WIDGET_BUTTON(pmenu, value ='ָ������',uname='bindice')
  ;  pevi = WIDGET_BUTTON(pindice, value='EVI',$
  ;    uname='evi')
  ;  plswi = WIDGET_BUTTON(pindice, value='LSWI', $
  ;    uname='lswi')
  ;  pbindice = WIDGET_BUTTON(pindice, value='��������', $
  ;    uname='bindice')
  ;��ֲ�ƶ���Ϣ��ȡ
  sMenu = WIDGET_BUTTON(mbar,value = "��ֲ�ƶ���ȡ",/menu)
  smulti = WIDGET_BUTTON(smenu, value="���Ƽ��",uname='multi')
  sphon = WIDGET_BUTTON(smenu, value="�����ڼ��",uname='phon')
  ;ˮ����Ϣ��ȡ
  cMenu = WIDGET_BUTTON(mbar,value = "ˮ����Ϣ��ȡ",/menu)
  carea = WIDGET_BUTTON(cmenu, value="ˮ����Ԫʶ��",uname='area')
  cdousin = WIDGET_BUTTON(cmenu, value='��˫������ȡ',uname='dousin')
  ;������֤
  aMenu = WIDGET_BUTTON(mbar,value = "������֤",/menu)
  asz = WIDGET_BUTTON(amenu, value="������֤",uname='asz')
  apaddy = WIDGET_BUTTON(amenu, value='ˮ����֤',uname='apaddy')
  ;����
  hMenu =  WIDGET_BUTTON(mBar, value ='����',/Menu)
  hHelp = WIDGET_BUTTON(hmenu, value = '����', $
    uName = 'about')

  ;�򿪲ü���ʸ���ļ�
  toolbar = WIDGET_BASE(tlb,/frame,/row)
  topen = WIDGET_BUTTON(toolbar, $
    value = "�о�����Χ",uname="stuarea")
  ttxt = WIDGET_TEXT(toolbar,value='',$
    xsize=84,/frame,/Editable)

  ;������-�����о�����Χ
  wdraw = WIDGET_DRAW(tlb,/frame,xsize=600,ysize=400); /MOTION_EVENTS

  ;�ڿ�����ʾͼƬ
  ;Wdraw = WIDGET_BASE(tlb,/frame,/row)
  ;hyy = WIDGET_BUTTON(wdraw,value='E:\paddy_extr\system\icon.bmp', $
  ;  /bitmap, xsize=600,ysize=400,/frame)
  ;������s
  ;  pbr = WIDGET_BASE(tlb,/frame,/row,xsize=84,ysize=20)
  ;  prsbar = IDLITWDPROGRESSBAR1( pbr ,$
  ;    title ='����', $
  ;    CANCEL =0)
  WIDGET_CONTROL, tlb,/Realize ,/map;,set_uValue = pState
  WIDGET_CONTROL, WDRAW,get_value=winID
  WSET, winID
  DEVICE, decomposed=1
  data = READ_IMAGE('E:\paddy_extr\system\icon.bmp')
  TV,data,/true
  ;ERASE, 'ffffff'x ; ����ɫ��Ϊ��ɫ
  pstate = {WINID: WINID, $
    ORIROOT: '',    $
    INPATH : '',    $
    OUTPATH : '',    $
    TTXT: TTXT         $
  };���ڲ����Ĵ��봫��PRSBAR : prsbar,      $

  ;�����������
  CENTERTLB,tlb

  WIDGET_CONTROL, tlb,SET_UVALUE = PTR_NEW(pstate)
  XMANAGER, 'PADDY_CROPSYSTEM', tlb, /NO_BLOCK

END