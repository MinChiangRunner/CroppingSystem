;+
; :DESCRIPTION:
;    Double Sort
;
; :Input:
;    input array dimensions: 2*N
;    idx:  0 - Sort by the first column firstly (Default)
;          1 - Sort by the second column firstly
;    type: 0 - ascending sort both columns (Default)
;          1 - descending sort both columns
;          2 - ascending sort firstly, and the descending sort
;          3 - descending sort firstly, and then ascending sort
;
; :Output:
;    output sorted array: 2*N;
;
; :Example:
;    arr = [[9,4],[3,4],[3,1],[2,6],[9,6],[3,5],[5,4]]
;    arrNew = double_sort(arr, 1, 3)
;
; :AUTHOR: duhj@esrichina.com.cn
;-

FUNCTION DOUBLE_SORT, arr, idx, type

  COMPILE_OPT idl2
  PRINT , N_ELEMENTS(arr)
  ;
  ;�ж����������Ƿ�Ϊ2*N
  IF ~N_ELEMENTS(arr) THEN BEGIN
    MESSAGE, 'Incorrect number of arguments', /continue
    RETURN, !null
  ENDIF ELSE BEGIN
    IF (SIZE(arr, /DIMENSIONS))[0] NE 2 $
      OR SIZE(arr, /N_DIMENSIONS) NE 2 THEN BEGIN
      MESSAGE, 'Please input array with 2*N dimensions', /continue
      RETURN, !null
    ENDIF
  ENDELSE

  ;�жϰ��ڼ�������Ĭ��Ϊ0
  ;  0 --- ����һ��������
  ;  1 --- ���ڶ���������
  IF ~N_ELEMENTS(idx) THEN BEGIN
    idx = 0
  ENDIF ELSE BEGIN
    IF idx NE 0 AND idx NE 1 THEN BEGIN
      MESSAGE, 'Input index must be one of the value:0,1', /continue
      RETURN, !null
    ENDIF
  ENDELSE

  ;�ж��������ͣ�����or����
  ;  0 - ������������
  ;  1 - ������������
  ;  2 - ���Ȱ�����Ȼ�󰴽���
  ;  3 - ���Ȱ�����Ȼ������
  IF ~N_ELEMENTS(type) THEN BEGIN
    type = 0
  ENDIF

  arr1 = arr[1-idx,*]
  arr2 = arr[idx,*]

  CASE type OF
    0: BEGIN
      arr1sort = arr1[SORT(arr2)]
      arr2sort = arr2[SORT(arr2)]

      R = HISTOGRAM(arr2sort, location = loc)

      eValue = loc[WHERE(HISTOGRAM(arr2sort) GT 1)]

      FOREACH element, eValue DO BEGIN
        eIdx = WHERE(arr2sort EQ element)
        arr1sort[eIdx] = (arr1sort[eIdx])[SORT(arr1sort[eIdx])]
      ENDFOREACH
    END
    1: BEGIN
      arr1sort = REVERSE(arr1[SORT(arr2)])
      arr2sort = REVERSE(arr2[SORT(arr2)])

      R = HISTOGRAM(arr2sort, location = loc)

      eValue = loc[WHERE(HISTOGRAM(arr2sort) GT 1)]

      FOREACH element, eValue DO BEGIN
        eIdx = WHERE(arr2[REVERSE(SORT(arr2))] EQ element)
        arr1sort[eIdx] = (arr1sort[eIdx])[(REVERSE(SORT(arr1sort[eIdx])))]
      ENDFOREACH
    END
    2: BEGIN
      arr1sort = (arr1[SORT(arr2)])
      arr2sort = (arr2[SORT(arr2)])

      R = HISTOGRAM(arr2sort, location = loc)

      eValue = loc[WHERE(HISTOGRAM(arr2sort) GT 1)]

      FOREACH element, eValue DO BEGIN
        eIdx = REVERSE(WHERE(arr2sort EQ element))
        arr1sort[eIdx] = ((arr1sort[eIdx])[((SORT(arr1sort[eIdx])))])
      ENDFOREACH
    END
    3: BEGIN
      arr1sort = REVERSE(arr1[SORT(arr2)])
      arr2sort = REVERSE(arr2[SORT(arr2)])

      R = HISTOGRAM(arr2sort, location = loc)

      eValue = loc[WHERE(HISTOGRAM(arr2sort) GT 1)]

      FOREACH element, eValue DO BEGIN
        eIdx = (WHERE(arr2sort EQ element))
        arr1sort[eIdx] = ((arr1sort[eIdx])[((SORT(arr1sort[eIdx])))])
      ENDFOREACH
    END
    ELSE: BEGIN
      MESSAGE, 'Please input the correct argument of type.', /continue
      RETURN, !null
    END
  ENDCASE

  arrNew = arr
  arrNew[1-idx,*] = arr1sort
  arrNew[idx,*] = arr2sort

  RETURN, arrNew
END