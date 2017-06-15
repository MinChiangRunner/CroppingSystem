FUNCTION ArrSort, arr
  COMPILE_OPT idl2
  arr1 = arr[0,*] ;
  ;size(arr1,/type)
  coln = n_elements(arr[*,0])
  row = N_ELEMENTS(arr[0,*])
  newarr = make_array(size(arr,/DIMENSIONS),TYPE= size(arr,/type))
  newarr[0,*] = arr1[sort(arr1)]
  FOR i=0, row-1 DO BEGIN
    newarr[1:(coln-1), where(newarr[0,*] EQ (arr[0,*])[i])] = arr[1:(coln-1),i]
  ENDFOR
  return, newarr
END