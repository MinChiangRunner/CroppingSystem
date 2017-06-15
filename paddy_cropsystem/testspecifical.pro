;+
; :DESCRIPTION:
;    测试加特定移栽期的程序和精度结果。
;
; :AUTHOR: chiangmin
;-
PRO TestSpecifical
  e = envi()
  file = 'E:\paddy_extr\Processing\RawResult\locpeak_18_39_DE2_8_T33_180I.dat'
  stdate=18
  endate=39
  ThreValue = 3300 ;3000 ;30
  intervaL = 8
  DecTrend = 2

  jdt = WIDGET_BASE(xsize=200,ysize=200)
  WIDGET_CONTROL,jdt,/Realize
  prsbar = IDLITWDPROGRESSBAR(GROUP_LEADER = jdt,title ='计算波峰个数')
  IDLITWDPROGRESSBAR_SETVALUE, prsbar, 0
  PeakRaster = e.OpenRaster(file)
  peak = PeakRaster.GetData()
  SPATIALREF = PeakRaster.SPATIALREF
  dim = peak.DIM
  ns = DIM[0]
  nl = DIM[1]
  nb = DIM[2]
  per = 100.0/(ns*nl)
  num_peak = intarr(ns,nl)
  FOR i = 0, ns-1 DO BEGIN
    FOR j = 0, nl-1 DO BEGIN
      pp = WHERE(peak[i,j,*] EQ 2, num)
      IF pp[0] EQ (-1) THEN CONTINUE
      ;在一定时期内的波峰才算波峰
      a = WHERE((pp GE (stdate-1)) $
        AND (pp LE (endate -1)),num)
      ;限定晚稻移栽时间，从而控制错误的双季稻
      IF ~((num EQ 1) OR (num EQ 0))  THEN BEGIN
        !NULL = min(peak[i,j,pp[a[0]]:pp[a[1]]],val)
        IF (((val+pp[a[0]]) LT (23-1)) OR  ((val+pp[a[0]]) GT (30-1))) THEN BEGIN
          num = 1
        ENDIF
      ENDIF
      num_peak[i,j] = num
      jd = (i*ns + (j+1))*per
      IDLITWDPROGRESSBAR_SETVALUE, prsbar, jd
    ENDFOR
  ENDFOR
  WIDGET_CONTROL,prsbar,/Destroy
  WIDGET_CONTROL,jdt, /Destroy

  ;输出文件
  postfix = '_SpecificPhon.dat';_Hants360I
  output = 'E:\paddy_extr\Processing\RawResult'
  fixn = STRING(stdate)+'_'+STRING(endate)+'_DE'+STRING(DecTrend)+ $
    '_'+STRING(interval)+ '_T' + STRING(ThreValue/100)
  out_name = output + PATH_SEP()+ 'numpeak_'+fixn.COMPRESS()+ postfix
  outraster = ENVIRASTER(num_peak, URI=out_name, SPATIALREF = spatialref)
  outraster.SAVE
  e.close

 
END









