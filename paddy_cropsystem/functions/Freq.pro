FUNCTION FREQ, arr
  COMPILE_OPT idl2
  ;�����ȡΨһֵ

  data1 = arr[sort(arr)]
  ;��ȡΨһֵ
  frer = data1[UNIQ(data1)]
  per = !NULL
  num = n_elements(arr)
  FOR i=0, n_elements(frer)-1 DO BEGIN
    xx = where( arr EQ frer[i], n)
    per = [[per],[frer[i], n, float(n)*100/float(num)]]
  ENDFOR
  return,per

END