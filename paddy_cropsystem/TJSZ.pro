;+
; :DESCRIPTION:
;    Describe the procedure.
;
;
; :AUTHOR: chiangmin
;-
PRO TJSZ
  COMPILE_OPT IDL2
  e = ENVI(/headless)
  indir = 'E:\paddy_extr\Processing\SZFinal\360I180SZPaddy'
  files = FILE_SEARCH(indir,'*.dat',count=n,/TEST_REGULAR)
  ProvBou = 'E:\paddy_extr\base\provical_boundary\dat'
  Provfiles = FILE_SEARCH(ProvBou,'*.dat',count = m, /TEST_REGULAR)
  SZ = !NULL
  insz = !NULL
  fgs = !NULL ;非水稻个数
  sgs = !NULL ; 单季稻个数
  dgs = !NULL ; 双季稻个数
  raster = e.OpenRaster(files[0])
  nrows = raster.NROWS
  ncolumns = raster.NCOLUMNS
  data = make_array(NCOLUMNS, NROWS, n,/BYTE)

  FOR i=0, n-1 DO BEGIN
    raster= e.OpenRaster(files[i])
    data[*,*,i] = raster.getdata()
  ENDFOR

  FOR i=0, ncolumns-1 DO BEGIN
    FOR j=0, nrows-1 DO BEGIN
      IF total(data[i,j,*]) EQ 0 THEN data[i,j,*] = 10
    ENDFOR
  ENDFOR

  ;3熟算两熟
  data[where(data EQ 3)]= 2

  FOR i=0, n-1 DO BEGIN
    ;统计所有
    stats = freq(data[*,*,i])
    num = stats[1,0:2];每类的个数

    ;仅统计水稻掩模范围内的个数及比例
    statsin = [stats[0,0:2], $
      ROTATE([total(stats[1,0:2]), $
      total(stats[1,0:2]), $
      total(stats[1,0:2])],1), $
      stats[1,0:2],stats[1,0:2]*100.0/total(stats[1,0:2])]

    print,statsin

    ;分省统计
    FOR j=0, m-1 DO BEGIN
      ProvRaster = e.OpenRaster(Provfiles[j])
      ProvData = ProvRaster.getdata()
      provin = (provdata EQ 0)*(provdata*data[*,*,i] + 10)+ $
        (provdata EQ 1)*provdata*data[*,*,i]
      ProvStats = freq(provin)
      num = [num ,ProvStats[1,0:2]]
    ENDFOR
    ;合并为数组
    fgs = [[fgs],[num[*,0]]]
    sgs = [[sgs],[num[*,1]]]
    dgs = [[dgs],[num[*,2]]]
    sz =[[sz],[stats]]
    insz = [[insz],[statsin]]
    ;data =!NULL
  ENDFOR
  data = !NULL
  ;变为三维数组
  gs = LONG([[indgen(1,13)+2002 ,fgs],[indgen(1,13)+2002 ,sgs],[indgen(1,13)+2002,dgs]])
  ;gs = [gs[[
  openw,lun, $
    'E:\paddy_extr\Processing\SZFinal\Analysis\360I180SZPaddy(012).txt',/get_lun
  printf,lun,' 研究区  安徽  福建  广东 广西  湖北 湖南 江西  浙江'
  printf,lun,gs,format='(10I8)'
  free_lun,lun


  plot1 = plot(gs[0,0,*],'r2', NAME='研究区')
  plot2 = plot(gs[1,0,*],/OVERPLOT,'r3', NAME='研究区')
  ; Display the first plot.
  plot1 = PLOT(observed, 'b2', NAME='Observed')

  ; Display the second plot.
  plot2 = PLOT(theory, /OVERPLOT, 'r2', NAME='Theory')

  ; Add the legend.
  leg = LEGEND(TARGET=[plot1,plot2], POSITION=[185,0.9], $
    /DATA, /AUTO_TEXT_COLOR)

  sz =reform(sz,3,3,13)
  insz = reform(insz,4,2,13)


  ;plot(gs[0,*,*],
  ;plot(insz[3,1,*])
  ;plot(insz[2,1,*])
  ;print,i
  e.close

END


;[stats[0,1:2],ROTATE([total(stats[1,1:2]), total(stats[1,1:2])],1),  stats[1,1:2],stats[1,1:2]*100.0/total(stats[1,1:2])]
;ENVI> b[*,*,0]
;0.00000000       12812313.       92.171722
;1.0000000       818533.00       5.8885221
;2.0000000       268407.00       1.9309187
;3.0000000       1229.0000    0.0088414196
;ENVI> b[*,*,1]
;0.00000000       12814221.       92.185440
;1.0000000       797369.00       5.7362685
;2.0000000       288417.00       2.0748706
;3.0000000       475.00000    0.0034171478
;ENVI> b[*,*,3]
;0.00000000       12809787.       92.153542
;1.0000000       718149.00       5.1663599
;2.0000000       370947.00       2.6685910
;3.0000000       1599.0000     0.011503198