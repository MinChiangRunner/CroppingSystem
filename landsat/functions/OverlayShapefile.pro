PRO OverlayShapefile ,fids,outShapefile, igdatas
  COMPILE_OPT IDL2
  ;    e = envi()
  ;    ;indir = "E:\Landsat\Processing\FLAASH\119040"
  ;    outShapefile = "E:\Landsat\Processing\Range\1180391992Range.shp"
  ;;    indir = 'E:\Landsat\Processing\FLAASH\120040\2014'
  ;;    files = file_search(indir, "*Flaash.dat", /TEST_REGULAR)
  ;    files = ["H:\Landsat\Processing\Completed\118039\1990\Result\SZResult\1180391990NDVISZ.dat", $
  ;      "H:\Landsat\Processing\Completed\118039\1990\Result\SZResult\1180391990NDVISZ.dat"]
  ;    Raster1 = e.OpenRaster(files[0])
  ;    fid1 = ENVIRasterToFID(Raster1)
  ;    Raster2 = e.OpenRaster(files[1])
  ;    fid2 = ENVIRasterToFID(Raster2)
  ;    igdatas=[0,0]
  ;开始计算
  ;初始化进度条
  fid1 = fids[0]
  fid2 = fids[1]
  igdata1 = igdatas[0]
  igdata2 = igdatas[1]
  ENVI_REPORT_INIT, 'Calculating the overlay coordinates...', title="ENVI", $
    base=base
  ENVI_REPORT_INC, base, 4

  ;进度条状态更新
  ENVI_REPORT_STAT, base, 1, 4, CANCEL=cancelvar
  GetFourCoor, Fid1, coord1,igdata1
  ;如果两个文件相同，则只计算四个角点
  IF Fid1 EQ Fid2 THEN BEGIN
    OverlayCoord = coord1
    GOTO, jump1
  ENDIF
  ENVI_REPORT_STAT, base, 2, 4, CANCEL=cancelvar
  GetFourCoor, Fid2, coord2, igdata2
  ENVI_REPORT_STAT, base, 3, 4, CANCEL=cancelvar
  GetOverlayCoord, coord1, coord2, OverlayCoord
  ;
  ;还要判断角点和原始图像四个角点的位置关系
  ;0 - 1
  ;|   |
  ;3 - 2

  ;进度条完成
  JUMP1:
  ENVI_REPORT_INIT, base=base, /finish
  ;
  FirstPoint = OverlayCoord[*,0]
  OverlayCoord = [[OverlayCoord], [FirstPoint]]

  Proj = ENVI_PROJ_CREATE(/GEOGRAPHIC)
  ;

  ;export to  shapefile
  ;新建Shapefile，为polygon类型
  oShp=OBJ_NEW('IDLffShape', outShapefile, /UPDATE, ENTITY_TYPE=5)
  ;创建新实体的结构体 - Create structure for new entity
  entNew = {IDL_SHAPE_ENTITY}

  ;定义实体的值 - Define the values for the new entity
  ;就是定义了一个点，经纬度为[-104,39]
  entNew.SHAPE_TYPE = 5  ;实体类型为1， 即Point
  entNew.VERTICES = PTR_NEW(OverlayCoord)
  entNew.N_VERTICES = 5 ; take out of example, need as workaround

  oShp.PutEntity, entNew
  OBJ_DESTROY, oShp

  prjFile = FILE_DIRNAME(outShapefile) + PATH_SEP() + $
    FILE_BASENAME(outShapefile,'.shp')+'.prj'
  OPENW, lun, prjFile, /GET_LUN
  prjstr = Proj.PE_COORD_SYS_STR
  PRINTF, lun, prjstr
  FREE_LUN, lun
  ;  e.close
  ;  print,"finished"
  ;
  ;  InfoStr = 'Export the overlay Shapefile successfully.'
  ;  !NULL = DIALOG_MESSAGE(['outShapefile: ' + outShapefile, InfoStr], $
  ;    /INFORMATION, title='ENVI Information')
END