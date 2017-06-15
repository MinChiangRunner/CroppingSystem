;+
; :DESCRIPTION:
;    ��Hants����������˲����תΪBSQ�ָ�����ͬʱ��ͶӰ,Ȼ����в�����.
;
; :AUTHOR: chiangmin
;-
PRO CHANGE_INTERVAL

  COMPILE_OPT idl2
  starttime = SYSTIME(1)
  e = ENVI(/headless)
  ;indir = 'D:\modis\ForHants\2014'
  ;indir = 'E:\jim\HantsInput\360_180_120_90'
  indir ='E:\jim\HantsInput\46_23_15_12\46_23_15_12BIL'
  inputfiles = file_search(indir,'*_psf',count=n,/TEST_REGULAR)
  ;outdir = 'E:\paddy_extr\index\2014'
  ;outdir = 'E:\jim\HantsInput\360_180_120_90BSQ_2010test'
  outdir = 'E:\jim\HantsInput\46_23_15_12\46_23_15_12BSQ'
  ;���ò���
   ;��ȡͶӰ��Ϣ
   ;46������
  ReFile = 'D:\modis\Result\EVI\h28v06_2014_evi.dat';��ȡͶӰ�ļ�
  ReRaster1 = e.OPENRASTER(ReFile)
  SpatialReF1 = ReRaster1.SPATIALREF
  ReFile ='D:\modis\Result\EVI\h28v05_2014_evi.dat'
  ReRaster2 = e.OPENRASTER(ReFile)
  SpatialReF2 = ReRaster2.SPATIALREF
  ReFile ='D:\modis\Result\EVI\h27v06_2014_evi.dat'
  ReRaster3 = e.OPENRASTER(ReFile)
  SpatialReF3 = ReRaster3.SPATIALREF
  ReFile ='D:\modis\Result\EVI\h27v05_2014_evi.dat'
  ReRaster4 = e.OPENRASTER(ReFile)
  SpatialReF4 = ReRaster4.SPATIALREF

  FOR i = 0, n-1 DO BEGIN

    ;inputfile = 'E:\paddy_extr\index\filter_evi\HSOFTINPUT\2014INT\HANTSEVI2014360I_psf'
    ;inputfile = 'E:\paddy_extr\index\filter_evi\HSOFTINPUT\2014Bil\HANtEVI2014360B_psf'
    outfile = outdir + PATH_SEP() + FILE_BASENAME(inputfiles[i])+'_BSQ.dat'
    colrow = outfile.extract('h[0-9]{2}v[0-9]{2}')
    case colrow of 
      'h28v06': SpatialReF = SpatialReF1
      'h28v05': SpatialReF = SpatialReF2
      'h27v06': SpatialReF = SpatialReF3
      'h27v05': SpatialReF = SpatialReF4
      else: 
    endcase
    
    ;��BIL תΪBSQ
    Raster =  e.OPENRASTER(inputfiles[i])
    data = raster.GETDATA()

    CASE raster.DATA_TYPE OF
      'byte': OutRaster = ENVIRaster(transpose(data,[0,2,1]), $
        DATA_TYPE = 2,INTERLEAVE='bsq',SpatialReF =SPATIALREF ,URI=Outfile)
      'int': OutRaster = ENVIRaster(transpose(data,[0,2,1]), $
        DATA_TYPE = 1,INTERLEAVE='bsq',SpatialReF =SPATIALREF ,URI=Outfile)
    ENDCASE
    outraster.SAVE
    OutRaster.CLOSE
    raster.CLOSE
  ENDFOR

  e.close
  proctime = STRING(ROUND((SYSTIME(1) - starttime)/60.0))
  ;e.CLOSE
  print,'typechange Finished,��ʱ'+proctime.COMPRESS()+'����!'
  ;OK = DIALOG_MESSAGE('�����,��ʱ'+proctime.COMPRESS()+'����!',/INFORMATION)
  ;ENVItask�ķ���
  IF 0 THEN BEGIN
    ;ת�ָ���
    task = ENVITASK('ConvertInterleaveDu')
    ;ͨ��AI
    ui = e.UI
    result = UI.SELECTTASKPARAMETERS(task)
    IF result EQ 'OK' THEN task.EXECUTE

    ;���ͶӰ
    FileRef = 'E:\paddy_extr\test\JXTestSG37EVI.dat'
    raster = e.OPENRASTER(FileRef)
    SpatialRef = RASTER.SPATIALREF
    raster.CLOSE

    outfile = 'E:\paddy_extr\index\2014\Hants2014.dat'
    uri = ui.SELECTINPUTDATA(/raster)
    OutRaster = e.OPENRASTER(uri.URI)
    DATA = Outraster.GETDATA()
    outraster = ENVIRASTER(data,URI=outfile, SPATIALREF=SPATIALREF)
    outraster.SAVE
    OutRaster.CLOSE
    raster.CLOSE
    e.close
  ENDIF
print, '���㲨��'
  PEAK_CAL
  print, 'MosaicBatch Start'
MosaicBatch
ok = dialog_message('FInished',/information)
END