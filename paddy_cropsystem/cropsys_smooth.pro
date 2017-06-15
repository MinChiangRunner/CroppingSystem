;+
; :AUTHOR: chiangmin
; 平滑去噪工具- S-G滤波和Hants 滤波
; S-G: 左边跨度(Nleft) 右边跨度(Nright)
;      最高次数(order) 滤波结束(Degree)
;      选择的都为文件夹位置,且为.dat格式
; Hants： ENVItask
;-


PRO  SGFILTER, $
  Nleft, Nright, $
  Order, Degree, $
  indir, outdir
  ; REFERENCE: HELP about SAVGOL
  ; Specify the following parameters!!!
  ;  Nleft=5   ; lt nb/2 ?
  ;  Nright=5  ; lt nb/2 ?
  ;  Order=0
  ;  Degree=3
  HELP,Nleft, Nright, $
    Order, Degree, $
    indir, outdir
  PRINT,Nleft, Nright, $
    Order, Degree, $
    indir, outdir
  COMPILE_OPT IDL2
  ;OPEN FILE
  ;file = DIALOG_PICKFILE(/READ, FILTER = '*')
  IF ((INDIR EQ '') OR (outdir EQ '')) THEN BEGIN
    ok = DIALOG_MESSAGE('没有选择输入或者输出文件',/ERROR)
    RETURN
  ENDIF
  file = FILE_SEARCH(indir,'*.img',count=fnum);注意
  IF file EQ '' THEN BEGIN
    ok = DIALOG_MESSAGE('没有.img栅格数据',/ERROR)
    RETURN
  ENDIF
  PRINT,file
  ;启动ENVI
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT
  ;进度条
  wtlb = WIDGET_BASE(xSize =200,ySize= 200, $
    title = '进度条')
  WIDGET_CONTROL,wtlb,/Realize
  ;初始化进度条
  process = IDLITWDPROGRESSBAR( $
    GROUP_LEADER=wTlb, $
    TIME=0,cancel = cancelIn, $
    TITLE='处理中.. 请稍等')
  ;开始走...
  IDLITWDPROGRESSBAR_SETVALUE, process, 0
  ;

  FOR j=0, fnum-1 DO BEGIN
    ENVI_OPEN_FILE, file, r_fid=fid
    ENVI_FILE_QUERY, fid, dims=dims, ns=ns, nl=nl, nb=nb
    map_info=ENVI_GET_MAP_INFO(fid=fid)

    ; READ DATA
    fdata = FLTARR(ns,nl,nb)
    ;fdata = MAKE_ARRAY(2400,2400,46,/FLOAT)
    FOR i = 0, nb-1 DO BEGIN
      fdata[*,*,i] = ENVI_GET_DATA(fid=fid, dims=dims, pos=i)
    ENDFOR

    ; Savitzky-Golay with XX, Nth degree polynomial:
    savgolFilter = SAVGOL(Nleft, Nright, Order, Degree)
    SGdata = CONVOL(TRANSPOSE(fdata), savgolFilter, $
      /EDGE_TRUNCATE)
    SGdata = TRANSPOSE(SGdata)

    ; output
    bs = STRING(Nleft)+ $
      STRING(Nright)+STRING(Order)+STRING(Degree)
    bs = bs.COMPRESS()
    OutName = outdir + FILE_BASENAME(file,'.dat')+ $
      '_' + bs + '_sg.dat'
    ENVI_WRITE_ENVI_FILE, SGdata, out_name=OutName, $
      map_info=map_info
    IDLITWDPROGRESSBAR_SETVALUE, process,j*100.0/fnum
  ENDFOR
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy
  ENVI_BATCH_EXIT
  ok = DIALOG_MESSAGE('计算完成',/INFORMATION)
END

PRO CROPSYS_SMOOTH_EVENT, event
  COMPILE_OPT idl2
  WIDGET_CONTROL,event.TOP, get_UValue = pState

  ;关闭事件
  IF TAG_NAMES(event, /Structure_Name) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
    ;
    status = DIALOG_MESSAGE('关闭?',/Question)
    IF status EQ 'No' THEN RETURN
    ;销毁指针
    ; PTR_FREE, pState
    WIDGET_CONTROL, event.TOP,/Destroy
    RETURN;
  ENDIF
  uname = WIDGET_INFO(event.ID,/uname)
  ;事件处理
  CASE uname OF

    'input': BEGIN
      indir = DIALOG_PICKFILE(TITLE='请选择输入文件的路径',/DIRECTORY)
      (*pState).INDIR = indir
      WIDGET_CONTROL, (*pState).INTXT, SET_VALUE=indir
      PRINT,(*pState).INDIR
    END

    'output': BEGIN
      outdir = DIALOG_PICKFILE(TITLE='请选择输出文件的路径',/DIRECTORY)
      (*pState).OUTDIR = outdir
      WIDGET_CONTROL, (*pState).OUTTXT, SET_VALUE=outdir
      PRINT,(*pState).OUTDIR
    END

    'sg': BEGIN
      PRINT,(*pState).METHOD
      (*pState).METHOD = 0
      PRINT,(*pState).METHOD
    END

    'hants': BEGIN
      PRINT,(*pState).METHOD
      (*pState).METHOD = 1
      PRINT,(*pState).METHOD
    END

    'nleft_v': BEGIN
      PRINT,(*pState).NLEFTV
      WIDGET_CONTROL, event.ID,get_value=nleftv
      PRINT,nleftv
      (*pState).NLEFTV = nleftv
      PRINT,(*pState).NLEFTV
    END

    'nright_v': BEGIN
      PRINT,(*pState).NRIGHTV
      WIDGET_CONTROL, event.ID,get_value=nrightv
      PRINT,nrightv
      (*pState).NRIGHTV = nrightv
      PRINT,(*pState).NRIGHTV
    END

    'order_v': BEGIN
      PRINT,(*pState).ORDER
      WIDGET_CONTROL, event.ID,get_value=order
      PRINT,order
      (*pState).ORDER = order
      PRINT,(*pState).ORDER
    END

    'degree_v': BEGIN
      PRINT,(*pState).DEGREE
      WIDGET_CONTROL, event.ID,get_value=degree
      PRINT,degree
      (*pState).DEGREE = degree
      PRINT,(*pState).DEGREE
    END

    'excute': BEGIN
      CASE (*pState).METHOD OF
        0:  SGFILTER, (*pState).NLEFTV, (*pState).NRIGHTV, $
          (*pState).ORDER, (*pState).DEGREE, $
          (*pState).INDIR, (*pState).OUTDIR
        1:  BEGIN
          e = ENVI()
          ui = e.UI
          task = ENVITASK('ENVIHANTSTask')
          UI = e.UI
          R = UI.SELECTTASKPARAMETERS(task)
          IF R NE 'OK' THEN BEGIN
            e.CLOSE
            RETURN
          ENDIF
          task.EXECUTE
        END
        ELSE: error = DIALOG_MESSAGE('未选择方法',/error)
      ENDCASE
    END

    'exit': BEGIN
      WIDGET_CONTROL, event.TOP,/destroy
      RETURN
    END
    ELSE:
  ENDCASE

END


PRO CROPSYS_SMOOTH
  COMPILE_OPT idl2
  ; e = ENVI(/headless)
  ftlb = WIDGET_BASE(xsize =400,ysize =200,$
    title ='平滑去噪',/COLUMN,/TLB_KILL_REQUEST_EVENTS, $
    TLB_FRAME_ATTR=1)
  inputbar = WIDGET_BASE(ftlb,/ROW)
  inbutton = WIDGET_BUTTON(inputbar, VALUE='选择输入文件', $
    uname='input')
  intxt = WIDGET_TEXT(inputbar,value='',$
    xsize=46,/frame,/Editable)
  outputbar = WIDGET_BASE(ftlb,/ROW)
  outbutton = WIDGET_BUTTON(outputbar, value='选择输出文件', $
    uname='output')
  outtxt = WIDGET_TEXT(outputbar,value='',$
    xsize=46,/frame,/Editable)

  exbase1 = WIDGET_BASE(ftlb,/ROW)
  lab = WIDGET_LABEL(exbase1,value='  滤波方法:   ')
  exbase = WIDGET_BASE(exbase1,/ROW,/EXCLUSIVE)
  eb1 = WIDGET_BUTTON(exbase,value ='S-G',UNAME='sg')
  eb2 = WIDGET_BUTTON(exbase,value ='Hants',UNAME='hants')
  ;参数设置
  par1 = WIDGET_BASE(ftlb,/ROW,TITLE='参数设置')
  nleft = CW_FIELD(par1, $
    TITLE = "左边跨度：", $
    /integer,uname='nleft_v',/RETURN_EVENTS,/FOCUS_EVENTS)
  nright = CW_FIELD(par1, $
    TITLE = "右边跨度：", $
    /integer,uname='nright_v',/RETURN_EVENTS,/FOCUS_EVENTS)
  par2 = WIDGET_BASE(ftlb,/ROW,TITLE='参数设置')
  order = CW_FIELD(par2,TITLE = '导数阶数: ', $
    /INTEGER,UNAME='order_v', $
    /RETURN_EVENTS,/FOCUS_EVENTS)
  degree = CW_FIELD(par2,TITLE = '滤波程度: ', $
    /INTEGER,UNAME ='degree_v', $
    /RETURN_EVENTS,/FOCUS_EVENTS)

  ;退出、执行
  excu = WIDGET_BASE(ftlb,/ROW,/ALIGN_CENTER)
  excute = WIDGET_BUTTON(excu, $
    value = '开始',uname='excute')
  exi = WIDGET_BUTTON(excu, $
    value = '退出',uname='exit')


  WIDGET_CONTROL,ftlb,/REALIZE
  Nleftv=5 & Nrightv=5
  pstate = {INTXT: INTXT,$
    OUTTXT:OUTTXT,       $
    INDIR:'',            $
    OUTDIR: '',          $
    NLEFTV: 5,           $
    NRIGHTV:5,           $
    ORDER: 0,            $
    DEGREE: 3,           $
    METHOD: 0}
  ;操作界面居中
  CENTERTLB,Ftlb

  pstate  = PTR_NEW(pstate,/NO_COPY)
  WIDGET_CONTROL,ftlb,/realize,/map,SET_Uvalue= pstate
  XMANAGER,'cropsys_smooth',ftlb,/NO_BLOCK

END