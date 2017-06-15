PRO ENVIZonalCLASSStatistics, shpFile=shpFile, $
  csvFile=csvFile, zoneField=zoneField, inFile=inFile

  COMPILE_OPT idl2

  infile = 'E:\paddy_extr\Processing\QBW\data_reclassfy\2013_subset_bm1_Reclas.tif'
  ;infile ='E:\������������\�Ϸ���˫��_�����\2013\2013.tif'
  zoneField = 'PYNAME'
  shpfile = 'E:\paddy_extr\Processing\QBW\STUDYAREAqbw1.shp'
  csvFile = 'E:\paddy_extr\Processing\QBW\2013statre.csv'

  e = ENVI();/current
  ;  CATCH, err
  ;  IF (err NE 0) THEN BEGIN
  ;    CATCH, /CANCEL
  ;    IF OBJ_VALID(e) THEN $
  ;      e.ReportError, 'ERROR: ' + !ERROR_STATE.MSG
  ;    MESSAGE, /RESET
  ;    RETURN
  ;  ENDIF

  Raster = e.openraster(infile)
  allDATA= Raster.getdata()
  className =  allDATA[UNIQ(allDATA, SORT(allDATA))]
  allDATA = !NULL
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

  ;  statsMIN = !NULL
  ;  statsMAX = !NULL
  ;  statsMEAN = !NULL
  ;  statsCOUNTS = !NULL
  ;  statsSTDDEV = !NULL

  count = lonarr(N_ELEMENTS(className))
  counts = !NULL

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

        ;       stats = freq(rasterWithMask.getadata())
        ;        stats[
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
        stats = freq(rasterWithMask.getdata())
        FOR k=0, N_ELEMENTS(stats[0,*])-1 DO count[where(className EQ stats[0,k])] = stats[1,k]
        counts = [[counts],[count]]
        ;���β�Ϊ1ʱ������ͳ��COUNTS
        ;        stats = ENVIRasterStatistics(ENVISUBSETRASTER(rasterWithMask,bands=[0]), $
        ;          /HISTOGRAMS, HISTOGRAM_NBINS=1)
        ;        Hist = stats.HISTOGRAMS
        ;        Hist = Hist[0]
        ;        COUNTS = Hist.COUNTS
        ;
        ;        stats = ENVIRasterStatistics(rasterWithMask)
        ;
        ;        statsMIN = [[statsMIN], [stats.MIN]]
        ;        statsMAX = [[statsMAX], [stats.MAX]]
        ;        statsMEAN = [[statsMEAN], [stats.MEAN]]
        ;        statsCOUNTS = [[statsCOUNTS], COUNTS]
        ;        statsSTDDEV = [[statsSTDDEV], [stats.STDDEV]]

        rasterWithMask.Close
        SubRaster.Close
        ENVI_FILE_MNG, id=subFid, /remove
        FOREACH element, roi DO element.CLOSE
        FILE_DELETE, roiFile, /QUIET

      ENDFOR

      ;      openw,lun,csvFile,/GET_LUN
      ;      printf,lun,'Year', ClassName
      ;      free_lun,lun


      ;����Ҫд����ͳ�ƽ������ΪHASH
      h = ORDEREDHASH()

      ;��ԭʼshapefile���������Ա��浽HASH��
      ; h = h + ORDEREDHASH(attr_names[attrIdx], REFORM(attrs[attrIdx,*]))
      FOR i=0,n_attr-1 DO h = h + ORDEREDHASH(attr_names[i], REFORM(attrs[i,*]))
      ;FOR i=6,6 DO h = h + ORDEREDHASH(attr_names[i], REFORM(attrs[i,*]))
      ;h = h + ORDEREDHASH('Year', REFORM(make_array(8,/INTEGER,VALUE=2013)))
      ;���ڴ洢CSV���ı�ͷ
      ;header = [attr_names,'Year']
      header = attr_names

      ;����COUNTS
      FOR i = 0, n_elements(className)-1 DO  BEGIN
        outfieldname = strcompress('COUNT'+string(fix(className[i])),/REMOVE_ALL)
        header =  [header,outfieldname]
        h = h + ORDEREDHASH(outfieldname+'___', counts[i,*])
      ENDFOR


      ;�����λΪ�ף���ͳ�����
      ;      map_info = ENVI_GET_MAP_INFO(fid=fid)
      ;      IF oproj.UNITS EQ 0 THEN BEGIN
      ;        header = [header, 'AREA']
      ;        h = h + ORDEREDHASH('AREA___', statsCOUNTS*PRODUCT(map_info.PS))
      ;      ENDIF
      ;
      ;      ;����Сֵ�����ֵ����ֵ����׼�����HASH��
      ;      statsNames = ['MIN','MAX','MEAN', 'STDDEV']
      ;      FOR i=0,nb-1 DO BEGIN
      ;        bandNames = statsNames + ' (Band ' + STRTRIM(i+1,2) + ')'
      ;        IF nb EQ 1 THEN bandNames = statsNames
      ;        header = [header, bandNames]
      ;
      ;        h = h + ORDEREDHASH(bandNames+'___', $
      ;          LIST(statsMIN[i,*], statsMAX[i,*], statsMEAN[i,*], statsSTDDEV[i,*]))
      ;      ENDFOR
    END
  ENDCASE

  WRITE_CSV, csvFile, h.ToStruct(), HEADER=header

  SPAWN, csvFile, /HIDE, /NOWAIT

  ENVI_REPORT_INIT, base=base, /finish
  e.close
END

;PRO SetENVIFont, default=default, yahei=yahei, font=font
;  IF KEYWORD_SET(yahei) THEN font = 'Microsoft Yahei*-12'
;  IF ARG_PRESENT(default) THEN BEGIN
;    tlb = WIDGET_BASE(map=0)
;    wId = WIDGET_BUTTON(tlb, VALUE='test')
;    WIDGET_CONTROL, tlb, /REALIZE
;    default = WIDGET_INFO(wId, /FONTNAME)
;    WIDGET_CONTROL, tlb, /DESTROY
;  ENDIF
;  WIDGET_CONTROL, DEFAULT_FONT=font
;END