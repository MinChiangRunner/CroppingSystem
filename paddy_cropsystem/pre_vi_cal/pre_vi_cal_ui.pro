; Add the extension to the toolbox. Called automatically on ENVI startup.
PRO PRE_VI_CAL_UI_EXTENSIONS_INIT
  COMPILE_OPT idl2, hidden

  ; Get ENVI session
  e = ENVI(/CURRENT)

  ; Add the extension to a subfolder
  e.ADDEXTENSION, 'Calculate Spectral Indices', 'RE_VI_CAL_UI', PATH=''
END

; ENVI Extension code. Called when the toolbox item is chosen.
PRO pre_vi_cal_UI
  COMPILE_OPT idl2, hidden

  ; General error handler
  CATCH, err
  IF (err NE 0) THEN BEGIN
    CATCH, /CANCEL
    IF OBJ_VALID(e) THEN $
      e.REPORTERROR, 'ERROR: ' + !ERROR_STATE.MSG
    MESSAGE, /RESET
    RETURN
  ENDIF

  ;Get ENVI session
  e = ENVI()

  Task = ENVITASK('E:\IDL compile\lesson\code\paddy_cropsystem\pre_vi_cal\pre_vi_cal.task')
  ok = e.UI.SELECTTASKPARAMETERS(Task)

  ;If user cancelled then just return
  IF ok NE 'OK' THEN RETURN

  ;Execute the task
  Task.EXECUTE

  ;Display the result
;  View1 = e.GETVIEW()
;  Layer1 = View1.CREATELAYER(Task.OUTPUT_RASTER)

END
