PRO PEAK_DECTION
;获取作物历，也就是波峰出现的位置和波谷所在位置
  COMPILE_OPT idl2
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT,log_file='E:\paddy_extr\peak_dec.txt'

  T = 0.4 ;波峰值的范围
  out_file = 'E:\paddy_extr\index\peak\'

  file = "E:\paddy_extr\index\peak_gt0.3.img"
  ;file = "E:\paddy_extr\index\sg_lv\train.img"
  ENVI_OPEN_FILE,file,r_fid=fid
  ENVI_FILE_QUERY,fid,dims=dims,ns=ns,nl=nl,nb=nb
  peak = MAKE_ARRAY(ns,nl,nb)


  FOR i=0,nb-1 DO $
    peak[*,*,i] = ENVI_GET_DATA(fid=fid,dims=dims,pos=i)
  file = "E:\paddy_extr\index\sg_lv\evi_SG_D35.img"
  ENVI_OPEN_FILE,file,r_fid=fid
  ENVI_FILE_QUERY,fid,dims=dims,ns=ns,nl=nl,nb=nb
  evi = MAKE_ARRAY(ns,nl,nb)
  FOR i=0,nb-1 DO $
    evi[*,*,i] = ENVI_GET_DATA(fid=fid,dims=dims,pos=i)

  PRINT,"计算波峰个数"
  n_peak = MAKE_ARRAY(ns,nl,/integer,value=0) ; 没有加任何判断前波峰数
  np_peak = MAKE_ARRAY(ns,nl,/integer,value=0) ; 加波谷判断后的水稻波峰数
  p_peak = MAKE_ARRAY(ns,nl,/integer,value=0) ; 符合水稻规律的波峰数
  f_peak = MAKE_ARRAY(ns,nl,nb,/integer,value=0); 最终水稻波峰位置
  n_e = MAKE_ARRAY(ns,nl,/integer,value=0) ; 早稻波峰位置个数
  n_b = MAKE_ARRAY(ns,nl,/integer,value=0) ; 共同波峰位置个数
  n_m = MAKE_ARRAY(ns,nl,/integer,value=0) ; 中稻波峰位置个数
  n_l = MAKE_ARRAY(ns,nl,/integer,value=0) ; 晚稻波峰位置个数
  FOR i=0, ns-1 DO BEGIN
    FOR j=0, nl-1 DO BEGIN
      ; 在早稻抽穗 19：23 或者晚稻和中稻抽穗 26：35 期间的为水稻
      x = WHERE(peak[i,j,*] EQ 1, n)
      n_peak[i,j] = n

      ;判断早稻波峰
      f = WHERE(((x GE 19) AND (x LE 23)), early)
      n_e[i,j] = early
      IF early NE 0 THEN f_peak[i,j,x[f]] = 1
      IF (evi[i,j,x[f]] LT T) THEN BEGIN
        n_e[i,j] = 0
        f_peak[i,j,x[f]] = 0
      ENDIF
      ;判断晚稻和中稻波峰
      m = WHERE(((x GE 27) AND (x LE 31)),mid);中稻波峰位置及个数
      f_peak[i,j,x[m]] = 1
      IF (mid EQ 1) THEN  n_m[i,j] = mid *3*(evi[i,j,x[m]] GE T)
      b = WHERE(((x GE 30) AND (x LE 31)),both);
      n_b[i,j] = both
      IF (both EQ 1) THEN  f_peak[i,j,x[b]] = 1
      av = MEAN(evi[i,j,39:45]) ; 40:46期晚稻值平均值要小于0.3
      l = WHERE(((x GE 30) AND (x LE 35)),late)
      n_l[i,j] = late*7*((evi[i,j,x[l]] GE T) AND (av LE 0.3))  ; 40:46期晚稻值平均值要小于0.3
      IF (late EQ 1) THEN  f_peak[i,j,x[l]] = 1

      IF (n_b[i,j] EQ 1) THEN BEGIN
        n_m[i,j] =0
        n_l[i,j] =0
        n_b[i,j] = 5*(evi[i,j,x[b]] GE T)
      ENDIF
      ; 当在27 和35之间有两个峰时，取值大的为波峰
      f = WHERE(((x GE 27) AND (x LE 35)),p)
      ; if (p eq 2) then stop,f
      IF (p EQ 2) THEN BEGIN
        k1 = f[0]
        k2 = f[1]
        n_m[i,j] = (MAX(evi[i,j,x[f]],/nan) GE T)* $
          (evi[i,j,x[k1]] GT evi[i,j,x[k2]])*3
        f_peak[i,j,x[k1]] = (MAX(evi[i,j,x[f]],/nan) GE T)* $
          (evi[i,j,x[k1]] GT evi[i,j,x[k2]])*1
        n_l[i,j] = (MAX(evi[i,j,x[f]],/nan) GE T)* $
          (evi[i,j,x[k1]] LT evi[i,j,x[k2]])*7
        f_peak[i,j,x[k2]] = (MAX(evi[i,j,x[f]],/nan) GE T)* $
          (evi[i,j,x[k1]] LT evi[i,j,x[k2]])*1
      ENDIF

      p_peak[i,j] = n_e[i,j] + n_m[i,j] + n_l[i,j]+ n_b[i,j]
      np_peak[i,j] = p_peak[i,j]
      ;    x = where( f_peak[i,j,*] eq 1, n)
      ;
      ;   if (n eq 2) then begin
      ;
      ;    ; 当波峰在早稻1 和 中稻3 同时出现时，留下数值大的作为波峰
      ;    if (np_peak[i,j] eq 4) then begin
      ;    np_peak[i,j] = 10
      ;    ;np_peak[i,j] = (evi[i,j,x[0]] gt evi[i,j,x[1]])*1 + $
      ;     ;             (evi[i,j,x[0]] le evi[i,j,x[1]])*3
      ;    endif
      ;
      ;    ; 如果为 双季稻 及 6 8 则  记录波谷位置，如果波谷不在晚稻移栽期，则选择值大的为单季稻
      ;   if  ((p_peak[i,j] eq 6) or (p_peak[i,j] eq 8)) then begin
      ;     valv = MIN(evi[i,j,x[0]:x[1]], val) ; 波谷位置
      ;     p_val = val + x[0] ; 波谷在X中的位置
      ;     f_peak[i,j,p_val] = -1
      ;
      ;     if ((p_val gt 28) or ( p_val lt 25)) then begin
      ;       np_peak[i,j] = 9
      ;       ;np_peak[i,j] = (evi[i,j,x[0]] GT evi[i,j,x[1]])*1 + $
      ;        ; (evi[i,j,x[0]] LT evi[i,j,x[1]])*(np_peak[i,j]-1)
      ;     endif
      ;   endif
      ;  endif
    ENDFOR
  ENDFOR

  map_info = ENVI_GET_MAP_INFO(fid=fid)
  ENVI_WRITE_ENVI_FILE, n_peak, $
    out_name=out_file+"n_peak_gt" + $
    STRMID(STRING(T),7,3,/reverse_offset)+".img", $
    map_info=map_info
  ENVI_WRITE_ENVI_FILE, p_peak, out_name=out_file+"p_peak_gt"+STRMID(STRING(T),7,3,/reverse_offset)+".img", $
    map_info=map_info
  ENVI_WRITE_ENVI_FILE, np_peak, out_name=out_file+"np_peak_gt"+STRMID(STRING(T),7,3,/reverse_offset)+".img", $
    map_info=map_info

  PRINT,"媳妇万岁，完成啦！"
  ENVI_BATCH_EXIT
END