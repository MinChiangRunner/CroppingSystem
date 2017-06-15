;+
; :DESCRIPTION:
;    批量计算图像的熟制.
; :KEYWORDS:
;    stdate
;    endate
;    input
;    output
;    ThreValueE:\jim\HantsInput\360_180_120_90BSQ
;    postfix
;    interval
;    DecTrend
;
; :AUTHOR: chiangmin
;-
PRO PEAK_CAL,stdate=stdate, $
  endate=endate, input=input, $
  output=output, ThreValue=ThreValue, $
  postfix=postfix, interval=interval, DecTrend=DecTrend
  ;计算波峰数量
  COMPILE_OPT idl2
  starttime = SYSTIME(1)

  ;参数设置
  LTranstart = 23 ;晚稻移栽开始期
  LTransend  = 30 ;晚稻移栽结束期
  stdate=18 ;波峰可能开始日期
  endate=39 ;波峰可能结束日期
  ThreValue = 3300 ;3000 ;30 ;最小阈值
  intervaL = 8 ; 两峰间隔
  DecTrend = 2 ;保持几个有效趋势

  ;设置文件路径
  ;
  ;input='E:\paddy_extr\test\2014evi\'
  ;output = 'E:\paddy_extr\test\2014evi\szresult'
  ;input='E:\paddy_extr\test\2010'
  ;output = 'E:\paddy_extr\test\2010'
  ;input = 'E:\jim\HantsInput\360_180_120_90BSQ'
  ;input = 'E:\jim\HantsInput\360_180_120_90BSQ_2010test'
  input = 'E:\jim\HantsInput\46_23_15_12\46_23_15_12BSQ'
  output = 'E:\jim\HantsInput\46_23_15_12\46_23_15_12SZRESULT'
  IF ~obj_valid(e) THEN e = ENVI(/headless);加一个判断对象是否存在的语句，便于批量程序

  Inputfiles = FILE_SEARCH(input,'*BSQ.dat',count=c)
  ;General error handler
  ;    CATCH, errorStatus
  ;    ; Error handler
  ;    IF (errorStatus NE 0) THEN BEGIN
  ;      CATCH, /CANCEL
  ;      ; TODO: Write error handler
  ;      IF OBJ_VALID(e) THEN $
  ;        e.REPORTERROR, 'ERROR: ' + !ERROR_STATE.MSG
  ;      MESSAGE, /RESET
  ;      RETURN
  ;    ENDIF

  ;input = 'E:\paddy_extr\test\JXTestSG37EVI.dat'
  ;input = 'E:\paddy_extr\Processing\EVI\HEVI_INTER_Hants2010.dat'
  ;input = 'E:\paddy_extr\test\HEVI2010215_2_psf_BSQ.dat'
  ;  raster = e.OPENRASTER(inputr)
  ;  Spatialref = raster.SPATIALREF
  ;  raster.CLOSE
  FOR nn = 0, c-1 DO BEGIN
    raster = e.OPENRASTER(Inputfiles[nn])
    Spatialref = raster.SPATIALREF
    evi = raster.GETDATA()

    dim = evi.DIM
    ns = DIM[0]
    nl = DIM[1]
    nb = DIM[2]

    ;二次差分法
    peak = MAKE_ARRAY(ns,nl,nb,/INTEGER,value=0);存储差分结果
    per = 100.0/(ns*nl)
    jdt = WIDGET_BASE(xsize=200,ysize=200)
    WIDGET_CONTROL,jdt,/Realize
    prsbar = IDLITWDPROGRESSBAR( GROUP_LEADER = jdt, $
      title ='二次差分进度'+STRCOMPRESS(STRING(nn+1),/REMOVE_ALL))
    IDLITWDPROGRESSBAR_SETVALUE, prsbar, 0
    FOR i = 0, ns-1 DO BEGIN
      FOR j = 0, nl-1 DO BEGIN
        ; !NULL = WHERE((evi[i,j,*] EQ -9999) or (evi[i,j,*] EQ 0),n)
        ;判断记录是不是全相等，相等的话就不进行差分计算，否则地下的while循环跑不完
        n = N_ELEMENTS(FREQ(evi[i,j,*]))
        IF (n EQ 3) THEN CONTINUE
        ts = TS_DIFF(REFORM(evi[i,j,*],nb),1) ;一阶差分,reform为数组变形函数
        ts1 = (ts GT 0)*(-1) + (ts LT 0)*(1);大于0的为-1，小于0的为1
        peq = WHERE(ts1[1:nb-2] EQ 0,n);波峰值相同的位置
        ;IF (n NE 0)  THEN PRINT,i,j,peq
        WHILE (n NE 0) DO BEGIN
          ;如果第一个evi等于第二EVI 等于第三个EVI 即 第一个第二第三个都为0，
          ;则取后面的值，否则等于前值
          IF ((peq[0] EQ 0) AND (ts1[0] EQ 0)) THEN $
            ts1[peq+1] = ts1[peq+2] ELSE  ts1[peq+1] = ts1[peq]
          peq = WHERE(ts1[1:nb-2] EQ 0,n)
        ENDWHILE
        ts2 = TS_DIFF(ts1,1) ; 二次差分。-2 为波谷 2 为波峰，但是位置提前1位，需修正
        ;修正位置
        peak[i,j,WHERE(ts2 EQ 0)+1] = 0
        peak[i,j,WHERE(ts2 EQ 1)+1] = 1
        peak[i,j,WHERE(ts2 EQ 2)+1] = 2
        peak[i,j,WHERE(ts2 EQ -1)+1] = -1
        peak[i,j,WHERE(ts2 EQ -2)+1] = -2
        peak[i,j,[0,nb-1]] = 0
        jd = (i*ns + (j+1))*per
        IDLITWDPROGRESSBAR_SETVALUE, prsbar, jd
      ENDFOR
    ENDFOR
    WIDGET_CONTROL,prsbar,/Destroy
    WIDGET_CONTROL,jdt, /Destroy
    ;  stdate = 14
    ;  endate = 35
    ;  peak[*,*,0:(stdate-2)] = 0
    ;  peak[*,*,endate:(nb-1)] = 0

    ;波峰选择
    PRINT,"融合波峰"
    jdt = WIDGET_BASE(xsize=200,ysize=200)
    WIDGET_CONTROL,jdt,/Realize
    prsbar = IDLITWDPROGRESSBAR(GROUP_LEADER = jdt, $
      title ='波峰进度'+STRCOMPRESS(STRING(nn+1),/REMOVE_ALL))
    IDLITWDPROGRESSBAR_SETVALUE, prsbar, 0
    FOR i=0, ns-1 DO BEGIN
      FOR j=0, nl-1 DO BEGIN
        ;PRINT,j
        sb = WHERE(peak[i,j,*] EQ 2,n) ; 获取波峰索引向量
        IF sb[0] EQ (-1) THEN CONTINUE

        ;下降趋势判断
        npl = !NULL
        FOR k=0, n-1 DO BEGIN
          s = (sb[k] - DecTrend) > 0
          en = (sb[k] + DecTrend) < (nb-1)
          !NULL = WHERE(peak[i,j,s:en] NE 0, xjgs);非0下降个数
          IF xjgs GT 1 THEN npl = [npl,sb[k]]
        ENDFOR
        peak[i,j,npl] = 0

        ;最大值肯定是波峰
        max = MAX(evi[i,j,*],sbmx,/nan)
        peak[i,j,sbmx] = 2
        PeakLoc = sbmx
        ;间隔判断
        sb = WHERE(peak[i,j,*] EQ 2)
        SbOut = WHERE((sb GE (sbmx+interval)) OR $
          (sb LE (sbmx-interval)),n)
        sbt = sb[SbOut]
        k = n
        WHILE (n NE 0) DO BEGIN
          ;PRINT,k--
          max = MAX(evi[i,j,sbt],sbmx,/nan)
          PeakLoc = [PeakLoc,sbt[sbmx]];波峰位置
          SbOut = WHERE((sbt GE (sbt[sbmx]+interval)) OR $
            (sbt LE (Sbt[sbmx]-interval)),n)
          sbt = sbt[sbout]
        ENDWHILE
        peak[i,j,sb] = 0 ;前后8期内的波峰为0，除最大值外
        peak[i,j,PeakLoc] = 2 ;前后8期最大值为波峰
        jd = (i*ns + (j+1))*per
        IDLITWDPROGRESSBAR_SETVALUE,prsbar, jd
      ENDFOR
    ENDFOR
    ; 阈值判断
    loc = where(Peak EQ 2)
    Peak[loc] = (evi[loc] GE ThreValue) * Peak[loc]
    WIDGET_CONTROL,prsbar,/Destroy
    WIDGET_CONTROL,jdt, /Destroy
    PRINT,'ok'


    evi = !NULL
    num_peak = INTARR(ns,nl)

    ;计算波峰个数
    jdt = WIDGET_BASE(xsize=200,ysize=200)
    WIDGET_CONTROL,jdt,/Realize
    prsbar = IDLITWDPROGRESSBAR(GROUP_LEADER = jdt, $
      title ='计算波峰个数'+STRCOMPRESS(STRING(nn+1),/REMOVE_ALL))
    IDLITWDPROGRESSBAR_SETVALUE, prsbar, 0
    FOR i = 0, ns-1 DO BEGIN
      FOR j = 0, nl-1 DO BEGIN
        pp = WHERE(peak[i,j,*] EQ 2, num)
        ;在一定时期内的波峰才算波峰
        a = WHERE((pp GE (stdate-1)) $
          AND (pp LE (endate -1)),num)
        ;限定晚稻移栽时间，从而控制错误的双季稻
        IF ~((num eq 1) OR (num eq 0))THEN BEGIN
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
    ;解析行列号和年份作为文件名加以区别,按年存放
    YearColRow =  file_basename(Inputfiles[nn])
    YearColRow =YearColRow.extract('[0-9]{4}h[0-9]{2}v[0-9]{2}')
    Year = YearColRow.extract('[0-9]{4}')
    outfile = output + path_sep() + year
    if ~FILE_TEST(outfile) then FILE_MKDIR, outfile
    
    ;
    postfix = '.dat';_Hants360I
    ;  output = 'E:\paddy_extr\Processing\RawResult\'
    fixn = YearColRow + STRING(stdate)+'_'+STRING(endate)+'_DE'+STRING(DecTrend)+ $
      '_'+STRING(interval)+ '_T' + STRING(ThreValue/100)
    out_name = outfile + PATH_SEP()+'locpeak_'+fixn.COMPRESS()+ postfix;"E:\paddy_extr\index\peak_gt0.3.img"
    outraster = ENVIRASTER(peak, URI=out_name, SPATIALREF= spatialref);
    outraster.SAVE
    out_name = outfile + PATH_SEP()+ 'numpeak_'+fixn.COMPRESS()+ postfix
    outraster = ENVIRASTER(num_peak, URI=out_name,SPATIALREF = spatialref)
    outraster.SAVE
  ENDFOR
  e.CLOSE
  proctime = STRING(ROUND((SYSTIME(1) - starttime )/60.0))
  print,'PeakCal Finished,用时'+proctime.COMPRESS()+'分钟!'
  ;OK = DIALOG_MESSAGE('完成了,用时'+proctime.COMPRESS()+'分钟!',/INFORMATION)
END
