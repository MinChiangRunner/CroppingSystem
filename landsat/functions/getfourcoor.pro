;����õ�����׻�ȫɫ�Ľǵ�

PRO GetFourCoor, Fid, coord, igdata
  ;
  ;    file = 'F:\���Ҳ��ֲ�������\��Դ3��\1 ����У�����\ZY3_01a_mynnavp_884148_20131026_105447_0007_SASMAC_CHN_sec_rel_001_1310280963_rpcortho.dat'
  COMPILE_OPT idl2

  ;  ENVI_OPEN_FILE, file, r_fid=fid
  IF fid EQ -1 THEN RETURN
  ENVI_FILE_QUERY, fid, dims=dims, ns=ns, nl=nl, nb=nb
  ;��ȡ���Ͻǵ������
  FOR i=0L,nl-1 DO BEGIN
    tmpDIMS = [-1, 0, ns-1, i, i]
    ;��ȡ��i�е�����
    tmpDATA = ENVI_GET_DATA(fid=fid, dims=tmpDIMS, pos=0)
    ;�ҵ���һ����Ϊ0����Ԫ
    idx = WHERE(tmpDATA NE igdata)
    IF idx[0] EQ -1 THEN CONTINUE
    ;
    leftup = [idx[0], i]
    BREAK
  ENDFOR
  ;PRINT, leftup

  ;��ȡ���½ǵ������
  FOR i=0L,ns-1 DO BEGIN
    tmpDIMS = [-1, i, i, 0, nl-1]
    ;��ȡ��i�е�����
    tmpDATA = ENVI_GET_DATA(fid=fid, dims=tmpDIMS, pos=0)
    ;�ҵ���һ����Ϊ0����Ԫ
    idx = WHERE(tmpDATA NE igdata)
    IF idx[0] EQ -1 THEN CONTINUE
    ;
    leftdown = [i, idx[-1]]
    BREAK
  ENDFOR
  ;PRINT, leftdown

  ;��ȡ���Ͻǵ������
  FOR i=ns-1,0L,-1 DO BEGIN
    tmpDIMS = [-1, i, i, 0, nl-1]
    ;��ȡ��i�е�����
    tmpDATA = ENVI_GET_DATA(fid=fid, dims=tmpDIMS, pos=0)
    ;�ҵ���һ����Ϊ0����Ԫ
    idx = WHERE(tmpDATA NE igdata)
    IF idx[0] EQ -1 THEN CONTINUE
    ;
    rightup = [i, idx[0]]
    BREAK
  ENDFOR
  ;PRINT, rightup


  ;��ȡ���½ǵ������
  FOR i=nl-1,0L,-1 DO BEGIN
    tmpDIMS = [-1, 0, ns-1, i, i]
    ;��ȡ��i�е�����
    tmpDATA = ENVI_GET_DATA(fid=fid, dims=tmpDIMS, pos=0)
    ;�ҵ���һ����Ϊ0����Ԫ
    idx = WHERE(tmpDATA NE igdata)
    IF idx[0] EQ -1 THEN CONTINUE
    ;
    rightdown = [idx[-1], i]
    BREAK
  ENDFOR
  ;PRINT, rightdown

  ;���˳��
  ;0 - 1
  ;|   |
  ;3 - 2
  ;ת��Ϊ��������
  coordFile = [[leftup],[rightup],[rightdown],[leftdown]]
  ENVI_CONVERT_FILE_COORDINATES, fid, $
    coordFile[0,*], coordFile[1,*], xmap, ymap, /to_map


  ;ת��Ϊ��γ��
  oProj = ENVI_PROJ_CREATE(/GEOGRAPHIC)
  iProj = ENVI_GET_PROJECTION(fid = fid)

  ENVI_CONVERT_PROJECTION_COORDINATES,  $
    xmap, ymap, iProj,    $
    oXgeo, oYgeo, oProj

  coord = [oXgeo, oYgeo]

END