;+
; :DESCRIPTION:
;    生成Hants滤波的文件，用于批处理.
;
;
; :AUTHOR: chiangmin
;-
PRO CreatHantsBat
  COMPILE_OPT idl2
  ;打开模板.bat
  ModelFile = 'E:\jim\EviForHants\HANTSEVI2002360I.bat'
  nl = file_lines(ModelFile)
  Model = strarr(nl)
  openr,lun,ModelFile,/GET_LUN
  readf,lun, Model
  free_lun,lun

  headerFile = 'E:\jim\EviForHants\Header45.hdr'
  nl = file_lines(headerFIle)
  HeaderModel = strarr(nl)
  openr,lun,HeaderFile,/GET_LUN
  readf,lun, HeaderModel
  free_lun,lun
  
  ;搜索平滑的文件位置,即Del.bat的个数
  Indir = 'E:\jim\EviForHants'
  infiles = FILE_SEARCH(Indir,'Del.bat',count=n)

  FOR i =0, n-1 DO BEGIN
    filename = infiles[i]
    year = filename.extract('[0-9]{4}')
    colrow = filename.extract('h[0-9]{2}v[0-9]{2}')
    outfile = FILE_DIRNAME(infiles[i])+PATH_SEP()+ $
      'HANTSEVI'+year+colrow +'360I.bat'

    ;输出Hants配置文件
    openw,lun, outfile, /GET_LUN
    outfile1 = FILE_DIRNAME(outfile)+path_sep()+ FILE_BASENAME(outfile,'.bat')
    ;printf,lun, 'SET PATH=%PATH%;E:\HANTS\'
    printf,lun, MODEL[13]
    printf,lun, 'projectUI ','"',outfile1,'"',' 2400 2400 46 I'
    printf,lun, 'PackNew ','"',outfile1,'"',' "', $
      FILE_DIRNAME(outfile1),'\datalist(0-360).txt"',FORMAT='(7A)'
    printf,lun, 'hantsUI ','"',outfile1,'"', $
      ' 360 1 9999 Lo 3 13 1 4 360 230 120 90',FORMAT='(5A)'
    printf,lun, 'hantsP ','"',outfile1,'"'
    printf,lun, 'UnPackNew ','"',outfile1,'"',' 4 ','"',outfile1,'"', format='(8A)'
    printf,lun, 'synthUI ','"',outfile1,'"',' 1 360 8 '
    printf,lun, 'synthP ','"',outfile1,'"'
    ;printf,lun, 'pause'
    free_lun, lun

    ;输出Batch批处理文件
    bb = 'E:\jim\EviForHants\batch.bat'
    openw,lun,bb,/get_lun,/append
    printf,lun, 'cd ',  '"',file_dirname(outfile),'"', format='(5A)'
    printf,lun,'call ', '"',outfile,'"', format='(4A)'
    printf,lun,'call "Del.bat"'
    free_lun,lun

    ;输出Header文件
    HeaderDir = 'E:\jim\EviForHants\HantsRawResult\' + file_basename(outfile,'.bat')+'.hdr'
    openw,lun,HeaderDir,/get_lun
    printf,lun,HeaderModel,format='(A)'
    free_lun,lun
    
  ENDFOR
  
  ok = DIALOG_MESSAGE('完成啦！'/INFORMATION)
END