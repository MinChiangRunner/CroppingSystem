;+
; :DESCRIPTION:
;   ��paddysample���Ƚϣ��жϾ���.
; :AUTHOR: chiangmin
;-
PRO VALIDATIONPOINT
  COMPILE_OPT idl2
  IF ~OBJ_VALID(e) THEN e = Envi(/headless)
  ;ˮ����������
  SampleFile = 'E:\paddy_extr\site\SampleALL\PaddySampleSZ\RasterH28V06SampleSZFinal2th.dat'
  ;SampleFile = 'E:\paddy_extr\test\JXSampleSZFinal2thH28v06.dat'
  SampleRaster = e.OPENRASTER(SampleFile)
  Sample = SampleRaster.GETDATA()
  SampleRaster.CLOSE

  ;��ȡ�Ľ������
  ;ResultFile = 'E:\paddy_extr\Processing\RawResult\numpeak_18_38_DE3_10_Hants.dat';T35
  ;ResultFile = 'E:\paddy_extr\Processing\RawResult\numpeak_18_38_DE3_8_Hants.dat';T35
  ;ResultFile = 'E:\paddy_extr\Processing\RawResult\numpeak_18_39_DE2_8_Hants.dat';T33
  ;ResultFile = 'E:\paddy_extr\Processing\RawResult\numpeak_18_38_DE3_8_T33_Hants.dat'
  ;ResultFile = 'E:\paddy_extr\Processing\RawResult\numpeak_18_38_DE4_8_T33_Hants.dat'
  ;ResultFile = 'E:\paddy_extr\test\2014evi\numpeak_18_39_DE2_8_T33_Hants360I.dat'
  ;ResultFile = 'E:\paddy_extr\test\2010\2010numpeak_18_39_DE2_8_T33.dat'
  ;ResultFile = 'E:\paddy_extr\test\2010\JX2010180numpeak_18_39_DE2_8_T33.dat'
  ResultFile = 'E:\paddy_extr\Processing\RawResult\numpeak_18_39_DE2_8_T33_SpecificPhon.dat'
  ResultRaster = e.OPENRASTER(ResultFile)
  Result = ResultRaster.GETDATA()
  SpatialRef = ResultRaster.SPATIALREF
  ;ResultRaster.CLOSE

  Outfile = 'E:\paddy_extr\Processing\Validation'
  ;Outfile = 'E:\paddy_extr\test\2010\Validation'

  ;�����ж�
  ;��������
  data = (Sample*10 + Result)*( Sample NE 0)

  ;������դ��
  File = OutFile +PATH_SEP()+ FILE_BASENAME(Resultfile, '.dat')+'VLDSample.dat'
  Outdata = EnviRaster(data, URI=file, SPATIALREF=SPATIALREF)
  outdata.SAVE

  ;�������
  Percent = FREQ(data)

  ;��0��Ԫ����
  all = n_elements(data)-percent[1,0]
  inper = !NULL
  FOR i=1, n_elements(Percent[0,*])-1 DO BEGIN
    n=Percent[1,i]
    inper = [[inper],[Percent[0,i], n, float(n)*100.0/float(all)]]
  ENDFOR

  ;������ȷ����Ԫ����������
  ;������Ԫ
  nuacc = total(percent[1,where((percent[0,*] EQ 11)  OR (percent[0,*] EQ 22) OR (percent[0,*] EQ 33))])
  Accur = total(percent[2,where((percent[0,*] EQ 11)  OR (percent[0,*] EQ 22) OR (percent[0,*] EQ 33))])
  Percent = [[Percent],[99,nuacc,Accur]]
  ;��0��Ԫ
  nuacc = total(inper[1,where((inper[0,*] EQ 11) OR (inper[0,*] EQ 22) OR (inper[0,*] EQ 33))])
  Accur = total(inper[2,where((inper[0,*] EQ 11) OR (inper[0,*] EQ 22) OR (inper[0,*] EQ 33))])
  inper = [[inper],[99,nuacc,Accur]]

  ;�������ʾ
  outfile = Outfile + PATH_SEP()+FILE_BASENAME(File, '.dat')+'_accu.txt'
  coln = data.DIM ;���ݵ�����
  openw,lun,outfile,/GET_LUN
  printf,lun,'�����ļ���',SampleFile
  printf,lun,'��ȡ����ļ���',ResultFile
  printf,lun,'---------------------------'
  printf,lun,'������Ԫ'
  PRINTF,lun, '���','����','ռ��', format= '(3a10)'
  PRINTF,lun,Percent,format= '(3f9.3)'
  printf,lun,'---------------------------'
  printf,lun,'��ˮ����Ԫ��'
  PRINTF,lun, '���','����','ռ��', format= '(3a10)'
  PRINTF,lun,inper,format= '(3f9.3)'
  printf,lun, 'ע��99Ϊ���徫��'
  printF,lun,'---------------------------'
  printF,lun, '12���кţ�'
  printF,lun, COLROWNUM(where(data EQ 12),coln[0])
  printF,lun, '21���кţ�'
  printF,lun, COLROWNUM(where(data EQ 21),coln[0])
  free_lun, lun

  NumPer = percent.DIM
  tlb = WIDGET_BASE(title='��ȡ������֤', $
    /Column, $
    /TLB_SIZE_EVENTS , $
    uname='wtlb' )

  table1 = WIDGET_TABLE(tlb, $
    uName  = 'table1', $
    COLUMN_LABELS = ['���','����','ռ��'], $
    xsize = NumPer[0], ysize = NumPer[1] , $
    /All_Events)

  table2 = WIDGET_TABLE(tlb, $
    /DISJOINT_SELECTION, $
    COLUMN_LABELS = ['���','����','ռ��'], $
    xsize = NumPer[0], ysize = NumPer[1], $
    uName  = 'table2')

  WIDGET_CONTROL,tlb,/realize
  CENTERTLB,tlb
  WIDGET_CONTROL, table1, set_value = Percent
  WIDGET_CONTROL, table2, set_value = inper

  ;�����ض�λ�ã�������
  ;  Loc = where(data EQ 21,n)
  ;  colu = data.DIM
  ;  xx = COLROWNUM(loc,colu[0])
  ;  print,xx[*,0:5], xx[*,1110:1115]
  ;  print, inper

  ok = dialog_message('����',/INFORMATION)
  e.CLOSE
END