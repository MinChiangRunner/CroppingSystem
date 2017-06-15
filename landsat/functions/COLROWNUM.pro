FUNCTION COLROWNUM, pos, column
  COMPILE_OPT idl2
  co = pos MOD COLUMN
  row = pos / column
  ;return,[rotate(co,1),rotate(row,1)]
  return,TRANSPOSE([[co],[row]])
END