;+
; :Description:
;    ENVI扩展工具：分区统计工具
;    根据输入shapefile文件，指定某字段，进行分区统计
;    包含最小值、最大值、均值、标准差、像元数、面积。
;
; :Author: duhj@esrichina.com.cn
;
; :Note:
;    最低ENVI版本：ENVI 5.2 SP1
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
      ;获取输出路径
      WIDGET_CONTROL, (*pState).WOUT, GET_VALUE=csvFile
      IF csvFile EQ '' THEN RETURN
      ;
      basename =  FILE_BASENAME(csvFile, STRMID(csvFile, STRPOS(csvFile, '.', /REVERSE_SEARCH)))
      csvFile = FILE_DIRNAME(csvFile)+PATH_SEP()+basename+'.csv'
      WIDGET_CONTROL, (*pState).WOUT, SET_VALUE=csvFile

      ;如果文件已存在，提示是否替换
      IF FILE_TEST(csvFile) THEN BEGIN
        ;如果文件已存在，弹出提示是否覆盖
        msgArr = ['File: ' + csvFile, '', $
          'WARNING: This file already exists. If you use this name, then the existing file will be overwritten.', $
          'Use this filename ?']

        result = DIALOG_MESSAGE(msgArr, title = 'ENVI Question', /question)

        IF result EQ 'No' THEN RETURN $
        ELSE FILE_DELETE, csvFile, /QUIET
      ENDIF


      Raster = (*pState).RASTER
      shpFile = (*pState).SHPFILE

      ;获取分区字段
      zoneIdx = WIDGET_INFO((*pState).ZONELIST, /DROPLIST_SELECT)
      zoneField = ((*pState).ATTR_NAMES)[zoneIdx]

      ;分区统计
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

  ;获取所有字段
  ;读取shp文件的信息
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

  ;输出路径
  outPath =  e.GetPreference('OUTPUT_DIRECTORY')
  basename = FILE_BASENAME(inFile, STRMID(inFile, STRPOS(inFile, '.', /REVERSE_SEARCH)))
  csvFile = outPath+basename+'_stats.csv'

  outBase = WIDGET_BASE(tlb, /FRAME, /COLUMN)
  wOut = WIDGET_OUTF(outBase, XSIZE=57, /AUTO_MANAGE, $
    PROMPT='Enter Output Filename (*.csv) ', DEFAULT=csvFile)

  ;确定按钮
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

  ;读取shp文件的信息
  oshp=OBJ_NEW('IDLffShape',shpFile)
  IF ~OBJ_VALID(oshp) THEN RETURN
  oshp->GETPROPERTY,n_entities=n_ent,$ ;记录个数
    Attribute_info=attr_info,$ ;属性信息，结构体， name为属性名
    ATTRIBUTE_NAMES = attr_names, $
    n_attributes=n_attr,$ ;属性个数
    Entity_type=ent_type  ;记录类型

  name = zoneField
  names = !NULL
  attrIdx = WHERE(attr_names EQ name)

  ;获取所有匹配字段
  FOR i = 0, n_ent-1 DO BEGIN
    ;
    ent = oshp->GETENTITY(i, /ATTRIBUTES) ;第i条记录
    ;   中区 中区 中区 中区 东区 中区 中区 中区 西区 西区 西区 中区 东区 东区 东区 西区
    names = [names, (*(ent.ATTRIBUTES)).(attrIdx)]
  ENDFOR
  ;求唯一值
  uniqNames = names[UNIQ(names, SORT(names))]
  nUniq = N_ELEMENTS(uniqNames)
  IF nUniq EQ n_ent THEN uniqFlag = 1 ELSE uniqFlag = 0

  iProj = ENVI_PROJ_CREATE(/geographic)
  ;自动读取prj文件获取投影坐标系
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

  ;初始化进度条
  ENVI_REPORT_INIT, ['Input Raster File: '+inFile, 'Input Vector File: '+shpFile, $
    'Output Stats File: '+csvFile], title="Zonal Statistics", $
    base=base

  CASE uniqFlag OF

    ;如果不是唯一值，则需要找到每个Name中的记录
    0: BEGIN


      ENVI_REPORT_INC, base, nUniq

      FOR i=0, nUniq-1 DO BEGIN
        ;找到name属性为uniqNames[i]的记录
        idx = WHERE(names EQ uniqNames[i])

        ;获取所有记录
        ent = oshp->GETENTITY(idx, /ATTRIBUTES)
        verts = !NULL
        FOREACH element, ent DO BEGIN
          vertstmp=*(element.VERTICES)
          verts = [[verts], [vertstmp]]
        ENDFOREACH

        ;获取Sub_RECT
        ENVI_CONVERT_PROJECTION_COORDINATES,  $
          verts[0,*], verts[1,*], iProj,    $
          oXmap, oYmap, oProj
        ; 转换为文件坐标
        ENVI_CONVERT_FILE_COORDINATES,fid,    $
          xFile,yFile,oXmap,oYmap

        xFile = xFile > 0 < ns
        yFile = yFile > 0 < nl

        sub_Rect = LONG64([MIN(xFile),MIN(yFile),MAX(xFile),MAX(yFile)])
        subRaster = ENVISUBSETRASTER(Raster, SUB_RECT=sub_Rect)
        subFid = ENVIRASTERTOFID(subRaster)
        ENVI_FILE_QUERY, subFid, ns=subNS, nl=subNL

        ;进度条状态更新
        ENVI_REPORT_STAT, base, i, nUniq

        ;获取每条记录信息，生成roi_ids
        roi_ids = !NULL
        FOR j=0, N_ELEMENTS(idx)-1 DO BEGIN
          ;
          ent = oshp->GETENTITY(idx[j], /ATTRIBUTES) ;第i条记录

          N_VERTICES=ent.N_VERTICES ;顶点个数
          parts=*(ent.PARTS)
          verts=*(ent.VERTICES)
          ; 将顶点坐标转换为输入文件的地理坐标
          ENVI_CONVERT_PROJECTION_COORDINATES,  $
            verts[0,*], verts[1,*], iProj,    $
            oXmap, oYmap, oProj
          ; 转换为文件坐标
          ENVI_CONVERT_FILE_COORDINATES,fid,    $
            xFile,yFile,oXmap,oYmap

          xFile = xFile > 0 < ns
          yFile = yFile > 0 < nl

          ; 转换为文件坐标
          ENVI_CONVERT_FILE_COORDINATES, subFid,    $
            xFile,yFile,oXmap,oYmap

          xFile = LONG64(xFile)
          yFile = LONG64(yFile)

          ;创建ROI
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

            ;如果有的ROI像元数为0，则不保存
            ENVI_GET_ROI_INFORMATION, roi_id, NPTS=npts
            IF npts EQ 0 THEN CONTINUE

            roi_ids = [roi_ids, roi_id]
          ENDFOR
        ENDFOR

        roiFile = e.GetTemporaryFilename('roi')
        ENVI_SAVE_ROIS, roiFile, roi_ids

        ;调用ENVI接口进行掩膜、统计
        roi = e.OpenROI(roiFile)
        rasterWithMask = ENVIROIMASKRASTER(SubRaster, roi)

        stats = freq(rasterWithMask.getadata())
        stats[
        ;波段不为1时，单独统计COUNTS
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

      ;将需要写出的统计结果保存为HASH
      h = ORDEREDHASH()

      ;将原始shapefile中所有NAME属性保存到HASH中
      h = h + ORDEREDHASH(name, uniqNames)

      ;用于存储CSV表格的表头
      header = name

      ;加入COUNTS
      header = [header, 'COUNT']
      h = h + ORDEREDHASH('COUNT___', statsCOUNTS)

      ;如果单位为米，则统计面积
      map_info = ENVI_GET_MAP_INFO(fid=fid)
      IF oproj.UNITS EQ 0 THEN BEGIN
        header = [header, 'AREA']
        h = h + ORDEREDHASH('AREA___', statsCOUNTS*PRODUCT(map_info.PS))
      ENDIF

      ;将最小值、最大值、均值、标准差保存在HASH中
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

      ;循环中，使用每条shp记录，创建roi
      ;然后使用ROI进行掩膜统计
      FOR i = 0, n_ent-1 DO BEGIN
        ;
        ent = oshp->GETENTITY(i, /ATTRIBUTES) ;第i条记录

        FOR j=0,n_attr-1 DO BEGIN
          Attrs[j,i] = (*(ent.ATTRIBUTES)).(j)
        ENDFOR

        N_VERTICES=ent.N_VERTICES ;顶点个数
        parts=*(ent.PARTS)
        verts=*(ent.VERTICES)
        ; 将顶点坐标转换为输入文件的地理坐标
        ENVI_CONVERT_PROJECTION_COORDINATES,  $
          verts[0,*], verts[1,*], iProj,    $
          oXmap, oYmap, oProj
        ; 转换为文件坐标
        ENVI_CONVERT_FILE_COORDINATES,fid,    $
          xFile,yFile,oXmap,oYmap

        xFile = xFile > 0 < ns
        yFile = yFile > 0 < nl

        sub_Rect = LONG64([MIN(xFile),MIN(yFile),MAX(xFile),MAX(yFile)])

        subRaster = ENVISUBSETRASTER(Raster, SUB_RECT=sub_Rect)
        subFid = ENVIRASTERTOFID(subRaster)
        ENVI_FILE_QUERY, subFid, ns=subNS, nl=subNL
        ; 转换为文件坐标
        ENVI_CONVERT_FILE_COORDINATES, subFid,    $
          xFile,yFile,oXmap,oYmap

        xFile = LONG64(xFile)
        yFile = LONG64(yFile)

        ;创建ROI
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

          ;如果有的ROI像元数为0，则不保存
          ENVI_GET_ROI_INFORMATION, roi_id, NPTS=npts
          IF npts EQ 0 THEN CONTINUE

          roi_ids = [roi_ids, roi_id]
        ENDFOR

        ENVI_REPORT_STAT,base, i, n_ent

        ;
        name = Attrs[attrIdx, i]
        roiFile = e.GetTemporaryFilename('roi')
        ENVI_SAVE_ROIS, roiFile, roi_ids

        ;调用ENVI接口进行掩膜、统计
        roi = e.OpenROI(roiFile)
        rasterWithMask = ENVIROIMASKRASTER(SubRaster, roi)
        
        ;波段不为1时，单独统计COUNTS
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

      ;将需要写出的统计结果保存为HASH
      h = ORDEREDHASH()

      ;将原始shapefile中所有属性保存到HASH中
      FOR i=0,n_attr-1 DO h = h + ORDEREDHASH(attr_names[i], REFORM(attrs[i,*]))

      ;用于存储CSV表格的表头
      header = attr_names

      ;加入COUNTS
      header = [header, 'COUNT']
      h = h + ORDEREDHASH('COUNT___', statsCOUNTS)

      ;如果单位为米，则统计面积
      map_info = ENVI_GET_MAP_INFO(fid=fid)
      IF oproj.UNITS EQ 0 THEN BEGIN
        header = [header, 'AREA']
        h = h + ORDEREDHASH('AREA___', statsCOUNTS*PRODUCT(map_info.PS))
      ENDIF

      ;将最小值、最大值、均值、标准差保存在HASH中
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