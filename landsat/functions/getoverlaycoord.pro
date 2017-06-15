;获取重叠区的角点
;输入多光谱和全色文件，返回重叠区角点

PRO GetOverlayCoord, coordPan, coordMul, OverlayCoord
  ;
  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 3 THEN RETURN
  
  ;  GetFourCoor, pan, coordPan
  ;  GetFourCoor, mul, coordMul
  ;  PRINT, coordPan
  ;  PRINT, ''
  ;  PRINT, coordMul
  ;  PRINT, ''
  ;计算左上角
  ;  CAL2LINESINTERSECTPOINT, L1Start, L1End, L2Start, L2End
  L1Start = coordPan[*,0]
  L1End = coordPan[*,1]
  L2Start = coordMul[*,0]
  L2End = coordMul[*,3]
  Point1 = CAL2LINESINTERSECTPOINT(L1Start, L1End, L2Start, L2End)
  L1Start = coordPan[*,0]
  L1End = coordPan[*,3]
  L2Start = coordMul[*,0]
  L2End = coordMul[*,1]
  Point2 = CAL2LINESINTERSECTPOINT(L1Start, L1End, L2Start, L2End)
  Point3 = coordPan[*,0]
  Point4 = coordMul[*,0]
  ;选出Point四个点中右下角的点，即Y最小
  Tmp = [[Point1],[Point2],[Point3],[Point4]]
  idx = (SORT(tmp[1,*]))[0]
;  Tmp = double_sort(Tmp,1,2)
  leftup = Tmp[*,idx]
  
  ;计算右上角
  L1Start = coordPan[*,0]
  L1End = coordPan[*,1]
  L2Start = coordMul[*,1]
  L2End = coordMul[*,2]
  Point1 = CAL2LINESINTERSECTPOINT(L1Start, L1End, L2Start, L2End)
  L1Start = coordPan[*,1]
  L1End = coordPan[*,2]
  L2Start = coordMul[*,0]
  L2End = coordMul[*,1]
  Point2 = CAL2LINESINTERSECTPOINT(L1Start, L1End, L2Start, L2End)
  Point3 = coordPan[*,1]
  Point4 = coordMul[*,1]
  ;选出Point四个点中左下角的点，即X最小
  Tmp = [[Point1],[Point2],[Point3],[Point4]]
  idx = (SORT(tmp[0,*]))[0]
;  Tmp = double_sort(Tmp,0,0)
  rightup = tmp[*,idx]
  
  ;计算右下角
  L1Start = coordPan[*,1]
  L1End = coordPan[*,2]
  L2Start = coordMul[*,2]
  L2End = coordMul[*,3]
  Point1 = CAL2LINESINTERSECTPOINT(L1Start, L1End, L2Start, L2End)
  L1Start = coordPan[*,2]
  L1End = coordPan[*,3]
  L2Start = coordMul[*,1]
  L2End = coordMul[*,2]
  Point2 = CAL2LINESINTERSECTPOINT(L1Start, L1End, L2Start, L2End)
  Point3 = coordPan[*,2]
  Point4 = coordMul[*,2]
  ;选出Point四个点中左下角的点，即Y最大
  Tmp = [[Point1],[Point2],[Point3],[Point4]]
  idx = (SORT(tmp[1,*]))[-1]
;  tmp = double_sort(tmp,1,3)
  rightdown = tmp[*,idx]
  
  
  ;计算左下角
  L1Start = coordPan[*,0]
  L1End = coordPan[*,3]
  L2Start = coordMul[*,2]
  L2End = coordMul[*,3]
  Point1 = CAL2LINESINTERSECTPOINT(L1Start, L1End, L2Start, L2End)
  L1Start = coordPan[*,2]
  L1End = coordPan[*,3]
  L2Start = coordMul[*,0]
  L2End = coordMul[*,3]
  Point2 = CAL2LINESINTERSECTPOINT(L1Start, L1End, L2Start, L2End)
  Point3 = coordPan[*,3]
  Point4 = coordMul[*,3]
  ;选出Point四个点中左下角的点，即X最大
  Tmp = [[Point1],[Point2],[Point3],[Point4]]
  idx = (SORT(tmp[0,*]))[-1]
;  tmp = double_sort(tmp,0,1)
  leftdown = tmp[*,idx]
  
  OverlayCoord = [[leftup],[rightup],[rightdown],[leftdown]]
  
END