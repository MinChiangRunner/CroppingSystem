PRO copyfile
  COMPILE_OPT idl2
  ;  files = file_search("H:\Landsat\Results\1990s\NewNDVI", "*NDVIDiff.*",count=n,/TEST_REGULAR)
  ;  FOREACH file ,files DO BEGIN
  ;    pf = file.split('\\')
  ;    destdir  = "E:\Landsat\Processing\1990s\" + pf[-5:-2].join('\\')
  ;    destfile = "E:\Landsat\Processing\1990s\" + pf[-5:-1].join('\\')
  ;    IF ~FILE_TEST(destdir) THEN file_mkdir, destdir
  ;    spawn,"copy " + file + " " + destfile
  ;  ENDFOREACH
  ;  print, "finish"
  ;  seqs = [1, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    1, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    1, $
  ;    2, $
  ;    2, $
  ;    1, $
  ;    1, $
  ;    1, $
  ;    1, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    1, $
  ;    1, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    1, $
  ;    1, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    1, $
  ;    2, $
  ;    1, $
  ;    1, $
  ;    2, $
  ;    1, $
  ;    1, $
  ;    1, $
  ;    1, $
  ;    1, $
  ;    2, $
  ;    2, $
  ;    2, $
  ;    1, $
  ;    1, $
  ;    1, $
  ;    1, $
  ;    1, $
  ;    2, $
  ;    2, $
  ;    1, $
  ;    2, $
  ;    2, $
  ;    1, $
  ;    1, $
  ;    1, $
  ;    2]
  ;
  ;  files = file_search("E:\Landsat\Processing\1990s","*NDVIDiff.dat",/TEST_REGULAR)
  ;  i=0
  ;
  ;  FOREACH file, files DO BEGIN
  ;    e = envi(/headless)
  ;    print, i
  ;    SEQ = seqs[i]
  ;    ; landsatndvidiff, FlaashDir = file_dirname(file_dirname(file)), seq = seq[i]
  ;    NDVISZOUTdir = file_dirname(file_dirname(file)) + "\SZResult"
  ;    Basename = FILE_BASENAME(file,".dat")
  ;    NDVISZOUTFILE =  NDVISZOUTdir + "\"+Basename.extract("[0-9]{10}NDVI") + "SZ0.1.dat"
  ;    file_mkdir, NDVISZOUTdir
  ;    rasterdiff = e.openraster(file)
  ;    diffid = ENVIRasterToFID(rasterdiff)
  ;    ENVI_FILE_QUERY, diffid, DIMS = dims
  ;    ;'(b1 le 0)*1 + (b1 gt 0)*2'
  ;    IF (SEQ EQ 1) THEN EXP = '(b1 le -0.1)*1 + (b1 gt 0.1)*2' ELSE $
  ;      EXP = '(b1 le -0.1)*2 + (b1 gt 0.1)*1'
  ;    ENVI_Doit, 'Math_Doit', $
  ;      FID = [diffid], $
  ;      DIMS = dims, $
  ;      POS = [0], $
  ;      EXP = EXP, $
  ;      OUT_NAME = NDVISZOUTFILE, $
  ;      R_FID = szfid
  ;    profix = 'mask1990.tif'
  ;    arg1 = STRJOIN(NDVISZOUTFILE.split('\\'),"/")
  ;    arg2 = 'E:\Landsat\landsatBase\PaddyMask\WBFPaddyMask1990.tif'
  ;    ;output files
  ;    arg3 = strmid(arg1,0,strpos(arg1,"/",/REVERSE_SEARCH))+"/"+ $
  ;      file_basename(arg1,'.dat')  + profix
  ;    cmd = strjoin(["py -2 E:\\Landsat\\PythonCode\\Extraction.py",arg1,arg2,arg3]," ")
  ;    spawn, cmd
  ;    i = i+1
  ;    e.close
  ;  ENDFOREACH

;  files = file_search("E:\Landsat\Processing\1990s","*NDVISZ0.1*",count=n,/TEST_REGULAR)
;  FOREACH file ,files DO BEGIN
;    basename=file_basename(file)
;    Title= basename.extract("[0-9]{6}")
;    year = strmid(basename,6,4)
;    dest = "H:\Landsat\Results\1990s\NewNDVI\"+Title+"\"+year+"\Result\SZResult"
;    ;destfile = dest + "\" + basename
;    spawn,"copy " + file + " " + dest
;  ENDFOREACH
;  print, "finish"
;  print,"finished"
END