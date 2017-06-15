PRO landsatNDVIminsLSWI
  COMPILE_OPT IDL2
  ;indir = "E:\Landsat\Processing\FLAASH\119040"
  indir = 'E:\Landsat\Processing\FLAASH\119040\1991'
  files = file_search(indir, "LT05_L1TP_119040_19910824_20170125_01_T1_MTLRadFlaash.dat", /TEST_REGULAR)
  ;outdir = "E:\Landsat\Processing\VI\119040\1992"
  LswiFile = "E:\Landsat\Processing\VI\119040\1991\Flaash_con\LSWI\L51991JULY-AUG-OTC-STACKlswI_subset.dat"
  NDVIfile = "E:\Landsat\Processing\VI\119040\1991\Flaash_con\NDVI\L51991JULY-AUG-OTC-STACKNDVI.dat"
  outdir = "E:\Landsat\Processing\VI\119040\1991\Flaash_con\NDVI-LSWI"
  e = envi(/headless)

  LswiRaster = e.OpenRaster(LswiFile)
  NDVIRaster = e.OpenRaster(NDVIfile)
  ;FOREACH file, files DO BEGIN
  SPATIALREF = NDVIRaster.SPATIALREF

  ;    outfile = outdir + path_sep()+ $
  ;      file_basename(file,".dat")+"NDVI.tif"
  ;    NDVIImage = ENVISpectralIndexRaster(raster, 'NDVI')
  ;    NDVIImage.Export, outfile, 'tiff'

  LSWI = LswiRaster.getdata()
  NDVI = NDVIRaster.GETDATA()
  DIFNLRatio = (NDVI - LSWI)/(NDVI + LSWI)
  DIFNLValue = (NDVI - LSWI)
  Recl = (LSWI[*,*,0] - LSWI[*,*,2])/(NDVI[*,*,2] - NDVI[*,*,2])
  OUTFILE = OUTDIR+'\1991FlaashDIFNL.dat'
  DIFNLRaster = ENVIRaster(DIFNL, URI= outfile, SPATIALREF= SPATIALREF)
  DIFNLRaster.Save
  
  OUTFILE = OUTDIR+'\1991FlaashDIFNLValue.dat'
  DIFNLRaster = ENVIRaster(DIFNLValue, URI= outfile, SPATIALREF= SPATIALREF)
  DIFNLRaster.Save
;
  e.close
  print,'finished'

END