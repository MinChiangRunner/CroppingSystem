
PRO CROPSYS_PEAK_CAL_EVENT, event
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
      indir = DIALOG_PICKFILE(TITLE='请选择输入文件的路径',/DIRECTORY);
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

    'start': BEGIN
      PRINT,(*pState).STDATE
      WIDGET_CONTROL, event.ID,get_value=STDATE
      PRINT,STDATE
      (*pState).STDATE = STDATE
      PRINT,(*pState).STDATE
    END

    'end': BEGIN
      PRINT,(*pState).ENDATE
      WIDGET_CONTROL, event.ID,get_value=ENDATE
      PRINT,ENDATE
      (*pState).ENDATE = ENDATE
      PRINT,(*pState).ENDATE
    END

    'intval': BEGIN
      PRINT,(*pState).INTERVAL
      WIDGET_CONTROL, event.ID,get_value=INTERVAL
      PRINT,INTERVAL
      (*pState).INTERVAL = INTERVAL
      PRINT,(*pState).INTERVAL
    END

    'postfix': BEGIN
      PRINT,(*pState).POSTFIX
      WIDGET_CONTROL, event.ID,get_value=POSTFIX
      PRINT,POSTFIX
      (*pState).POSTFIX = POSTFIX
      PRINT,(*pState).POSTFIX
    END
    'evimin': BEGIN
      PRINT,(*pState).THREVALUE
      WIDGET_CONTROL, event.ID,get_value=THREVALUE
      PRINT,THREVALUE
      (*pState).THREVALUE = THREVALUE
      PRINT,(*pState).THREVALUE
    END
    'dectrend': BEGIN
      PRINT,(*pState).DECTREND
      WIDGET_CONTROL, event.ID,get_value=DECTREND
      PRINT,DECTREND
      (*pState).DECTREND = DECTREND
      PRINT,(*pState).DECTREND
    END

    'excute': BEGIN
      PEAK_CAL,stdate=(*pState).STDATE, endate=(*pState).ENDATE,$
        input=(*pState).INDIR,output=(*pState).OUTDIR,  $
        ThreValue=(*pState).THREVALUE,postfix=(*pState).POSTFIX, $
        interval=(*pState).INTERVAL, DecTrend=(*pState).DECTREND

      ok = DIALOG_MESSAGE('熟制检测完成',/INFORMATION)
    END

    'exit': BEGIN
      WIDGET_CONTROL, event.TOP,/destroy
      RETURN
    END
    ELSE:
  ENDCASE

END


PRO CROPSYS_PEAK_CAL
  COMPILE_OPT idl2
  ; e = ENVI(/headless)
  ftlb = WIDGET_BASE(xsize =400,ysize =200,$
    title ='熟制检测',/COLUMN,/TLB_KILL_REQUEST_EVENTS, $
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

  ;参数设置
  par1 = WIDGET_BASE(ftlb,/ROW,TITLE='参数设置')
  nleft = CW_FIELD(par1, $
    TITLE = "开始时期：", $
    /integer,uname='start', value=18, $
    /RETURN_EVENTS,/FOCUS_EVENTS)
  nright = CW_FIELD(par1, $
    TITLE = "结束时期：", $
    /integer,uname='end', value=38, $
    /RETURN_EVENTS,/FOCUS_EVENTS)
  par2 = WIDGET_BASE(ftlb,/ROW,TITLE='参数设置')
  intv = CW_FIELD(par2,TITLE = '两期间隔: ', $
    /INTEGER,UNAME='intval', value=8, $
    /RETURN_EVENTS,/FOCUS_EVENTS)
  fix = CW_FIELD(par2,TITLE = '输出后缀: ', $
    /STRING,UNAME='postfix', value ='.img', $
    /RETURN_EVENTS,/FOCUS_EVENTS)
  par3 = WIDGET_BASE(ftlb,/row, TITLE='参数设置')
  emin = CW_FIELD(par3, TITLE='最小阈值: ', $
    /FLOATING, UNAME='evimin', value = 3500, $
    /RETURN_EVENTS, /FOCUS_EVENTS)
  DT = CW_FIELD(par3, TITLE='有效趋势个数: ', $
    /FLOATING, UNAME='dectrend', value = 3, $
    /RETURN_EVENTS, /FOCUS_EVENTS)


  ;退出、执行
  excu = WIDGET_BASE(ftlb,/ROW,/ALIGN_CENTER)
  excute = WIDGET_BUTTON(excu, $
    value = '开始',uname='excute')
  exi = WIDGET_BUTTON(excu, $
    value = '退出',uname='exit')


  WIDGET_CONTROL,ftlb,/REALIZE
  ; Nleftv=5 & Nrightv=5
  pstate = {INTXT: INTXT,$
    OUTTXT:OUTTXT,       $
    INDIR:'',            $
    OUTDIR: '',          $
    STDATE: 18,          $
    ENDATE:38,           $
    POSTFIX:'.img',      $
    INTERVAL: 8 ,        $
    THREVALUE: 3500,       $
    DECTREND: 3          $
  }
  ;操作界面居中
  CENTERTLB,Ftlb

  pstate  = PTR_NEW(pstate,/NO_COPY)
  WIDGET_CONTROL,ftlb,/realize,/map,SET_Uvalue= pstate
  XMANAGER,'CROPSYS_PEAK_CAL',ftlb,/NO_BLOCK

END

