;��ȡ�ص����Ľǵ�
;�������׺�ȫɫ�ļ��������ص����ǵ�

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
  ;�������Ͻ�
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
  ;ѡ��Point�ĸ��������½ǵĵ㣬��Y��С
  Tmp = [[Point1],[Point2],[Point3],[Point4]]
  idx = (SORT(tmp[1,*]))[0]
;  Tmp = double_sort(Tmp,1,2)
  leftup = Tmp[*,idx]
  
  ;�������Ͻ�
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
  ;ѡ��Point�ĸ��������½ǵĵ㣬��X��С
  Tmp = [[Point1],[Point2],[Point3],[Point4]]
  idx = (SORT(tmp[0,*]))[0]
;  Tmp = double_sort(Tmp,0,0)
  rightup = tmp[*,idx]
  
  ;�������½�
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
  ;ѡ��Point�ĸ��������½ǵĵ㣬��Y���
  Tmp = [[Point1],[Point2],[Point3],[Point4]]
  idx = (SORT(tmp[1,*]))[-1]
;  tmp = double_sort(tmp,1,3)
  rightdown = tmp[*,idx]
  
  
  ;�������½�
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
  ;ѡ��Point�ĸ��������½ǵĵ㣬��X���
  Tmp = [[Point1],[Point2],[Point3],[Point4]]
  idx = (SORT(tmp[0,*]))[-1]
;  tmp = double_sort(tmp,0,1)
  leftdown = tmp[*,idx]
  
  OverlayCoord = [[leftup],[rightup],[rightdown],[leftdown]]
  
END