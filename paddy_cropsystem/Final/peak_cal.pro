;+
; :DESCRIPTION:
;    ��������ͼ�������.
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
  ;���㲨������
  COMPILE_OPT idl2
  starttime = SYSTIME(1)

  ;��������
  LTranstart = 23 ;�����Կ�ʼ��
  LTransend  = 30 ;�����Խ�����
  stdate=18 ;������ܿ�ʼ����
  endate=39 ;������ܽ�������
  ThreValue = 3300 ;3000 ;30 ;��С��ֵ
  intervaL = 8 ; ������
  DecTrend = 2 ;���ּ�����Ч����

  ;�����ļ�·��
  ;
  ;input='E:\paddy_extr\test\2014evi\'
  ;output = 'E:\paddy_extr\test\2014evi\szresult'
  ;input='E:\paddy_extr\test\2010'
  ;output = 'E:\paddy_extr\test\2010'
  ;input = 'E:\jim\HantsInput\360_180_120_90BSQ'
  ;input = 'E:\jim\HantsInput\360_180_120_90BSQ_2010test'
  input = 'E:\jim\HantsInput\46_23_15_12\46_23_15_12BSQ'
  output = 'E:\jim\HantsInput\46_23_15_12\46_23_15_12SZRESULT'
  IF ~obj_valid(e) THEN e = ENVI(/headless);��һ���ж϶����Ƿ���ڵ���䣬������������

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

    ;���β�ַ�
    peak = MAKE_ARRAY(ns,nl,nb,/INTEGER,value=0);�洢��ֽ��
    per = 100.0/(ns*nl)
    jdt = WIDGET_BASE(xsize=200,ysize=200)
    WIDGET_CONTROL,jdt,/Realize
    prsbar = IDLITWDPROGRESSBAR( GROUP_LEADER = jdt, $
      title ='���β�ֽ���'+STRCOMPRESS(STRING(nn+1),/REMOVE_ALL))
    IDLITWDPROGRESSBAR_SETVALUE, prsbar, 0
    FOR i = 0, ns-1 DO BEGIN
      FOR j = 0, nl-1 DO BEGIN
        ; !NULL = WHERE((evi[i,j,*] EQ -9999) or (evi[i,j,*] EQ 0),n)
        ;�жϼ�¼�ǲ���ȫ��ȣ���ȵĻ��Ͳ����в�ּ��㣬������µ�whileѭ���ܲ���
        n = N_ELEMENTS(FREQ(evi[i,j,*]))
        IF (n EQ 3) THEN CONTINUE
        ts = TS_DIFF(REFORM(evi[i,j,*],nb),1) ;һ�ײ��,reformΪ������κ���
        ts1 = (ts GT 0)*(-1) + (ts LT 0)*(1);����0��Ϊ-1��С��0��Ϊ1
        peq = WHERE(ts1[1:nb-2] EQ 0,n);����ֵ��ͬ��λ��
        ;IF (n NE 0)  THEN PRINT,i,j,peq
        WHILE (n NE 0) DO BEGIN
          ;�����һ��evi���ڵڶ�EVI ���ڵ�����EVI �� ��һ���ڶ���������Ϊ0��
          ;��ȡ�����ֵ���������ǰֵ
          IF ((peq[0] EQ 0) AND (ts1[0] EQ 0)) THEN $
            ts1[peq+1] = ts1[peq+2] ELSE  ts1[peq+1] = ts1[peq]
          peq = WHERE(ts1[1:nb-2] EQ 0,n)
        ENDWHILE
        ts2 = TS_DIFF(ts1,1) ; ���β�֡�-2 Ϊ���� 2 Ϊ���壬����λ����ǰ1λ��������
        ;����λ��
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

    ;����ѡ��
    PRINT,"�ںϲ���"
    jdt = WIDGET_BASE(xsize=200,ysize=200)
    WIDGET_CONTROL,jdt,/Realize
    prsbar = IDLITWDPROGRESSBAR(GROUP_LEADER = jdt, $
      title ='�������'+STRCOMPRESS(STRING(nn+1),/REMOVE_ALL))
    IDLITWDPROGRESSBAR_SETVALUE, prsbar, 0
    FOR i=0, ns-1 DO BEGIN
      FOR j=0, nl-1 DO BEGIN
        ;PRINT,j
        sb = WHERE(peak[i,j,*] EQ 2,n) ; ��ȡ������������
        IF sb[0] EQ (-1) THEN CONTINUE

        ;�½������ж�
        npl = !NULL
        FOR k=0, n-1 DO BEGIN
          s = (sb[k] - DecTrend) > 0
          en = (sb[k] + DecTrend) < (nb-1)
          !NULL = WHERE(peak[i,j,s:en] NE 0, xjgs);��0�½�����
          IF xjgs GT 1 THEN npl = [npl,sb[k]]
        ENDFOR
        peak[i,j,npl] = 0

        ;���ֵ�϶��ǲ���
        max = MAX(evi[i,j,*],sbmx,/nan)
        peak[i,j,sbmx] = 2
        PeakLoc = sbmx
        ;����ж�
        sb = WHERE(peak[i,j,*] EQ 2)
        SbOut = WHERE((sb GE (sbmx+interval)) OR $
          (sb LE (sbmx-interval)),n)
        sbt = sb[SbOut]
        k = n
        WHILE (n NE 0) DO BEGIN
          ;PRINT,k--
          max = MAX(evi[i,j,sbt],sbmx,/nan)
          PeakLoc = [PeakLoc,sbt[sbmx]];����λ��
          SbOut = WHERE((sbt GE (sbt[sbmx]+interval)) OR $
            (sbt LE (Sbt[sbmx]-interval)),n)
          sbt = sbt[sbout]
        ENDWHILE
        peak[i,j,sb] = 0 ;ǰ��8���ڵĲ���Ϊ0�������ֵ��
        peak[i,j,PeakLoc] = 2 ;ǰ��8�����ֵΪ����
        jd = (i*ns + (j+1))*per
        IDLITWDPROGRESSBAR_SETVALUE,prsbar, jd
      ENDFOR
    ENDFOR
    ; ��ֵ�ж�
    loc = where(Peak EQ 2)
    Peak[loc] = (evi[loc] GE ThreValue) * Peak[loc]
    WIDGET_CONTROL,prsbar,/Destroy
    WIDGET_CONTROL,jdt, /Destroy
    PRINT,'ok'


    evi = !NULL
    num_peak = INTARR(ns,nl)

    ;���㲨�����
    jdt = WIDGET_BASE(xsize=200,ysize=200)
    WIDGET_CONTROL,jdt,/Realize
    prsbar = IDLITWDPROGRESSBAR(GROUP_LEADER = jdt, $
      title ='���㲨�����'+STRCOMPRESS(STRING(nn+1),/REMOVE_ALL))
    IDLITWDPROGRESSBAR_SETVALUE, prsbar, 0
    FOR i = 0, ns-1 DO BEGIN
      FOR j = 0, nl-1 DO BEGIN
        pp = WHERE(peak[i,j,*] EQ 2, num)
        ;��һ��ʱ���ڵĲ�����㲨��
        a = WHERE((pp GE (stdate-1)) $
          AND (pp LE (endate -1)),num)
        ;�޶�������ʱ�䣬�Ӷ����ƴ����˫����
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

    ;����ļ�
    ;�������кź������Ϊ�ļ�����������,������
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
  print,'PeakCal Finished,��ʱ'+proctime.COMPRESS()+'����!'
  ;OK = DIALOG_MESSAGE('�����,��ʱ'+proctime.COMPRESS()+'����!',/INFORMATION)
END
