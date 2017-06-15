PRO LandsatSZExtraction
  COMPILE_OPT idl2
  ;Input Parameters
  starttime = SYSTIME(1)

  ;LandSat 8 OLI singletitle

  ;filedirs = [ "E:\Landsat\Processing\2015s\120043\2013\RawData\Used" ] ;"E:\Landsat\Processing\2015s\123043\2013\RawData\Used" ;, $
  filedirs = ["E:\Landsat\Processing\2015s\125040\2013\RawData\Used", $
  "E:\Landsat\Processing\2015s\125041\2013\RawData\Used", $
  "E:\Landsat\Processing\2015s\120043\2013\RawData\Used"]

  seqs = [2,2,2];2, $

  ;, $

  ;seqs = 1
  ; 气溶胶模型：0-No Aerosol；1-Rural；4-Maritime；5-Urban；6-Tropospheric
  aerosol_models = [1,1,1]


  FOR i = 0, N_ELEMENTS(filedirs)-1 DO BEGIN
    print, i
    ;filedir = "E:\Landsat\Processing\118040\2014\RAWDATA\Used"
    filedir = filedirs[i]
    ;IF (where(filedir.extract("[0-9]{6}") eq  Newflaash) eq -1) THEN CONTINUE
    ;差值顺序
    ;1 --前半年：差值大于0为双季稻，小于0为单季稻； 2 -- 后半年，差值小于0为双季稻，大于0为单季稻
    ; 注意跨年的影像以年份排序
    SEQ = seqs[i]
    ; 气溶胶模型：0-No Aerosol；1-Rural；4-Maritime；5-Urban；6-Tropospheric
    ;aerosol_model = 2
    aerosol_model = aerosol_models[i]

    files = file_search(filedir,"*_MTL.txt", count=n, /TEST_REGULAR)
    ;建立文件夹，存放输出文件
    RadDir = file_dirname(FILE_DIRNAME(filedir)) + "\Rad" ;Rad file directory
    FlaashDir = file_dirname(FILE_DIRNAME(filedir)) + "\Flaash"
    IF ~FILE_TEST(RadDir) THEN FILE_MKDIR,RadDir
    IF ~FILE_TEST(FlaashDir) THEN FILE_MKDIR,FlaashDir
    e = envi(/headless);
    FOREACH file, files DO BEGIN
      ;开始辐射辐射定标
      print, file_basename(file,".txt") + ' RADCal Starting....'
      radiance_file = RadDir + path_sep()+ $
        file_basename(file,".txt")+"Rad.dat"
      IF ~file_test(radiance_file) THEN BEGIN
        LandsetRadCal, file, RadDir
        print, file_basename(file,".txt") + ' RADCal Done!'
      ENDIF ELSE  BEGIN
        print, radiance_file + ' has existed!"
        RadRaster = e.OpenRaster(radiance_file)
        sensor = RadRaster.METADATA['sensor type']
      ENDELSE

      ;Flaash
      ; input Radiance file
      print, file_basename(file,".txt") + ' Flaash Starting....'
      reflect_file = FlaashDir + path_sep() + $
        file_basename(radiance_file,".dat")+"Flaash.dat"
      IF ~file_test(reflect_file) THEN BEGIN
        FlaashBatch, radiance_file = radiance_file, FlaashDir = FlaashDir, $
          aerosol_model = aerosol_model, sensor = sensor
        print, file_basename(file,".txt") + ' Flaash Done!'
      ENDIF ELSE  print, reflect_file + ' has existed!"
    ENDFOREACH
    ;
    ; SZ Extraction
    ; FlasshDir = 'E:\Landsat\Processing\119040\2014\Flassh'
    print,  ' SZ Extraction Starting....'
    landsatNDVIDiff, FlaashDir = FlaashDir, SEQ = SEQ, sensor = sensor
    print,  ' SZ Extraction Done! '
    e.close
  ENDFOR
  proctime = STRING(ROUND((SYSTIME(1) - starttime )/60.0))
  OK = DIALOG_MESSAGE('全部完成了,用时'+proctime.COMPRESS()+'分钟!',/INFORMATION)
END