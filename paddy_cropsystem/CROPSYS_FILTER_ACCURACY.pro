
PRO CROPSYS_FILTER_ACCURACY_EVENT, ev
  COMPILE_OPT idl2
  WIDGET_CONTROL,ev.TOP, get_UValue = aState

  ;关闭事件
  IF TAG_NAMES(ev, /Structure_Name) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
    ;
    status = DIALOG_MESSAGE('关闭?',/Question)
    IF status EQ 'No' THEN RETURN
    ;销毁指针
    ; PTR_FREE, pState
    WIDGET_CONTROL, ev.TOP,/Destroy
    RETURN;
  ENDIF
  uname = WIDGET_INFO(ev.ID,/uname)
  CASE uname OF
    'input1':BEGIN
      file1 = DIALOG_PICKFILE(TITLE='输入原始文件', $
        filter = '*.img',path='e:\paddy_extr\index')
      (*astate).INPUT1 = file1
      WIDGET_CONTROL,(*astate).INTXT1,set_value = file1
    END

    'input2':BEGIN
      file2 = DIALOG_PICKFILE(TITLE='输入结果文件', $
        filter = '*.img',path='e:\paddy_extr\index\sg_lv')
      (*astate).INPUT2 = file2
      WIDGET_CONTROL,(*astate).INTXT2,set_value = file2
    END

    'excute': BEGIN
      e = ENVI(/headless)
      raster1 = e.OPENRASTER((*astate).INPUT1)
      raster2 = e.OPENRASTER((*astate).INPUT2)
      ;view = e.GETVIEW()
      ;layer1 = view.CREATELAYER(raster1)
      ;layer2 = view.CREATELAYER(raster2)
      (*astate).RAWDATA = raster1.GETDATA()
      (*astate).RESUDATA = raster2.GETDATA()
      ;TV,(*astate).RAWDATA[*,*,0]
;      (*astate).RAWDATA = rawdata
;      (*astate).RESUDATA = resudata
      PRINT,(*astate).RAWDATA[0,0,0]
      PRINT, (*astate).RESUDATA[0,0,0]
      OK = DIALOG_MESSAGE('载入成功！',/INFORMATION)
    END

    'row': BEGIN
      PRINT,(*aState).ROW
      WIDGET_CONTROL, ev.ID,get_value=row
      PRINT,row
      (*aState).ROW = row
      PRINT,(*aState).ROW
    END

    'column': BEGIN
      PRINT,(*aState).COLUMN
      WIDGET_CONTROL, ev.ID,get_value=column
      PRINT,column
      (*aState).ROW = column
      PRINT,(*aState).COLUMN
    END

    'contrast': BEGIN
      row = (*astate).ROW + 1
      column = (*astate).COLUMN + 1
      IPLOT,(*astate).RAWDATA[column,row,*]
      IPLOT,(*astate).RESUDATA[column,row,*],/overplot
    END

    'exit': BEGIN
      WIDGET_CONTROL, ev.TOP,/destroy
      RETURN
    END
    ELSE:
  ENDCASE
END


PRO CROPSYS_FILTER_ACCURACY
  COMPILE_OPT idl2
  ; e = ENVI(/headless)
  atlb = WIDGET_BASE(xsize =400,ysize =200,$
    title ='精度验证' $
    ,/COLUMN,/TLB_KILL_REQUEST_EVENTS, $
    TLB_FRAME_ATTR=1);
  inputbar1 = WIDGET_BASE(atlb,/ROW)
  inbutton1 = WIDGET_BUTTON(inputbar1, VALUE='选择原始栅格', $
    uname='input1')
  intxt1 = WIDGET_TEXT(inputbar1,value='',$
    xsize=46,/frame,/Editable)
  inputbar2 = WIDGET_BASE(atlb,/ROW)
  inbutton2 = WIDGET_BUTTON(inputbar2, VALUE='选择结果栅格', $
    uname='input2')
  intxt2 = WIDGET_TEXT(inputbar2,value='',$
    xsize=46,/frame,/Editable)
  outputbar = WIDGET_BASE(atlb,/ROW)
  row = CW_FIELD(outputbar, $
    TITLE = "行号：", $
    /integer,uname='row',/RETURN_EVENTS,/FOCUS_EVENTS)
  col = CW_FIELD(outputbar, $
    TITLE = "列号：", $
    /integer,uname='column',/RETURN_EVENTS,/FOCUS_EVENTS)

  ;退出、执行
  excu = WIDGET_BASE(atlb,/row,/ALIGN_CENTER)
  excute = WIDGET_BUTTON(excu, $
    value = '载入',uname='excute')
  cont = WIDGET_BUTTON(excu, $
    value = '比较',uname='contrast')
  exi = WIDGET_BUTTON(excu, $
    value = '退出',uname='exit')
  ;wdraw = WIDGET_DRAW(atlb,/frame,xsize=600,ysize=400);
  WIDGET_CONTROL, atlb,/Realize ,/map;,set_uValue = pState
  ;操作界面居中
  CENTERTLB,atlb
  rawdata = FLTARR(2400,2400,46)
  resudata = FLTARR(2400,2400,46)
  Astate = {WINID:'',$
    ROW: 1, $
    COLUMN: 1,$
    INPUT1: '',$
    INPUT2: '',$
    INTXT1:INTXT1,$
    INTXT2:INTXT2,$
    RAWDATA:rawdata,$
    RESUDATA:resudata}
  astate  = PTR_NEW(astate,/NO_COPY)
  rawdata = !NULL
  resudata =!NULL
  WIDGET_CONTROL,atlb,/realize,/map,SET_Uvalue= astate
  XMANAGER,'cropsys_filter_accuracy',atlb,/NO_BLOCK

END