PRO UNPACK_RASTER
  COMPILE_OPT IDL2
  ; General error handler
  ;  CATCH, err
  ;  IF (err NE 0) THEN BEGIN
  ;    CATCH, /CANCEL
  ;    IF OBJ_VALID(e) THEN $
  ;      e.REPORTERROR, 'ERROR:   ' + !ERROR_STATE.MSG
  ;    MESSAGE, /RESET
  ;    RETURN
  ;  ENDIF
  
  e = ENVI(/HEADLESS)
  
  ; Create an ENVIRaster
  ;file = FILEPATH('qb_boulder_pan', ROOT_DIR=e.ROOT_DIR, $
  ;  SUBDIRECTORY = ['data'])
  ;file = 'E:\paddy_extr\index\2010\evi\h28v06_2010_evi_int10000'
  InFile = 'E:\paddy_extr\index\2014\h28v06_2014_evi.dat'
  InFile = 'E:\paddy_extr\Processing\EVI\2010BlueRecInteger.daT'
  
  
 
  raster = e.OPENRASTER(InFile)
  ; raster = e.OPENRASTER(file,EXTERNAL_TYPE='arcview')
  nbs = raster.NBANDS
  ; Create a temporary output file
  ;newFile = 'E:\paddy_extr\index\filter_evi\unpack\2010_EVI_bil'
  ;newFile ='E:\paddy_extr\index\filter_evi\HSOFTINPUT\10000inter\2010_EVI_inter'
  newFile = 'E:\paddy_extr\index\filter_evi\HSOFTINPUT\2010BlueRec\2010REblue'
  FOR i = 0, nbs-1 DO BEGIN
    ; Export a subset of the raster as an ENVI file
    nb = STRING((i+1))
    ;outfile
    OUTFile = newFile + nb.COMPRESS(); +'.dat'
    subRaster = ENVISUBSETRASTER(raster, BANDS = i);,SUB_RECT=[0,0,2399,2399]
    subraster.EXPORT, OUTFile, 'ENVI'
    txtFile = file_dirname(OutFile)+'\datalist.txt'
    openw,lun,txtFile,/GET_LUN,/APPEND
    printf,lun,FILE_BASENAME(outfile),strcompress(string(8*i))
    free_lun,lun
  ENDFOR

  openw,lun,file_dirname(newFile)+'\del.bat',/GET_LUN
  printf,lun, 'del *pof'
  printf,lun, 'del *scf'
  printf,lun, 'del *bin'
  printf,lun, 'del *hcf'
  printf,lun, 'del *pcf'
  printf,lun, 'del *tsp'
  free_lun,lun
  ; Open the ENVI file
  ;raster2 = e.OPENRASTER(newFile)
  ;view = e.GETVIEW()
  ;layer = view.CREATELAYER(raster2)
  ok = DIALOG_MESSAGE('Íê³É',/INFORMATION)
  raster.CLOSE
  e.CLOSE

END