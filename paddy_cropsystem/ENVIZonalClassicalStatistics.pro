;+
; :Description:
;    ENVI��չ���ߣ�����ͳ�ƹ���
;    ��������shapefile�ļ���ָ��ĳ�ֶΣ����з���ͳ��
;    ������Сֵ�����ֵ����ֵ����׼���Ԫ���������
;
; :Author: duhj@esrichina.com.cn
;
; :Note:
;    ���ENVI�汾��ENVI 5.2 SP1
;-

; Add the extension to the toolbox. Called automatically on ENVI startup.
;PRO ENVIZonalClassicalStatistics_extensions_init
;
;  ; Set compile options
;  COMPILE_OPT IDL2
;
;  ; Get ENVI session
;  e = ENVI(/CURRENT)
;
;  ; Add the extension to a subfolder
;  e.AddExtension, 'Zonal Statistics', 'ENVI_Zonal_Statistics', PATH=''
;END


PRO ENVIZonalClassicalStatistics_event, ev

  COMPILE_OPT idl2
  WIDGET_CONTROL, ev.TOP, GET_UVALUE=pState

  uname = WIDGET_INFO(ev.ID, /UNAME)

  CASE uname OF
    'OK': BEGIN
      ;
      ;��ȡ���·��
      WIDGET_CONTROL, (*pState).WOUT, GET_VALUE=csvFile
      IF csvFile EQ '' THEN RETURN
      ;
      basename =  FILE_BASENAME(csvFile, STRMID(csvFile, STRPOS(csvFile, '.', /REVERSE_SEARCH)))
      csvFile = FILE_DIRNAME(csvFile)+PATH_SEP()+basename+'.csv'
      WIDGET_CONTROL, (*pState).WOUT, SET_VALUE=csvFile

      ;����ļ��Ѵ��ڣ���ʾ�Ƿ��滻
      IF FILE_TEST(csvFile) THEN BEGIN
        ;����ļ��Ѵ��ڣ�������ʾ�Ƿ񸲸�
        msgArr = ['File: ' + csvFile, '', $
          'WARNING: This file already exists. If you use this name, then the existing file will be overwritten.', $
          'Use this filename ?']

        result = DIALOG_MESSAGE(msgArr, title = 'ENVI Question', /question)

        IF result EQ 'No' THEN RETURN $
        ELSE FILE_DELETE, csvFile, /QUIET
      ENDIF


      Raster = (*pState).RASTER
      shpFile = (*pState).SHPFILE

      ;��ȡ�����ֶ�
      zoneIdx = WIDGET_INFO((*pState).ZONELIST, /DROPLIST_SELECT)
      zoneField = ((*pState).ATTR_NAMES)[zoneIdx]

      ;����ͳ��
      ENVIZonalStatistics, Raster, shpFile=shpFile, $
        csvFile=csvFile, zoneField=zoneField, inFile=(*pState).INFILE

      Raster.Close
      ;
      WIDGET_CONTROL, ev.TOP, /DESTROY
    END

    'Cancel': BEGIN
      WIDGET_CONTROL, ev.TOP, /DESTROY
      RETURN
    END

    ELSE:
  ENDCASE
END


; ENVI Extension code. Called when the toolbox item is chosen.
PRO ENVIZonalClassicalStatistics

  ; Set compile options
  COMPILE_OPT IDL2

  ; General error handler
  CATCH, err
  IF (err NE 0) THEN BEGIN
    CATCH, /CANCEL
    IF OBJ_VALID(e) THEN $
      e.ReportError, 'ERROR: ' + !ERROR_STATE.MSG
    MESSAGE, /RESET
    RETURN
  ENDIF

  ;Get ENVI session
  e = ENVI(/CURRENT)

  SetENVIFont, /YAHEI, DEFAULT=DEFAULT

  ;******************************************
  ; Insert your ENVI Extension code here...
  ;******************************************

  UI = e.UI
  Raster = UI.SelectInputData(/RASTER, Bands=Bands, Sub_RECT=Sub_RECT, $
    title = 'Select the Input Raster File', /DISABLE_NO_DATA)
  IF Raster EQ !NULL THEN RETURN
  inFile = Raster.URI

  Raster = ENVISUBSETRASTER(Raster, Bands=Bands, SUB_RECT=Sub_RECT)

  Vector = UI.SelectInputData(/VECTOR, title='Select the Input Vecter File',$
    /DISABLE_NO_DATA)
  IF Vector EQ !NULL THEN RETURN
  shpFile = Vector.URI

  ;��ȡ�����ֶ�
  ;��ȡshp�ļ�����Ϣ
  oshp=OBJ_NEW('IDLffShape',shpFile)
  IF ~OBJ_VALID(oshp) THEN RETURN
  oshp->GETPROPERTY, ATTRIBUTE_NAMES = attr_names

  ENVI_CENTER, xoff, yoff
  tlb = WIDGET_BASE(TITLE='Zonal Statistics Parameters', /COLUMN, $
    XOFFSET=xoff, YOFFSET=yoff, TLB_FRAME_ATTR=1)

  zoneBase = WIDGET_BASE(tlb, /ROW, /FRAME, XSIZE=400)
  zoneBase = WIDGET_BASE(zoneBase, /ROW, XOFFSET=0)
  zoneLabel = WIDGET_LABEL(zoneBase, VALUE='Zone Field ' )
  zoneList = WIDGET_DROPLIST(zoneBase, VALUE=attr_names , /FLAT, YSIZE=25)

  ;���·��
  outPath =  e.GetPreference('OUTPUT_DIRECTORY')
  basename = FILE_BASENAME(inFile, STRMID(inFile, STRPOS(inFile, '.', /REVERSE_SEARCH)))
  csvFile = outPath+basename+'_stats.csv'

  outBase = WIDGET_BASE(tlb, /FRAME, /COLUMN)
  wOut = WIDGET_OUTF(outBase, XSIZE=57, /AUTO_MANAGE, $
    PROMPT='Enter Output Filename (*.csv) ', DEFAULT=csvFile)

  ;ȷ����ť
  okBase = WIDGET_BASE(tlb, /ROW, /FRAME)
  okBtn = WIDGET_BUTTON(okBase, value='OK', uname='OK', XSIZE=60)
  cancelBtn = WIDGET_BUTTON(okBase, value='Cancel',uname='Cancel',XSIZE=80)

  WIDGET_CONTROL, tlb, /REALIZE
  SetENVIFont, font=DEFAULT

  pState = {                $
    RASTER:Raster,          $
    INFILE:inFile,          $
    SHPFILE:shpFile,        $
    ATTR_NAMES:attr_names,  $
    ZONELIST:zoneList,      $
    WOUT:wOut               $
  }

  WIDGET_CONTROL, tlb, SET_UVALUE=PTR_NEW(pState)

  XMANAGER, 'ENVI_Zonal_Statistics', tlb, /NO_BLOCK
END

PRO ENVIZonalStatistics, Raster, shpFile=shpFile, $
  csvFile=csvFile, zoneField=zoneField, inFile=inFile

  COMPILE_OPT idl2
  e = ENVI(/current)
  CATCH, err
  IF (err NE 0) THEN BEGIN
    CATCH, /CANCEL
    IF OBJ_VALID(e) THEN $
      e.ReportError, 'ERROR: ' + !ERROR_STATE.MSG
    MESSAGE, /RESET
    RETURN
  ENDIF

  fid = ENVIRASTERTOFID(raster)
  ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, dims=dims

  ;��ȡshp�ļ�����Ϣ
  oshp=OBJ_NEW('IDLffShape',shpFile)
  IF ~OBJ_VALID(oshp) THEN RETURN
  oshp->GETPROPERTY,n_entities=n_ent,$ ;��¼����
    Attribute_info=attr_info,$ ;������Ϣ���ṹ�壬 nameΪ������
    ATTRIBUTE_NAMES = attr_names, $
    n_attributes=n_attr,$ ;���Ը���
    Entity_type=ent_type  ;��¼����

  name = zoneField
  names = !NULL
  attrIdx = WHERE(attr_names EQ name)

  ;��ȡ����ƥ���ֶ�
  FOR i = 0, n_ent-1 DO BEGIN
    ;
    ent = oshp->GETENTITY(i, /ATTRIBUTES) ;��i����¼
    ;   ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ���� ����
    names = [names, (*(ent.ATTRIBUTES)).(attrIdx)]
  ENDFOR
  ;��Ψһֵ
  uniqNames = names[UNIQ(names, SORT(names))]
  nUniq = N_ELEMENTS(uniqNames)
  IF nUniq EQ n_ent THEN uniqFlag = 1 ELSE uniqFlag = 0

  iProj = ENVI_PROJ_CREATE(/geographic)
  ;�Զ���ȡprj�ļ���ȡͶӰ����ϵ
  potPos = STRPOS(shpFile,'.',/reverse_search)  ;
  prjfile = STRMID(shpFile,0,potPos[0])+'.prj'

  IF FILE_TEST(prjfile) THEN BEGIN
    OPENR, lun, prjFile, /GET_LUN
    strprj = ''
    READF, lun, strprj
    FREE_LUN, lun

    CASE STRMID(strprj, 0,6) OF
      'GEOGCS': BEGIN
        iProj = ENVI_PROJ_CREATE(PE_COORD_SYS_STR=strprj, $
          type = 1)
      END
      'PROJCS': BEGIN
        iProj = ENVI_PROJ_CREATE(PE_COORD_SYS_STR=strprj, $
          type = 42)
      END
    ENDCASE
  ENDIF

  oProj = ENVI_GET_PROJECTION(fid = fid)
  Attrs = STRARR(n_attr, n_ent)

  statsMIN = !NULL
  statsMAX = !NULL
  statsMEAN = !NULL
  statsCOUNTS = !NULL
  statsSTDDEV = !NULL

  ;��ʼ��������
  ENVI_REPORT_INIT, ['Input Raster File: '+inFile, 'Input Vector File: '+shpFile, $
    'Output Stats File: '+csvFile], title="Zonal Statistics", $
    base=base

  CASE uniqFlag OF

    ;�������Ψһֵ������Ҫ�ҵ�ÿ��Name�еļ�¼
    0: BEGIN


      ENVI_REPORT_INC, base, nUniq

      FOR i=0, nUniq-1 DO BEGIN
        ;�ҵ�name����ΪuniqNames[i]�ļ�¼
        idx = WHERE(names EQ uniqNames[i])

        ;��ȡ���м�¼
        ent = oshp->GETENTITY(idx, /ATTRIBUTES)
        verts = !NULL
        FOREACH element, ent DO BEGIN
          vertstmp=*(element.VERTICES)
          verts = [[verts], [vertstmp]]
        ENDFOREACH

        ;��ȡSub_RECT
        ENVI_CONVERT_PROJECTION_COORDINATES,  $
          verts[0,*], verts[1,*], iProj,    $
          oXmap, oYmap, oProj
        ; ת��Ϊ�ļ�����
        ENVI_CONVERT_FILE_COORDINATES,fid,    $
          xFile,yFile,oXmap,oYmap

        xFile = xFile > 0 < ns
        yFile = yFile > 0 < nl

        sub_Rect = LONG64([MIN(xFile),MIN(yFile),MAX(xFile),MAX(yFile)])
        subRaster = ENVISUBSETRASTER(Raster, SUB_RECT=sub_Rect)
        subFid = ENVIRASTERTOFID(subRaster)
        ENVI_FILE_QUERY, subFid, ns=subNS, nl=subNL

        ;������״̬����
        ENVI_REPORT_STAT, base, i, nUniq

        ;��ȡÿ����¼��Ϣ������roi_ids
        roi_ids = !NULL
        FOR j=0, N_ELEMENTS(idx)-1 DO BEGIN
          ;
          ent = oshp->GETENTITY(idx[j], /ATTRIBUTES) ;��i����¼

          N_VERTICES=ent.N_VERTICES ;�������
          parts=*(ent.PARTS)
          verts=*(ent.VERTICES)
          ; ����������ת��Ϊ�����ļ��ĵ�������
          ENVI_CONVERT_PROJECTION_COORDINATES,  $
            verts[0,*], verts[1,*], iProj,    $
            oXmap, oYmap, oProj
          ; ת��Ϊ�ļ�����
          ENVI_CONVERT_FILE_COORDINATES,fid,    $
            xFile,yFile,oXmap,oYmap

          xFile = xFile > 0 < ns
          yFile = yFile > 0 < nl

          ; ת��Ϊ�ļ�����
          ENVI_CONVERT_FILE_COORDINATES, subFid,    $
            xFile,yFile,oXmap,oYmap

          xFile = LONG64(xFile)
          yFile = LONG64(yFile)

          ;����ROI
          N_Parts = N_ELEMENTS(Parts)

          FOR k=0, N_Parts-1 DO BEGIN
            roi_id = ENVI_CREATE_ROI(color=i,     $
              ns = subNS ,  nl = subNL)
            IF k EQ N_Parts-1 THEN BEGIN
              tmpFileX = xFile[Parts[k]:*]
              tmpFileY = yFile[Parts[k]:*]
            ENDIF ELSE BEGIN
              tmpFileX = xFile[Parts[k]:Parts[k+1]-1]
              tmpFileY = yFile[Parts[k]:Parts[k+1]-1]
            ENDELSE

            ENVI_DEFINE_ROI, roi_id, /polygon,    $
              xpts=REFORM(tmpFileX), ypts=REFORM(tmpFileY)

            ;����е�ROI��Ԫ��Ϊ0���򲻱���
            ENVI_GET_ROI_INFORMATION, roi_id, NPTS=npts
            IF npts EQ 0 THEN CONTINUE

            roi_ids = [roi_ids, roi_id]
          ENDFOR
        ENDFOR

        roiFile = e.GetTemporaryFilename('roi')
        ENVI_SAVE_ROIS, roiFile, roi_ids

        ;����ENVI�ӿڽ�����Ĥ��ͳ��
        roi = e.OpenROI(roiFile)
        rasterWithMask = ENVIROIMASKRASTER(SubRaster, roi)

        stats = freq(rasterWithMask.getadata())
        stats[
        ;���β�Ϊ1ʱ������ͳ��COUNTS
        stats = ENVIRasterStatistics(ENVISUBSETRASTER(rasterWithMask,bands=[0]), $
          /HISTOGRAMS, HISTOGRAM_NBINS=1)
        Hist = stats.HISTOGRAMS
        Hist = Hist[0]
        COUNTS = Hist.COUNTS

        stats = ENVIRasterStatistics(rasterWithMask)

        statsMIN = [[statsMIN], [stats.MIN]]
        statsMAX = [[statsMAX], [stats.MAX]]
        statsMEAN = [[statsMEAN], [stats.MEAN]]
        statsCOUNTS = [[statsCOUNTS], COUNTS]
        statsSTDDEV = [[statsSTDDEV], [stats.STDDEV]]

        rasterWithMask.Close
        SubRaster.Close
        ENVI_FILE_MNG, id=subFid, /remove
        FOREACH element, roi DO element.CLOSE
        FILE_DELETE, roiFile, /QUIET

      ENDFOR

      ;����Ҫд����ͳ�ƽ������ΪHASH
      h = ORDEREDHASH()

      ;��ԭʼshapefile������NAME���Ա��浽HASH��
      h = h + ORDEREDHASH(name, uniqNames)

      ;���ڴ洢CSV���ı�ͷ
      header = name

      ;����COUNTS
      header = [header, 'COUNT']
      h = h + ORDEREDHASH('COUNT___', statsCOUNTS)

      ;�����λΪ�ף���ͳ�����
      map_info = ENVI_GET_MAP_INFO(fid=fid)
      IF oproj.UNITS EQ 0 THEN BEGIN
        header = [header, 'AREA']
        h = h + ORDEREDHASH('AREA___', statsCOUNTS*PRODUCT(map_info.PS))
      ENDIF

      ;����Сֵ�����ֵ����ֵ����׼�����HASH��
      statsNames = ['MIN','MAX','MEAN', 'STDDEV']
      FOR i=0,nb-1 DO BEGIN
        bandNames = statsNames + ' (Band ' + STRTRIM(i+1,2) + ')'
        IF nb EQ 1 THEN bandNames = statsNames
        header = [header, bandNames]

        h = h + ORDEREDHASH(bandNames+'___', $
          LIST(statsMIN[i,*], statsMAX[i,*], statsMEAN[i,*], statsSTDDEV[i,*]))
      ENDFOR

    END
    1: BEGIN

      ENVI_REPORT_INC, base, nUniq

      ;ѭ���У�ʹ��ÿ��shp��¼������roi
      ;Ȼ��ʹ��ROI������Ĥͳ��
      FOR i = 0, n_ent-1 DO BEGIN
        ;
        ent = oshp->GETENTITY(i, /ATTRIBUTES) ;��i����¼

        FOR j=0,n_attr-1 DO BEGIN
          Attrs[j,i] = (*(ent.ATTRIBUTES)).(j)
        ENDFOR

        N_VERTICES=ent.N_VERTICES ;�������
        parts=*(ent.PARTS)
        verts=*(ent.VERTICES)
        ; ����������ת��Ϊ�����ļ��ĵ�������
        ENVI_CONVERT_PROJECTION_COORDINATES,  $
          verts[0,*], verts[1,*], iProj,    $
          oXmap, oYmap, oProj
        ; ת��Ϊ�ļ�����
        ENVI_CONVERT_FILE_COORDINATES,fid,    $
          xFile,yFile,oXmap,oYmap

        xFile = xFile > 0 < ns
        yFile = yFile > 0 < nl

        sub_Rect = LONG64([MIN(xFile),MIN(yFile),MAX(xFile),MAX(yFile)])

        subRaster = ENVISUBSETRASTER(Raster, SUB_RECT=sub_Rect)
        subFid = ENVIRASTERTOFID(subRaster)
        ENVI_FILE_QUERY, subFid, ns=subNS, nl=subNL
        ; ת��Ϊ�ļ�����
        ENVI_CONVERT_FILE_COORDINATES, subFid,    $
          xFile,yFile,oXmap,oYmap

        xFile = LONG64(xFile)
        yFile = LONG64(yFile)

        ;����ROI
        N_Parts = N_ELEMENTS(Parts)
        roi_ids = !NULL
        FOR j=0, N_Parts-1 DO BEGIN
          roi_id = ENVI_CREATE_ROI(color=i,     $
            ns = subNS ,  nl = subNL)
          IF j EQ N_Parts-1 THEN BEGIN
            tmpFileX = xFile[Parts[j]:*]
            tmpFileY = yFile[Parts[j]:*]
          ENDIF ELSE BEGIN
            tmpFileX = xFile[Parts[j]:Parts[j+1]-1]
            tmpFileY = yFile[Parts[j]:Parts[j+1]-1]
          ENDELSE

          ENVI_DEFINE_ROI, roi_id, /polygon,    $
            xpts=REFORM(tmpFileX), ypts=REFORM(tmpFileY)

          ;����е�ROI��Ԫ��Ϊ0���򲻱���
          ENVI_GET_ROI_INFORMATION, roi_id, NPTS=npts
          IF npts EQ 0 THEN CONTINUE

          roi_ids = [roi_ids, roi_id]
        ENDFOR

        ENVI_REPORT_STAT,base, i, n_ent

        ;
        name = Attrs[attrIdx, i]
        roiFile = e.GetTemporaryFilename('roi')
        ENVI_SAVE_ROIS, roiFile, roi_ids

        ;����ENVI�ӿڽ�����Ĥ��ͳ��
        roi = e.OpenROI(roiFile)
        rasterWithMask = ENVIROIMASKRASTER(SubRaster, roi)
        
        ;���β�Ϊ1ʱ������ͳ��COUNTS
        stats = ENVIRasterStatistics(ENVISUBSETRASTER(rasterWithMask,bands=[0]), $
          /HISTOGRAMS, HISTOGRAM_NBINS=1)
        Hist = stats.HISTOGRAMS
        Hist = Hist[0]
        COUNTS = Hist.COUNTS

        stats = ENVIRasterStatistics(rasterWithMask)

        statsMIN = [[statsMIN], [stats.MIN]]
        statsMAX = [[statsMAX], [stats.MAX]]
        statsMEAN = [[statsMEAN], [stats.MEAN]]
        statsCOUNTS = [[statsCOUNTS], COUNTS]
        statsSTDDEV = [[statsSTDDEV], [stats.STDDEV]]

        rasterWithMask.Close
        SubRaster.Close
        ENVI_FILE_MNG, id=subFid, /remove
        FOREACH element, roi DO element.CLOSE
        FILE_DELETE, roiFile, /QUIET

      ENDFOR

      ;����Ҫд����ͳ�ƽ������ΪHASH
      h = ORDEREDHASH()

      ;��ԭʼshapefile���������Ա��浽HASH��
      FOR i=0,n_attr-1 DO h = h + ORDEREDHASH(attr_names[i], REFORM(attrs[i,*]))

      ;���ڴ洢CSV���ı�ͷ
      header = attr_names

      ;����COUNTS
      header = [header, 'COUNT']
      h = h + ORDEREDHASH('COUNT___', statsCOUNTS)

      ;�����λΪ�ף���ͳ�����
      map_info = ENVI_GET_MAP_INFO(fid=fid)
      IF oproj.UNITS EQ 0 THEN BEGIN
        header = [header, 'AREA']
        h = h + ORDEREDHASH('AREA___', statsCOUNTS*PRODUCT(map_info.PS))
      ENDIF

      ;����Сֵ�����ֵ����ֵ����׼�����HASH��
      statsNames = ['MIN','MAX','MEAN', 'STDDEV']
      FOR i=0,nb-1 DO BEGIN
        bandNames = statsNames + ' (Band ' + STRTRIM(i+1,2) + ')'
        IF nb EQ 1 THEN bandNames = statsNames
        header = [header, bandNames]

        h = h + ORDEREDHASH(bandNames+'___', $
          LIST(statsMIN[i,*], statsMAX[i,*], statsMEAN[i,*], statsSTDDEV[i,*]))
      ENDFOR
    END
  ENDCASE

  WRITE_CSV, csvFile, h.ToStruct(), HEADER=header

  SPAWN, csvFile, /HIDE, /NOWAIT

  ENVI_REPORT_INIT, base=base, /finish
END

PRO SetENVIFont, default=default, yahei=yahei, font=font
  IF KEYWORD_SET(yahei) THEN font = 'Microsoft Yahei*-12'
  IF ARG_PRESENT(default) THEN BEGIN
    tlb = WIDGET_BASE(map=0)
    wId = WIDGET_BUTTON(tlb, VALUE='test')
    WIDGET_CONTROL, tlb, /REALIZE
    default = WIDGET_INFO(wId, /FONTNAME)
    WIDGET_CONTROL, tlb, /DESTROY
  ENDIF
  WIDGET_CONTROL, DEFAULT_FONT=font
END