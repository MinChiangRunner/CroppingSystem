PRO SELECTSAMPLET_EVENT, event
  COMPILE_OPT idl2
  COMMON IN, jj
  ;WIDGET_CONTROL,event.TOP, get_UValue = pState
  uname = WIDGET_INFO(event.ID,/uname)
  CASE uname OF
    'Value': BEGIN
      WIDGET_CONTROL,event.ID, get_value = b
      jj = b
      ;(*pstate).VALUE = b
    END
    'next':BEGIN
      WIDGET_CONTROL, event.TOP,/destroy
      RETURN
    END
    ELSE:
  ENDCASE
  ;  HELP, event
  ;  ; value = WIDGET_INFO(event.ID,/value)
  ;  ; print,value
  ;  WIDGET_CONTROL,event.ID, get_value = b
  ;
  ;  print,b
END



PRO SELECTSAMPLE
  COMPILE_OPT IDL2
  COMMON IN, jj
  ;file= 'E:\paddy_extr\site\SampleALL\PaddySampleFromROIS\RasterH27V05PaddySampleROIs.dat'
  ;file= 'E:\paddy_extr\site\SampleALL\PaddySampleFromROIS\RasterH27V06PaddySampleROIs.dat'
  ;file3= 'E:\paddy_extr\site\SampleALL\PaddySampleFromROIS\RasterH28V05PaddySampleROIs.dat'
  yanf = 'E:\paddy_extr\Data_Contrast\Yan\h28v06_gsnum.tif'
  DecloudFil = 'E:\paddy_extr\index\EVI_RE_blue'
  Hantsfil = 'E:\paddy_extr\test\HEVI_INTER_Hants2010.dat'
  HantsfilI = 'E:\paddy_extr\Processing\EVI\HANTEVI2010360I_psf_bil.dat'
  HantsfilB = 'E:\paddy_extr\Processing\EVI\HANTEVI2010360B_psf_bil.dat'
  ;file= 'E:\paddy_extr\site\SampleALL\PaddySampleFromROIS\RasterH28V06PaddySampleROIs.dat'
  EVIFile = 'E:\paddy_extr\index\2010\evi\h28v06_2010_evi_int10000'
  ;fsz = 'E:\paddy_extr\site\SampleALL\PaddySampleSZ\RasterH28V06SampleSZ.txt';临时保存
  ;fsz = 'E:\paddy_extr\site\SampleALL\PaddySampleSZ\RasterH28V06SampleSZFinal.dat'
  file =  'E:\paddy_extr\Processing\Validation\numpeak_18_38_DE3_8_HantsVLDSample.dat'
  e = envi(/headless);
  EVIRaster = e.OPENRASTER(EVIFile)
  EVI = EVIRaster.GETDATA()
  EVIRaster.CLOSE

  HantEviR = e.OPENRASTER(Hantsfil)
  HantEvi = HantEviR.GETDATA()
  HantEviR.CLOSE

  HantEviR = e.OPENRASTER(HantsfilI)
  HantEviI = HantEviR.GETDATA()
  HantEviR.CLOSE

  HantEviR = e.OPENRASTER(HantsfilB)
  HantEviB = HantEviR.GETDATA()
  HantEviR.CLOSE

  DecloudR = e.OPENRASTER(DecloudFil)
  Decloud = DecloudR.GETDATA()
  DecloudR.CLOSE

  YanR = read_tiff('E:\paddy_extr\Data_Contrast\Yan\h28v06_gsnum.tif')
  qbwd = read_tiff('E:\paddy_extr\base\qbw_2009_hv28.tif')
  SampleRaster = e.OPENRASTER(File)
  Sample = SampleRaster.GETDATA()
  Spatialref = Sampleraster.SPATIALREF

  IF 0 THEN BEGIN
    dims = Sample.DIM
    JJ = 0
    SZ = make_array(dims[0],dims[1],/INTEGER,value=0)
    openr,lun,fsz,/GET_LUN
    readf,lun,sz
    free_lun,lun
    Loc = where((Sample EQ 21), n)
    ;Loc = where((sz EQ 6), n)
    hlh = COLROWNUM(loc,dims[0])
    FOR i=0, n-1 DO BEGIN
      bb = PLOT(Decloud[hlh[0,i],hlh[1,i],*],'r',TITLE='除云结果')
      ee = PLOT(evi[hlh[0,i],hlh[1,i],*],'b',TITLE='拟合结果')
      dd = PLOT(HantEvi[hlh[0,i],hlh[1,i],*],'r',/overplot)
      print, YanR[hlh[0,i],hlh[1,i]]
      print, qbwd[hlh[0,i],hlh[1,i]]
      base = WIDGET_BASE(title ='精度验证' $
        ,/COLUMN,TLB_FRAME_ATTR=1);
      Value = CW_FIELD(base,TITLE = "行号：", $
        /FRAME,/integer,uname='Value', $
        /RETURN_EVENTS,/FOCUS_EVENTS)
      WIDGET_CONTROL, base,/Realize
      XMANAGER, 'SELECTSAMPLET', base, GROUP_LEADER = GROUP, /NO_BLOCK
      CENTERTLB, base
      stop
      bb.CLOSE
      ee.CLOSE
      sz[hlh[0,i],hlh[1,i]] = jj
      WIDGET_CONTROL, base,/destroy
      print, jj
      openw,lun,'E:\paddy_extr\site\SampleALL\PaddySampleSZ\RasterH28V06SampleSZ3_mod.txt',/GET_LUN
      printf,lun,sz
      free_lun,lun
    ENDFOR
    ok = dialog_message('判断完成!',/INFORMATION)
    ;输出
    OutName = 'E:\paddy_extr\site\SampleALL\PaddySampleSZ\RasterH28V06SampleSZFinal2th.dat'
    OutRaster = ENVIRASTER(SZ, URI=OutName, SPATIALREF=SPATIALREF)
    OutRaster.SAVE
  ENDIF

  IF 1 THEN BEGIN
    file = 'E:\paddy_extr\Processing\Validation\numpeak_18_39_DE2_8_HantsVLDSample.dat'
    ;file2 = 'E:\paddy_extr\Processing\RawResult\locpeak_18_39_DE2_8_Hants.dat'
    raster = e.OPENRASTER(file)
    data = raster.GETDATA()
    print,'核对12'
    loc = where(data NE 0,n)
    ;loc = where(data EQ 12,n)
    hlh = COLROWNUM(loc,2400)
    FOR i=0, n-1 DO BEGIN
      print,hlh[0,i],hlh[1,i]
      print,'qbw:', qbwd[hlh[0,i],hlh[1,i]]
      print,'yand:',Yanr[hlh[0,i],hlh[1,i]]

      bb = PLOT(Decloud[hlh[0,i],hlh[1,i],*],'r',TITLE='除云结果');,TITLE = "除云结果"
      dd = PLOT(fix(float(evi[hlh[0,i],hlh[1,i],*])/100.0),'b', TITLE="拟合对比")
      ee = PLOT(fix(float(HantEvi[hlh[0,i],hlh[1,i],*])/100.0),'r',/overplot)
      ff = PLOT(fix(float(HantEviI[hlh[0,i],hlh[1,i],*])/100.0),'g',/overplot)
      nn = PLOT(HantEviB[hlh[0,i],hlh[1,i],*],'k',/overplot)
      stop
      bb.CLOSE
      ee.CLOSE
      ;nn.CLOSE
      ;dd.CLOSE
    ENDFOR

    ;    xx = where(data EQ 21,n)
    ;    loc = COLROWNUM(xx,2400)
    ;    print,loc
    ;    FOR b=
    ;    b=string(loc[1,0])
    ;    print,loc[0,0],'p,',b.COMPRESS()
  ENDIF
END