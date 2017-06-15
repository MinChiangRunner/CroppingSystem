;�աաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաա�
;
;�󼯺ϵĲ���
; copy From DAVID's Code  ^_^
;
FUNCTION SETUNION, a, b
  ;
  COMPILE_OPT StrictArr
  IF N_ELEMENTS(a) EQ 0 THEN RETURN, b    ;A union NULL = a
  IF N_ELEMENTS(b) EQ 0 THEN RETURN, a    ;B union NULL = b
  RETURN, WHERE(HISTOGRAM([a,b], OMin = omin)) + omin ; Return combined set
END

;�աաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաա�
;
;
;ȥ��2ά�������ظ���Ԫ��
;
; 2010��3��25��
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

;�աաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաա�
;
;����������ľ���,XYˮƽ��
;
; 2008-4-28
; Write By DYQ
;��ʵ������ DISTANCE_MEASURE ������û�취��д���˲ŷ���IDL�Դ�o(��_��)o
;
FUNCTION CALDISTANCE, point1, point2
  ;
  point1 = point1*1.
  point2 = point2*1.
  RETURN, SQRT((point1[0]-point2[0])^2+(point1[1]-point2[1])^2)
END

;�աաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաա�
;
;����㵽ֱ�ߵľ���
;
;Write By DYQ
;��ʵ������ PNT_LINE ������û�취��д���˲ŷ���IDL�Դ�o(��_��)o
;
FUNCTION CALDISTANCEPTOLINE, point0,linePos1,linePos2

  a = CALDISTANCE(point0,linePos1)
  b = CALDISTANCE(point0,linePos2);SQRT((point[0]-linePos2[0])^2+(point[1]-linePos2[1])^2)

  c = CALDISTANCE(linePos1,linePos2);SQRT((linePos2[0]-linePos1[0])^2+(linePos2[1]-linePos1[1])^2)

  p = (a+b+c)*0.5
  s = SQRT(p*(p-a)*(p-b)*(p-c))

  RETURN, s*2/c
END


;�աաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաա�
;
;������ֱ�ߵĽ���
;2008-9-27
;Write By DYQ
;
; ����
; P1:ֱ��1���������--- P2:ֱ��1���յ�����
; P1S:ֱ��2���������--- P2S:ֱ��2����y������
; �ཻ�򷵻ؽ��㣬���ཻ�򷵻�-1
; Modified By DYQ
; 2008-10-29 --������p1��p2��P1S��P2S�غϵ��ж�
;Example:
;   ֱ��: [-1,-1],[1,1]
;   ֱ�ߣ�[1,0],[0,1]
;   point = Cal2linesintersectpoint([-1,-1],[1,1],[1,0],[0,1])

FUNCTION CAL2LINESINTERSECTPOINT, P1,P2,P1S,P2S
  ;
  COMPILE_OPT IDL2
  ;�����1���غ���
  IF ARRAY_EQUAL(P1, P2) THEN BEGIN
    IF ARRAY_EQUAL(P1S, P2S ) THEN BEGIN
      IF P1 EQ P2 THEN RETURN,P1
      RETURN, -1
    ENDIF ELSE BEGIN
      IF CALDISTANCEPTOLINE(P1,P1S,P2S) EQ 0 THEN RETURN, P1
      RETURN,-1
    ENDELSE
  ;��1�ĵ㲻�غ�
  ENDIF ELSE BEGIN
    IF ARRAY_EQUAL(P1S ,P2S) THEN BEGIN
      RETURN, P1S
    ENDIF ELSE BEGIN
      ;�����һ��ֱ�ߴ�ֱx��
      IF (P1[0]-P2[0]) EQ 0 THEN BEGIN
        ipX = p1[0];
        ;�ڶ���Ҳ��ֱ
        IF (P1S[0]-P2S[0]) EQ 0 THEN BEGIN
          ;���ཻ
          RETURN, -1
        ENDIF ELSE BEGIN
          ;
          k2 = FLOAT(P1S[1]-P2S[1])/(P1S[0]-P2S[0])
          b2 = FLOAT(P1S[0]*P2S[1]-P2S[0]*P1S[1])/(P1S[0]-P2S[0])
          ;
          ipY = k2*ipX+b2
          RETURN,[ipX,ipY]
        ENDELSE
      ;�ڶ���ֱ�ߴ�ֱX��
      ENDIF ELSE IF (P1S[0]-P2S[0]) EQ 0 THEN BEGIN
        ipX = p2s[0];
        k1 = FLOAT(P1[1]-P2[1])/(P1[0]-P2[0])
        b1 = FLOAT(P1[0]*P2[1]-P2[0]*P1[1])/(P1[0]-P2[0])
        ipY = k1*ipX+b1
        RETURN,[ipX,ipY]

      ;������ֱ
      ENDIF ELSE BEGIN
        k1 = FLOAT(P1[1]-P2[1])/(P1[0]-P2[0])
        b1 = FLOAT(P1[0]*P2[1]-P2[0]*P1[1])/(P1[0]-P2[0])
        ;
        k2 = FLOAT(P1S[1]-P2S[1])/(P1S[0]-P2S[0])
        b2 = FLOAT(P1S[0]*P2S[1]-P2S[0]*P1S[1])/(P1S[0]-P2S[0])
        ;�������ֱY��
        IF (K2 EQ 0) AND(K1 EQ 0) THEN RETURN,-1
        ipX = (b2-b1)/(k1-k2)
        ipY = (k1*b2-k2*b1)/(k1-k2)
        RETURN,[ipX,ipY]
      ENDELSE
    ENDELSE
  ENDELSE
;
END

;�աաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաա�
;
;
;����ƽ����ֱ���Ƿ��������ཻ���н���ɷ���
;2010��3��25��
; Write By DYQ
;
;���ø�ʽresult = CalLineInPolygon(linePoints, polyPoints) ;
;LinePoints: ������Ķ�ά����[2,2]�����򷵻�-1;
;PolyPoints: ����ε�Ķ�ά����[2,n]�����򷵻�-1
;
FUNCTION CALLINEINPOLYGON, linePoints, polyPoints
  COMPILE_OPT idl2
  ;
  IF ARRAY_EQUAL(SIZE(inPoints,/dimension), [2,2]) THEN RETURN,-1
  ;�����
  pointNum = (SIZE(polyPoints,/dimension))[1]
  ;�ཻ��ʶ
  sign = -1
  ipoints = [0,0]
  ;ѭ�����
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
  ;�жϽ����Ƿ��ڶ������
  ;
  oROI = OBJ_NEW('IDLanROI', polyPoints)

  conArr = [0,0]
  FOR i=0, N_ELEMENTS(result)/2-1 DO BEGIN
    ;
    psign= oROI->CONTAINSPOINTS(result[*,i])
    ;���ڶ�����ڵĵ�
    IF psign NE 0 THEN BEGIN
      conArr = [[conArr], [result[*,i]]]
    ENDIF
  ENDFOR
  OBJ_DESTROY,oROI
  ;
  IF N_ELEMENTS(conArr)/2 EQ 1 THEN RETURN, -1 ELSE RETURN,conArr[*,1:N_ELEMENTS(conArr)/2-1]
END
;
;�աաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաաա�
;
;���Գ���

PRO TEST
  ;
  ;  restore,'C:\Users\Administrator\Desktop GridNum,format="(I07)"LineInPolygon.sav'
  linePoints = [[0,0],[2,1]]
  polyPoints = [[1,1],[2,1],[3,2],[4,1]]
  points = CALLINEINPOLYGON(linePoints, polyPoints)

  PRINT,points
END
;




