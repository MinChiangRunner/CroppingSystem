PRO BATCH_PEAK_CAL
  COMPILE_OPT idl2
  ;设置批量参数
  starttime = SYSTIME(1)
  ;e = envi(/headless)

  paras = [[18,38,3300,8,2],[18,38,3300,8,3], $
    [18,38,3300,8,4],[18,38,3300,8,3],[18,38,3300,10,3],$
    [18,38,3500,8,2],[18,39,3500,8,3],[18,39,3500,10,3],[18,39,3300,10,2]]
  n=9
  input = 'E:\paddy_extr\Processing\EVI\HEVI_INTER_Hants2010.dat'
  postfix = '_Hants.dat'
  output = 'E:\paddy_extr\Processing\RawResult\'
  FOR i = 0, n-1 DO BEGIN
    PEAK_CAL,stdate=paras[0,i], $
      endate=paras[1,i], input=input, $
      output=output, ThreValue=paras[2,i], $
      postfix=postfix, interval=paras[3,i], DecTrend=paras[4,i]
  ENDFOR
  ;e.CLOSE
  proctime = STRING(ROUND((SYSTIME(1) - starttime )/60.0))
  OK = DIALOG_MESSAGE('完成了,用时'+proctime.COMPRESS()+'分钟!',/INFORMATION)
END