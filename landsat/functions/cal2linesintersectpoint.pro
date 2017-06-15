;≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌
;
;求集合的并集
; copy From DAVID's Code  ^_^
;
FUNCTION SETUNION, a, b
  ;
  COMPILE_OPT StrictArr
  IF N_ELEMENTS(a) EQ 0 THEN RETURN, b    ;A union NULL = a
  IF N_ELEMENTS(b) EQ 0 THEN RETURN, a    ;B union NULL = b
  RETURN, WHERE(HISTOGRAM([a,b], OMin = omin)) + omin ; Return combined set
END

;≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌
;
;
;去除2维数组中重复的元素
;
; 2010年3月25日
; Write By DYQ
;
FUNCTION UNIQARRAY, inArray
  ;
  num = N_ELEMENTS(inArray[0,*])
  xArray = REFORM(inArray[0,*])
  yArray = REFORM(inArray[1,*])
  ;
  xUniq = UNIQ(xArray(SORT(xArray)))
  yUniq = UNIQ(yArray(SORT(yArray)))
  ;
  RETURN, inArray[*,SETUNION(xUniq,yUniq)]

END

;≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌
;
;计算两个点的距离,XY水平面
;
; 2008-4-28
; Write By DYQ
;其实可以用 DISTANCE_MEASURE 函数，没办法，写好了才发现IDL自带o(∩_∩)o
;
FUNCTION CALDISTANCE, point1, point2
  ;
  point1 = point1*1.
  point2 = point2*1.
  RETURN, SQRT((point1[0]-point2[0])^2+(point1[1]-point2[1])^2)
END

;≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌
;
;计算点到直线的距离
;
;Write By DYQ
;其实可以用 PNT_LINE 函数，没办法，写好了才发现IDL自带o(∩_∩)o
;
FUNCTION CALDISTANCEPTOLINE, point0,linePos1,linePos2

  a = CALDISTANCE(point0,linePos1)
  b = CALDISTANCE(point0,linePos2);SQRT((point[0]-linePos2[0])^2+(point[1]-linePos2[1])^2)

  c = CALDISTANCE(linePos1,linePos2);SQRT((linePos2[0]-linePos1[0])^2+(linePos2[1]-linePos1[1])^2)

  p = (a+b+c)*0.5
  s = SQRT(p*(p-a)*(p-b)*(p-c))

  RETURN, s*2/c
END


;≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌
;
;计算两直线的交点
;2008-9-27
;Write By DYQ
;
; 输入
; P1:直线1的起点坐标--- P2:直线1的终点坐标
; P1S:直线2的起点坐标--- P2S:直线2的终y点坐标
; 相交则返回交点，不相交则返回-1
; Modified By DYQ
; 2008-10-29 --增加了p1、p2及P1S、P2S重合的判断
;Example:
;   直线: [-1,-1],[1,1]
;   直线：[1,0],[0,1]
;   point = Cal2linesintersectpoint([-1,-1],[1,1],[1,0],[0,1])

FUNCTION CAL2LINESINTERSECTPOINT, P1,P2,P1S,P2S
  ;
  COMPILE_OPT IDL2
  ;如果线1点重合了
  IF ARRAY_EQUAL(P1, P2) THEN BEGIN
    IF ARRAY_EQUAL(P1S, P2S ) THEN BEGIN
      IF P1 EQ P2 THEN RETURN,P1
      RETURN, -1
    ENDIF ELSE BEGIN
      IF CALDISTANCEPTOLINE(P1,P1S,P2S) EQ 0 THEN RETURN, P1
      RETURN,-1
    ENDELSE
  ;线1的点不重合
  ENDIF ELSE BEGIN
    IF ARRAY_EQUAL(P1S ,P2S) THEN BEGIN
      RETURN, P1S
    ENDIF ELSE BEGIN
      ;如果第一条直线垂直x轴
      IF (P1[0]-P2[0]) EQ 0 THEN BEGIN
        ipX = p1[0];
        ;第二条也垂直
        IF (P1S[0]-P2S[0]) EQ 0 THEN BEGIN
          ;不相交
          RETURN, -1
        ENDIF ELSE BEGIN
          ;
          k2 = FLOAT(P1S[1]-P2S[1])/(P1S[0]-P2S[0])
          b2 = FLOAT(P1S[0]*P2S[1]-P2S[0]*P1S[1])/(P1S[0]-P2S[0])
          ;
          ipY = k2*ipX+b2
          RETURN,[ipX,ipY]
        ENDELSE
      ;第二条直线垂直X轴
      ENDIF ELSE IF (P1S[0]-P2S[0]) EQ 0 THEN BEGIN
        ipX = p2s[0];
        k1 = FLOAT(P1[1]-P2[1])/(P1[0]-P2[0])
        b1 = FLOAT(P1[0]*P2[1]-P2[0]*P1[1])/(P1[0]-P2[0])
        ipY = k1*ipX+b1
        RETURN,[ipX,ipY]

      ;都不垂直
      ENDIF ELSE BEGIN
        k1 = FLOAT(P1[1]-P2[1])/(P1[0]-P2[0])
        b1 = FLOAT(P1[0]*P2[1]-P2[0]*P1[1])/(P1[0]-P2[0])
        ;
        k2 = FLOAT(P1S[1]-P2S[1])/(P1S[0]-P2S[0])
        b2 = FLOAT(P1S[0]*P2S[1]-P2S[0]*P1S[1])/(P1S[0]-P2S[0])
        ;如果都垂直Y轴
        IF (K2 EQ 0) AND(K1 EQ 0) THEN RETURN,-1
        ipX = (b2-b1)/(k1-k2)
        ipY = (k1*b2-k2*b1)/(k1-k2)
        RETURN,[ipX,ipY]
      ENDELSE
    ENDELSE
  ENDELSE
;
END

;≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌
;
;
;计算平面上直线是否与多边形相交，有交点可返回
;2010年3月25日
; Write By DYQ
;
;调用格式result = CalLineInPolygon(linePoints, polyPoints) ;
;LinePoints: 两个点的二维坐标[2,2]，否则返回-1;
;PolyPoints: 多边形点的二维坐标[2,n]，否则返回-1
;
FUNCTION CALLINEINPOLYGON, linePoints, polyPoints
  COMPILE_OPT idl2
  ;
  IF ARRAY_EQUAL(SIZE(inPoints,/dimension), [2,2]) THEN RETURN,-1
  ;点个数
  pointNum = (SIZE(polyPoints,/dimension))[1]
  ;相交标识
  sign = -1
  ipoints = [0,0]
  ;循环求解
  FOR i=0, pointNum -1 DO BEGIN
    ;
    point = CAL2LINESINTERSECTPOINT(linePoints[*,0], $
      linePoints[*,1], polyPoints[*,i],polyPoints[*,(i+1) MOD pointNum])
    IF N_ELEMENTS(point) GT 1 THEN BEGIN
      ipoints = [[iPoints],[REFORM(point)]]
      sign = 1
    ENDIF
  ENDFOR
  ;
  IF sign EQ -1 THEN RETURN, sign $
  ELSE result = UNIQARRAY(iPoints[*,1:N_ELEMENTS(iPoints[0,*])-1])
  ;判断交点是否在多边形内
  ;
  oROI = OBJ_NEW('IDLanROI', polyPoints)

  conArr = [0,0]
  FOR i=0, N_ELEMENTS(result)/2-1 DO BEGIN
    ;
    psign= oROI->CONTAINSPOINTS(result[*,i])
    ;有在多边形内的点
    IF psign NE 0 THEN BEGIN
      conArr = [[conArr], [result[*,i]]]
    ENDIF
  ENDFOR
  OBJ_DESTROY,oROI
  ;
  IF N_ELEMENTS(conArr)/2 EQ 1 THEN RETURN, -1 ELSE RETURN,conArr[*,1:N_ELEMENTS(conArr)/2-1]
END
;
;≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌≌
;
;测试程序

PRO TEST
  ;
  ;  restore,'C:\Users\Administrator\Desktop GridNum,format="(I07)"LineInPolygon.sav'
  linePoints = [[0,0],[2,1]]
  polyPoints = [[1,1],[2,1],[3,2],[4,1]]
  points = CALLINEINPOLYGON(linePoints, polyPoints)

  PRINT,points
END
;




