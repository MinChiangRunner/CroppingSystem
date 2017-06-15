pro GDGXchong
  compile_opt idl2
  filedirs = $
    ["H:\LandSat\4-24GX\124044\1990\Result\SZResult", $
    "H:\LandSat\4-24GX\124045\1992\Result\SZResult", $
    "H:\LandSat\4-24GX\125043\1991\Result\SZResult", $
    "H:\LandSat\4-24GX\125044\1992\Result\SZResult", $
    "H:\LandSat\4-24GX\125045\1992\Result\SZResult", $
    "H:\LandSat\4-24GX\126043\1990\Result\SZResult", $
    "H:\LandSat\4-24GX\126044\1992\Result\SZResult", $
    "H:\LandSat\4-24GX\126045\1989\Result\SZResult", $
    "H:\LandSat\4-24GX\127043\1992\Result\SZResult", $
    "H:\LandSat\4-24GD\121044\1989\Result\SZResult", $
    "H:\LandSat\4-24GD\122044\1992\Result\SZResult", $
    "H:\LandSat\4-24GD\122045\1992\Result\SZResult", $
    "H:\LandSat\4-24GD\123044\1992\Result\SZResult", $
    "H:\LandSat\4-24GD\123045\1992\Result\SZResult", $
    "H:\LandSat\4-24GD\124046\1990\Result\SZResult" $
    ]
    
    ;水稻掩膜文件
  Paddymask2010 = 'E:\Landsat\landsatBase\PaddyMask\2010\study_area_2010_Project.shp'
  PaddymaskCommon = 'E:\Landsat\landsatBase\PaddyMask\CommonPaddy\COMMON_PADDY_wgs.shp'
  paddymask2000 = 'E:\Landsat\landsatBase\PaddyMask\2000\study_area_paddy_2000_Project.shp'
  profix = 'mask2000.tif'
  foreach files, filedirs do begin
    file = file_search(files,"*NDVISZ.dat")
    arg1 = STRJOIN(file.split('\\'),"/")
    arg2 = Paddymask2000

    ;output files
    arg3 = strmid(arg1,0,strpos(arg1,"/",/REVERSE_SEARCH))+"/"+ $
      file_basename(arg1,'.dat')  + profix
    cmd = strjoin(["py -2 E:\\Landsat\\Processing\\Extraction.py",arg1,arg2,arg3]," ")
    spawn, cmd

    ;以共同水稻为掩膜
    arg2 = PaddymaskCommon
    arg3 = strmid(arg1,0,strpos(arg1,"/",/REVERSE_SEARCH))+"/"+ $
      file_basename(arg1,'.dat')  + 'maskcommon.tif'
    cmd = strjoin(["py -2 E:\\Landsat\\Processing\\Extraction.py",arg1,arg2,arg3]," ")
    spawn, cmd
  endforeach
 print, "完成"
end