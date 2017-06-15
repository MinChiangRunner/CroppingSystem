;+
;:DESCRIPTION:
;   ENVI���ο�����������ģ��
;   Ĭ��Ϊ���ݸ�ʽת��Ϊtiff��ʽ
;
; Author: DYQ
;-
;��������
PRO BATCH_VI_CAL_MODIS_CLEANUP,tlb
  WIDGET_CONTROL,tlb,get_UValue = pState
  PTR_FREE,pState
END
;�¼���Ӧ����
PRO BATCH_VI_CAL_MODIS_EVENT,event
  COMPILE_OPT idl2
  WIDGET_CONTROL,event.TOP, get_UValue = pState

  ;�ر��¼�
  IF TAG_NAMES(event, /Structure_Name) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
    ;
    status = DIALOG_MESSAGE('�ر�?',/Question)
    IF status EQ 'No' THEN RETURN
    ;����ָ��
    ; PTR_FREE, pState
    WIDGET_CONTROL, event.TOP,/Destroy
    RETURN;
  ENDIF
  ;����ϵͳ��uname�����жϵ�������
  uName = WIDGET_INFO(event.ID,/uName)
  ;
  CASE uname OF
    ;���ļ�
    'open': BEGIN
      files = DIALOG_PICKFILE(/directory, $
        title = !SYS_TITLE+' ѡ������Դ', $
        path = (*pState).ORIROOT)
      IF N_ELEMENTS(files) EQ 0 THEN RETURN
      ;������ʾ�ļ�
      WIDGET_CONTROL, (*pState).WLIST, set_value = files
      (*pState).INPUTFILES = PTR_NEW(files)
      (*pState).ORIROOT = FILE_DIRNAME(files[0])
      ;���ý���������
      IDLITWDPROGRESSBAR1_SETVALUE,(*pState).PRSBAR,0

    END
    ;�˳�
    'exit': BEGIN
      status = DIALOG_MESSAGE('�ر�?',$
        title = !SYS_TITLE, $
        /Question)
      IF status EQ 'No' THEN RETURN
      WIDGET_CONTROL, event.TOP,/Destroy
    END
    ;����
    'about': BEGIN
      void = DIALOG_MESSAGE(!SYS_TITLE+' V1.0'+STRING(13b)+ $
        '��ӭʹ�ã���������ϵjiangm.15b@igsnrr.ac.cn��' ,/information)
    END
    ;
    ;·��ѡ��ť
    'filepathsele': BEGIN
      WIDGET_CONTROL, event.ID,get_value = value
      WIDGET_CONTROL,(*pState).WSELE, Sensitive= value
      WIDGET_CONTROL,(*pState).OUTPATH, Sensitive= value
    END
    ;ѡ�����·��
    'selePath' : BEGIN
      outroot = DIALOG_PICKFILE(/dire,title = !SYS_TITLE)
      WIDGET_CONTROL,(*pState).OUTPATH,set_value = outRoot
    END

    ;����ִ��
    'execute': BEGIN
      ;��ȡѡ��ķ���
      WIDGET_CONTROL,(*pState).BGROUP, get_Value = mValue
      IF PTR_VALID((*pState).INPUTFILES) EQ 0 THEN RETURN
      ;��ʼ��ENVI
      ENVI, /restore_base_save_files
      ENVI_BATCH_INIT,/NO_Status_Window

      ;��ȡ�ļ���
      files = *((*pState).INPUTFILES)
      ;��ȡӰ��ĸ��������������ʱ��
      pfiles = FILE_SEARCH(files,'*.hdf',count=num,/test_regular)
      ;�ж������ļ����Ƿ�Ϊ��
      IF num EQ 0 THEN BEGIN
        tmp = DIALOG_MESSAGE('�ļ���Ϊ��', $
          title=!SYS_TITLE,/error)
        RETURN
      ENDIF
      ;�ж��Ƿ���Ҫѡ�����·��
      IF mValue NE 0 THEN BEGIN
        ;��������ļ���
        WIDGET_CONTROL, (*pState).OUTPATH,get_value= outfiledir
        IF (outfiledir[0] EQ ' ') THEN  outfiledir = $
          DIALOG_PICKFILE(/dire, title =!SYS_TITLE+' ���·��')
      ENDIF  ELSE outfiledir = FILE_DIRNAME(files[0])
     
      per = 100./num ;ÿ��Ӱ��Ľ�����ʱ��
      ;��ȡ����Ӱ���������ļ���
      pfiles = FILE_SEARCH(files,'*',count=num,/test_directory)


      FOR i=0,num-1 DO BEGIN
        ;�����ļ���ַ�����ҵ����ļ����ڸ������ļ�Pfile, Ȼ�����������ļ��б���
        files =FILE_SEARCH(pfiles[i] $
          +'\*.hdf',count=n)
        IF n EQ 0 THEN BEGIN
          tmp=DIALOG_MESSAGE(pfiles[i]+'�ļ���Ϊ��', $
            title=!SYS_TITLE,/error)
          CONTINUE
        ENDIF
        crname = STRMID(files[0],27,6,/reverse_offset);��ȡ���к���Ϊ�ļ�����
        year =  STRMID(files[0],35,4,/reverse_offset)
        ofname = outfiledir + PATH_SEP()+ year + PATH_SEP() ;�������ļ�·��
        ;���������Ϊ���ֵ�·��
        IF ~FILE_TEST(ofname) THEN BEGIN
          FILE_MKDIR, ofname
          FILE_MKDIR, ofname + 'ndvi'
          FILE_MKDIR, ofname + 'evi'
          FILE_MKDIR, ofname + 'lswi'
        ENDIF


        ;�����洢����
        NDVI=MAKE_ARRAY(2400,2400,n,/INTEGER)
        EVI=MAKE_ARRAY(2400,2400,n,/INTEGER)
        LSWI=MAKE_ARRAY(2400,2400,n,/INTEGER)
        ;��ʼ����
        FOR k=0, n-1 DO BEGIN
          ENVI_OPEN_DATA_FILE,files[k],/modis,r_fid=fid
          IF (fid EQ -1) THEN BEGIN
            tmp=DIALOG_MESSAGE(files[k]+'�ļ���ȡ����', $
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


          ENVI_FILE_MNG,id=fid,/remove; �ر��ļ�
          jd = (FLOAT(i)*100)/num + (k+1)*per;��ʾ������
          IDLITWDPROGRESSBAR1_SETVALUE,(*pState).PRSBAR,jd
        ENDFOR
        ;�� Inf ���� -Inf ��Ϊ Nan
        ndvi = FINITE(ndvi)*ndvi
        evi = FINITE(evi)*evi
        lswi = FINITE(lswi)*lswi
        ;����1������Ϊ1��С��0������Ϊ0
        evi = (evi LT 0)*0 + (evi GT 10000)*10000 + $
          ((evi GE 0) AND (evi LE 10000))*evi
        ;���img
       
        bnames=STRING([1:n])

        ;��������ļ����� ����ָ�������ļ���Ȼ������ļ�
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
      void = DIALOG_MESSAGE('������� ',title = !SYS_TITLE,/infor)
      ;�ر�ENVI���ο���ģʽ
      ENVI_BATCH_EXIT
    END
    ELSE:
  ENDCASE
END
;
;--------------------------
;ENVI���ο���������ģ��
PRO BATCH_VI_CAL_MODIS
  ;
  COMPILE_OPT idl2
  ;��ʼ�������С
  sz = [600,400]
  ;����ϵͳ�������ɷ����޸�ϵͳ����
  DEFSYSV,'!SYS_Title','MODISָ������������'
  ;��������Ĵ���
  tlb = WIDGET_BASE(MBAR= mBar, $
    /COLUMN , $
    title = !SYS_TITLE, $
    /Tlb_Kill_Request_Events, $
    tlb_frame_attr = 1, $
    Map = 0)
  ;�����˵�
  fMenu = WIDGET_BUTTON(mBar, value ='�ļ�',/Menu)
  wButton = WIDGET_BUTTON(fMenu,value ='����������·��', $
    uName = 'open')
  fExit = WIDGET_BUTTON(fMenu, value = '�˳�', $
    uName = 'exit',/Sep)
  eMenu = WIDGET_BUTTON(mBar,value ='����',/Menu)
  wButton = WIDGET_BUTTON(eMenu,$
    value ='����������', $
    uName = 'execute')
  hMenu =  WIDGET_BUTTON(mBar, value ='����',/Menu)
  hHelp = WIDGET_BUTTON(hmenu, value = '����', $
    uName = 'about',/Sep)
  ;���������base
  wInputBase = WIDGET_BASE(tlb, $
    xSize =sz[0], $
    /Frame, $
    /Align_Center,$
    /Column)


  wLabel= WIDGET_LABEL(wInputBase, $
    value ='�ļ�������')
  wList = WIDGET_LIST(wInputBase, $
    YSize = sz[1]/(2*15),$
    XSize = sz[0]/8)

  ;���·������
  wLabel= WIDGET_LABEL(tlb, $
    value ='�����������')

  ;����������ƽ���
  wSetBase = WIDGET_BASE(tlb, $
    xSize =sz[0], $
    /Row)
  values = ['Դ�ļ�·��', $
    '��ѡ��·��']
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
    value ='ѡ��·��', $
    uName ='selePath')
  ;
  ;ִ�а�ťbase
  wExecuteBase = WIDGET_BASE(tlb,$
    /align_center,$
    /row)
  wButton = WIDGET_BUTTON(wExecuteBase, $
    ysize =40,$
    value ='����������·��', $
    uName = 'open')
  wButton = WIDGET_BUTTON(wExecuteBase,$
    value ='����������', $
    uName = 'execute')
  ;״̬��������ʾ������
  wStatus = WIDGET_BASE(tlb,/align_right)
  prsbar = IDLITWDPROGRESSBAR1( wExecuteBase ,$
    title ='����', $
    CANCEL =0)
  ;�ṹ�崫�ݲ���
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
  ;�����������
  CENTERTLB,tlb
  ;
  WIDGET_CONTROL, tlb,/Realize,/map,set_uValue = pState
  XMANAGER,'Batch_Vi_cal_MODIS',tlb,/No_Block,$
    cleanup ='Batch_Vi_cal_MODIS_Cleanup'
END
