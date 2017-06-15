  ;+
  ; :DESCRIPTION:
  ;    将batch_vi_cal计算得出的EVI数据转成Hants需要的byte BIL形式或者INTEGER形式；
  ;    输出为解压后导入Hants软件的格式
  ; :AUTHOR: chiangmin
  ;-
PRO DataTypeConvertUnpack

  COMPILE_OPT IDL2
  ; General error handler
  ;  CATCH, err
  ;  IF (err NE 0) THEN BEGIN
  ;    CATCH, /CANCEL
  ;    IF OBJ_VALID(e) THEN $
  ;      e.REPORTERROR, 'ERROR: ' + !ERROR_STATE.MSG
  ;    MESSAGE, /RESET
  ;    RETURN
  ;  ENDIF
  OutDir = 'D:\modis\ForHANTS'
  Indir = 'D:\modis\Result\EVI'
  InFiles = FILE_SEARCH(Indir, '*_evi.dat',count=n,/TEST_REGULAR)
  ;CD,OUTDIR
  e = ENVI(/HEADLESS)

  ;进度条
  wtlb = Widget_Base(xSize =200,ySize= 200, $
    title = '进度条')
  Widget_Control,wtlb,/Realize
  ;初始化进度条
  process = IDLitwdProgressBar( $
    GROUP_LEADER=wTlb, $
    TIME=0,cancel = cancelIn, $
    TITLE='处理中... 请稍等')
  ;开始走...
  IDLitwdProgressBar_setvalue, process, 0
  per = 100.0/n
  ; Create an ENVIRaster
  ;file = FILEPATH('qb_boulder_pan', ROOT_DIR=e.ROOT_DIR, $
  ;  SUBDIRECTORY = ['data'])
  ;file = 'E:\paddy_extr\index\2014\h28v06_2014_evi.dat'
  FOR j=0, n-1 DO BEGIN
    ;解析年份，作为文件夹名称
    YEAR = strmid(InFiles[j],strpos(InFiles[j],'_',/REVERSE_SEARCH)-4,4)
    COLROW = strmid(InFiles[j],strpos(InFiles[j],'\',/REVERSE_SEARCH)+1,6)
    outfile = Outdir + '\'+ year
    IF ~FILE_TEST(outfile)THEN FILE_MKDIR, outfile
    outfile = Outdir + '\'+ year +'\'+COLROW
    IF ~FILE_TEST(outfile)THEN FILE_MKDIR, outfile

    raster = e.OPENRASTER(Infiles[j])
    SpatialReF = raster.SPATIALREF
    data = raster.GETDATA()
    
    ;将数据转为BYTE 和 bil格式,并输出
    IF 0 THEN BEGIN
      OutFile = outfile+PATH_SEP()+ FILE_BASENAME(Infiles[j],'.dat') +'BIL.dat'
      OutRaster = ENVIRaster(transpose(byte(round(data/100.0)),[0,2,1]), $
        DATA_TYPE = 1,INTERLEAVE='bil',SpatialReF =SPATIALREF ,URI=Outfile)
      outraster.SAVE
    ENDIF
    
    ;将long 型转为integer型的bsq
    IF 1 THEN BEGIN
      OutFile = outfile+PATH_SEP()+ FILE_BASENAME(Infiles[j],'.dat') +'_INT.dat'
      OutRaster = ENVIRaster(FIX(data), DATA_TYPE = 2,SpatialReF =SPATIALREF ,URI=Outfile)
      outraster.SAVE
    ENDIF

    ; raster = e.OPENRASTER(file,EXTERNAL_TYPE='arcview')
    ;分解
    Outraster = e.OPENRASTER(Outfile);,EXTERNAL_TYPE='arcview'
    nbs = OutRaster.NBANDS
    ; Create a temporary output file
    ;newFile = 'E:\paddy_extr\index\filter_evi\unpack\2010_EVI_bil'
    ;newFile = FILE_DIRNAME(outfile)+PATH_SEP()+'I'
    FOR i=0, nbs-1 DO BEGIN
      ; Export a subset of the raster as an ENVI file
      nb = STRING(i+1)
      OUTFile = FILE_DIRNAME(outfile)+PATH_SEP()+'I' + nb.COMPRESS(); +'.dat'
      subRaster = ENVISUBSETRASTER(Outraster, BANDS = i);,SUB_RECT=[0,0,2399,2399]
      subraster.EXPORT, OUTFile, 'ENVI'
      openw,lun,file_dirname(OutFile)+'\datalist.txt',/GET_LUN,/APPEND
      printf,lun,FILE_BASENAME(outfile),strcompress(string(8*i+1))
      free_lun,lun
    ENDFOR

    openw,lun,file_dirname(outFile)+'\Del.bat',/GET_LUN
    printf,lun, 'del *pof'
    printf,lun, 'del *scf'
    printf,lun, 'del *bin'
    printf,lun, 'del *hcf'
    printf,lun, 'del *pcf'
    printf,lun, 'del *tsp'
    free_lun,lun

    IDLITWDPROGRESSBAR_SETVALUE, process,per*(j+1)
  ENDFOR

  ;销毁进度条
  Widget_Control,process,/Destroy
  Widget_Control,wTlb, /Destroy

  ; Open the ENVI file
  ;raster2 = e.OPENRASTER(newFile)
  ;view = e.GETVIEW()
  ;layer = view.CREATELAYER(raster2)
  ok = DIALOG_MESSAGE('完成',/INFORMATION)
  ;raster.CLOSE
  e.CLOSE
END