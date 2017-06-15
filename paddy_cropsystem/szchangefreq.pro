PRO SZChangeFreq
  COMPILE_OPT idl2
  e = ENVI(/headless)
  indir = 'E:\paddy_extr\Processing\SZFinal\360I180SZPaddy'
  files = FILE_SEARCH(indir,'*.dat',count=n,/TEST_REGULAR)

  Changefreq =!NULL
  nfreq =!NULL
  
  FOR i=0, n-2 DO BEGIN
    raster= e.OpenRaster(files[i])
    data1 = raster.getdata()

    raster= e.OpenRaster(files[i+1])
    data2 = raster.getdata()
   
    ;3 ÏÀ„¡Ω Ï
    data1[where(data1 EQ 3)]= 2
    data2[where(data2 EQ 3)]= 2
    jz = data2 - data1
    FR = data2*10 + data1
    Changefreq = [[Changefreq], [FR]]
    nfreq = [[nfreq],[jz]]

    data1 =!NULL
    data2 =!NULL
  ENDFOR
  
  Changefreq = reform(Changefreq,4014,3463,12)
  nfreq = reform(nfreq,4014,3463,12)
  num = MAKE_ARRAY(4014,3463,/BYTE)
  
  FOR i =0, 4014-1 DO BEGIN
    FOR j=0, 3463-1 DO BEGIN
      !NULL = where(nfreq[i,j,*], count)
      num[i,j]=byte(count)
    ENDFOR
  ENDFOR
  
  numraster = ENVIRaster(num, $
    URI='E:\paddy_extr\Processing\SZFinal\Analysis\ChangeFreq.dat', $
    SPATIALREF=raster.SPATIALREF)
  numraster.save
  Matrixraster = ENVIRaster(Changefreq, $
    URI='E:\paddy_extr\Processing\SZFinal\Analysis\TransMatrix.dat', $
    SPATIALREF=raster.SPATIALREF)
  Matrixraster.save
END