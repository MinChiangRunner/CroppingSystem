  ;+
  ; :DESCRIPTION:
  ;    Describe the procedure.
  ;
  ; :PARAMS:
  ;    peak
  ;    evi
  ;    interval
  ;    sub
  ;
  ;
  ;
  ; :AUTHOR: chiangmin
  ;-
FUNCTION PEAKSELECT1, evi, interval, sub
  COMPILE_OPT idl2
  max = MAX(evi[i,j,sub],sbmx,/nan)
  sb_i = WHERE((sub LT (sub[sbmx]+interval)) $
    AND (sub GT (sub[sbmx]-interval)))
  sb_r = WHERE(sub GE (sub[sbmx]+interval))
  sb_l = WHERE(sub LE (sub[sbmx]-interval))
  result = {SBMAX:sbmax, $
    SBI:sb_i,            $
    SBR:sb_r,            $
    SBL:sb_l}
  RETURN, result
END


