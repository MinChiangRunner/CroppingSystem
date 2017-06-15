;计算得到多光谱或全色的角点

PRO GetFourCoor, Fid, coord, igdata
  ;
  ;    file = 'F:\国家测绘局测试数据\资源3号\1 正射校正结果\ZY3_01a_mynnavp_884148_20131026_105447_0007_SASMAC_CHN_sec_rel_001_1310280963_rpcortho.dat'
  COMPILE_OPT idl2

  ;  ENVI_OPEN_FILE, file, r_fid=fid
  IF fid EQ -1 THEN RETURN
  ENVI_FILE_QUERY, fid, dims=dims, ns=ns, nl=nl, nb=nb
  ;获取左上角点的坐标
  FOR i=0L,nl-1 DO BEGIN
    tmpDIMS = [-1, 0, ns-1, i, i]
    ;获取第i行的数据
    tmpDATA = ENVI_GET_DATA(fid=fid, dims=tmpDIMS, pos=0)
    ;找到第一个不为0的像元
    idx = WHERE(tmpDATA NE igdata)
    IF idx[0] EQ -1 THEN CONTINUE
    ;
    leftup = [idx[0], i]
    BREAK
  ENDFOR
  ;PRINT, leftup

  ;获取左下角点的坐标
  FOR i=0L,ns-1 DO BEGIN
    tmpDIMS = [-1, i, i, 0, nl-1]
    ;获取第i行的数据
    tmpDATA = ENVI_GET_DATA(fid=fid, dims=tmpDIMS, pos=0)
    ;找到第一个不为0的像元
    idx = WHERE(tmpDATA NE igdata)
    IF idx[0] EQ -1 THEN CONTINUE
    ;
    leftdown = [i, idx[-1]]
    BREAK
  ENDFOR
  ;PRINT, leftdown

  ;获取右上角点的坐标
  FOR i=ns-1,0L,-1 DO BEGIN
    tmpDIMS = [-1, i, i, 0, nl-1]
    ;获取第i行的数据
    tmpDATA = ENVI_GET_DATA(fid=fid, dims=tmpDIMS, pos=0)
    ;找到第一个不为0的像元
    idx = WHERE(tmpDATA NE igdata)
    IF idx[0] EQ -1 THEN CONTINUE
    ;
    rightup = [i, idx[0]]
    BREAK
  ENDFOR
  ;PRINT, rightup


  ;获取右下角点的坐标
  FOR i=nl-1,0L,-1 DO BEGIN
    tmpDIMS = [-1, 0, ns-1, i, i]
    ;获取第i行的数据
    tmpDATA = ENVI_GET_DATA(fid=fid, dims=tmpDIMS, pos=0)
    ;找到第一个不为0的像元
    idx = WHERE(tmpDATA NE igdata)
    IF idx[0] EQ -1 THEN CONTINUE
    ;
    rightdown = [idx[-1], i]
    BREAK
  ENDFOR
  ;PRINT, rightdown

  ;点的顺序
  ;0 - 1
  ;|   |
  ;3 - 2
  ;转换为地理坐标
  coordFile = [[leftup],[rightup],[rightdown],[leftdown]]
  ENVI_CONVERT_FILE_COORDINATES, fid, $
    coordFile[0,*], coordFile[1,*], xmap, ymap, /to_map


  ;转换为经纬度
  oProj = ENVI_PROJ_CREATE(/GEOGRAPHIC)
  iProj = ENVI_GET_PROJECTION(fid = fid)

  ENVI_CONVERT_PROJECTION_COORDINATES,  $
    xmap, ymap, iProj,    $
    oXgeo, oYgeo, oProj

  coord = [oXgeo, oYgeo]

END