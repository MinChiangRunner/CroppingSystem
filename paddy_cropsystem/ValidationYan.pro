PRO VALIDATIONYan
  COMPILE_OPT idl2
  e = Envi(/headless)
  ;data: b1:Yan b2:mine b3: paddy2010
  ;(((b1 eq 0) or (b1 eq 1) or (b1 eq 2)
  ; or (b1 eq 3))*b1*10+ (b1 eq 4)*10 +
  ;(b1 eq 5)*20 + b2)*b3
  ;33 22 11 一致 21 12 31 13 不一致

  IF 1 THEN BEGIN
    ;验证数据
;    YanFile = 'E:\paddy_extr\test\JXYan.dat'
;    b1Raster = e.OPENRASTER(YanFile)
;    b1 = b1Raster.GETDATA()
;    b1Raster.CLOSE
    b1 = read_tiff('E:\paddy_extr\Data_Contrast\Yan\h28v06_gsnum.tif')
    ;结果数据
    ;MineFile = 'E:\paddy_extr\test\result\numpeak_18_38_DE3_11_Hants_all.dat'
    MineFile = 'E:\paddy_extr\Processing\RawResult\numpeak_18_39_DE2_8_Hants.dat'
    b2Raster = e.OPENRASTER(MineFile)
    b2 = b2Raster.GETDATA()
    b2Raster.CLOSE

    ;水稻掩膜
    ;PaddyFile = 'E:\paddy_extr\test\JXTestPaddy2010.dat'
    PaddyFile = 'E:\paddy_extr\site\SampleALL\H28V06_paddy_mask.dat'
    b3Raster = e.OPENRASTER(PaddyFile)
    b3 = b3Raster.GETDATA()
    SpatialRef = b3Raster.SPATIALREF
    ;b3Raster.close

    ;计算
    data = (((b1 EQ 0) OR (b1 EQ 1) OR (b1 EQ 2) $
      OR (b1 EQ 3))*b1*10+ (b1 EQ 4)*10 + $
      (b1 EQ 5)*20 + b2)*b3
    file = 'E:\paddy_extr\test\veritify\Hants_18_39_DE2_8_H28v06_Yan_Paddy'
    Outdata = EnviRaster(data, URI=file, SPATIALREF=SPATIALREF)
    outdata.SAVE
  ENDIF
  ;读取运算后的数据
  IF 0 THEN BEGIN
    ;file = 'E:\paddy_extr\test\veritify\SG37_all_Yan_Paddy'
    file = 'E:\paddy_extr\test\veritify\Hants_18_38_DE4_all_Yan_Paddy'
    Raster = e.OPENRASTER(file)
    data = raster.GETDATA()
  ENDIF
  ;  file = 'E:\paddy_extr\test\JXTestHants2010.dat'
  ;  evir = e.openRaster(file)
  ;  evi = evir.getdata()

  Percent = FREQ(data)


  ;非0像元个数
  all = n_elements(data)-percent[1,0]
  inper = !NULL
  FOR i=1, n_elements(Percent[0,*])-1 DO BEGIN
    n=Percent[1,i]
    inper = [[inper],[Percent[0,i], n, float(n)*100.0/float(all)]]
  ENDFOR
  ;分类正确的像元个数及比例
  ;所有像元
  nuacc = total(percent[1,where((percent[0,*] EQ 11)  OR (percent[0,*] EQ 22) OR (percent[0,*] EQ 33))])
  Accur = total(percent[2,where((percent[0,*] EQ 11)  OR (percent[0,*] EQ 22) OR (percent[0,*] EQ 33))])
  Percent = [[Percent],[99,nuacc,Accur]]
  ;非0像元
  nuacc = total(inper[1,where((inper[0,*] EQ 11) OR (inper[0,*] EQ 22) OR (inper[0,*] EQ 33))])
  Accur = total(inper[2,where((inper[0,*] EQ 11) OR (inper[0,*] EQ 22) OR (inper[0,*] EQ 33))])
  inper = [[inper],[99,nuacc,Accur]]

  ;输出及显示
  outfile = file + '_accu.txt'
  openw,lun,outfile,/GET_LUN
  printf,lun,'所有像元'
  PRINTF,lun, '类别','个数','占比', format= '(3a10)'
  PRINTF,lun,Percent,format= '(3f9.3)'
  printf,lun,'---------------------------'
  printf,lun,'仅水稻像元内'
  PRINTF,lun, '类别','个数','占比', format= '(3a10)'
  PRINTF,lun,inper,format= '(3f9.3)'
  printf,lun, '注：99为整体精度'
  free_lun, lun

  NumPer = percent.DIM
  tlb = WIDGET_BASE(title='提取精度验证', $
    /Column, $
    /TLB_SIZE_EVENTS , $
    uname='wtlb' )

  table1 = WIDGET_TABLE(tlb, $
    uName  = 'table1', $
    COLUMN_LABELS = ['类别','个数','占比'], $
    xsize = NumPer[0], ysize = NumPer[1] , $
    /All_Events)

  table2 = WIDGET_TABLE(tlb, $
    /DISJOINT_SELECTION, $
    COLUMN_LABELS = ['类别','个数','占比'], $
    xsize = NumPer[0], ysize = NumPer[1], $
    uName  = 'table2')

  WIDGET_CONTROL,tlb,/realize
  CENTERTLB,tlb
  WIDGET_CONTROL, table1, set_value = Percent
  WIDGET_CONTROL, table2, set_value = inper

  ;查找特定位置，调试用
  Loc = where(data EQ 21,n)
  colu = data.DIM
  xx = COLROWNUM(loc,colu[0])
  print,xx[*,0:5], xx[*,1110:1115]
  print, inper

  ok = dialog_message('结束',/INFORMATION)
  e.CLOSE
END