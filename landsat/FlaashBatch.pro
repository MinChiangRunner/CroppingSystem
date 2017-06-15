PRO GetElevation, ColRow,Elevation
  COMPILE_OPT idl2
  KEYS = [117039, 118038, 118039, 118040, 118041, 118042, 118043, 119038, $
    119039, 119040, 119041, 119042, 119043, 120037, 120038, 120039, $
    120040, 120041, 120042, 120043, 120044, 121036, 121037, 121038, $
    121039, 121040, 121041, 121042, 121043, 121044, 122036, 122037, $
    122038, 122039, 122040, 122041, 122042, 122043, 122044, 122045, $
    123037, 123038, 123039, 123040, 123041, 123042, 123043, 123044, $
    123045, 124038, 124039, 124040, 124041, 124042, 124043, 124044, $
    124045, 124046, 125037, 125038, 125039, 125040, 125041, 125042, $
    125043, 125044, 125045, 126037, 126038, 126039, 126040, 126041, $
    126042, 126043, 126044, 126045, 127042, 127043, 127044, 128043]
  VALUES = [0.0512, 0.0062, 0.0736, 0.2986, 0.3213, 0.1111, 0.1928, 0.0145, $
    0.1818, 0.3723, 0.6342, 0.4732, 0.2165, 0.0087, 0.0216, 0.3072, $
    0.2909, 0.5174, 0.5892, 0.4315, 0.0859, 0.0584, 0.026, 0.0647, $
    0.1745, 0.057, 0.2408, 0.3648, 0.335, 0.1793, 0.0371, 0.0223, $
    0.2429, 0.1483, 0.277, 0.1999, 0.5284, 0.3304, 0.0719, 0.0627, $
    0.0616, 0.1264, 0.0457, 0.179, 0.1684, 0.3607, 0.4706, 0.1783, $
    0.1551, 0.143, 0.0389, 0.1297, 0.331, 0.4656, 0.3956, 0.1826, $
    0.0661, 0.0569, 0.5347, 0.8028, 0.7743, 0.4588, 0.5005, 0.6313, $
    0.3086, 0.1636, 0.1118, 0.9305, 1.1427, 0.9687, 0.7794, 0.8132, $
    0.8744, 0.5725, 0.3609, 0.3087, 1.1444, 0.7831, 1.0166, 1.4524]

  ElevationHash = hash(keys, values)
  Elevation = Elevationhash[ColRow]
END

PRO FlaashBatch, radiance_file = radiance_file, FlaashDir = FlaashDir ,aerosol_model=aerosol_model, sensor = sensor
  COMPILE_OPT idL2
  e=envi(/current);
  ;  radiance_file='D:\LandSat\Processing\120040\1988\Rad\LT05_L1TP_120040_19881009_20170205_01_T1_MTLRad.dat'
  ;  ;infile='E:\Landsat\Processing\Radiometric\LC81190402014203LGN00Rad.dat'
  ;  FlaashDir = 'D:\LandSat\Processing\120040\1988\Flaash'
  ;  FlaashDir = 'E:\IDL compile\ENVI_FLAASH_Batch_20170320\ENVI_FLAASH_Batch\output'
  ;  infile = 'E:\IDL compile\ENVI_FLAASH_Batch_20170320\ENVI_FLAASH_Batch\data\Landsat_8_OLI_Rad.dat'
  ;输入多光谱辐射亮度数据
  ; radiance_file = infile

  ;大气校正输出结果文件路径
  reflect_file = FlaashDir + path_sep() + $
    file_basename(radiance_file,".dat")+"Flaash.dat"

  ;打开栅格数据，获取元数据信息
  Raster = e.OpenRaster(radiance_file)

  ;数据信息
  nspatial = raster.NCOLUMNS   ;列数
  nlines = raster.NROWS        ;行数
  fid = ENVIRasterToFID(raster)
  ENVI_FILE_QUERY, fid, data_type = data_type;数据类型

  ;获取输入文件后缀 （.dat）
  exten = stregex(radiance_file, '\..+$', /extract)
  ;对应 Rootname for FLAASH files 参数，设置为 Landsat_8_OLI_Rad_
  user_stem_name = FILE_BASENAME(radiance_file, exten)+'_'

  ;对应 Output Directory for FLAASH Files 参数
  ;使用输出路径作为临时路径（不建议使用系统临时路径）
  modtran_directory = FlaashDir
  sensor = Raster.METADATA['sensor type']
  ;获取光谱响应函数路径
  CASE sensor OF
    'Landsat TM':BEGIN
      filter_func_filename = FILEPATH('tm.sli', $
        root_dir=e.ROOT_DIR, subdirectory=['resource','filterfuncs'])
      SWIR = 6 ;
      red = 3 ;
      green = 2 ;0表示undefined，LC8绿波段为第3波段,TM为2
      blue = 0  ;0表示undefined，LC8蓝波段为第2波段,TM为1
      sensor_name = 'Landsat TM5'
      filter_func_file_index = 6
    END
    'Landsat OLI': BEGIN
      filter_func_filename = FILEPATH('landsat8_oli.sli', $
        root_dir=e.ROOT_DIR, subdirectory=['resource','filterfuncs'])
      SWIR = 7; 6
      red = 4
      green = 3 ;0表示undefined，LC8绿波段为第3波段,TM为2
      blue = 2  ;0表示undefined，LC8蓝波段为第2波段,TM为1
      sensor_name = 'Landsat-8 OLI'
      filter_func_file_index = 0
    END
    'Landsat ETM': BEGIN
      filter_func_filename = FILEPATH('tm.sli', $
        root_dir=e.ROOT_DIR, subdirectory=['resource','filterfuncs'])
      SWIR = 6 ;
      red = 3 ;
      green = 2 ;0表示undefined，LC8绿波段为第3波段,TM为2
      blue = 1  ;0表示undefined，LC8蓝波段为第2波段,TM为1
      sensor_name = 'Landsat ETM'
      filter_func_file_index = 12
    END
  ENDCASE
  Colrow = long(FlaashDir.extract('[0-9]{6}'))
  Getelevation, Colrow, Elevation

  ;获取时间信息
  IF OBJ_VALID(raster.TIME) THEN BEGIN
    ;如果元数据中有时间信息，则自动获取
    tmpTimes = STRSPLIT(raster.TIME.ACQUISITION, '-T:Z', /extract)
    year = FIX(tmpTimes[0])
    month = FIX(tmpTimes[1])
    day = FIX(tmpTimes[2])
    gmt = DOUBLE(tmpTimes[3]) + $
      DOUBLE(tmpTimes[4])/60D + DOUBLE(tmpTimes[5])/60D^2
  ENDIF ELSE BEGIN
    ;如果元数据中没有，则手动设置
    year = 2013
    month = 10
    day = 3
    gmt = 2.923418
  ENDELSE

  ;坐标信息
  ref = raster.SPATIALREF
  IF ref NE !NULL THEN BEGIN
    ;如果有坐标系，则自动获取经纬度、分辨率
    pixel_size = (ref.PIXEL_SIZE)[0]
    ref.ConvertFileToMap, nspatial/2, nlines/2, MapX, MapY
    ref.ConvertMapToLonLat, MapX, MapY, longitude, latitude
  ENDIF ELSE BEGIN
    ;如果没有坐标系，则手动设置
    pixel_size = 30.0
    longitude = 117.08846
    latitude = 40.506906
  ENDELSE

  ;*-------根据时间和经纬度选择校正模型
  ;大气模型：0-SAW；1-MLW；2-U.S. Standard；3-SAS；4-MLS；5-T
  ;1-T 2-MLS 4-SAS
  ATMOSPHERE_MODEL = (latitude GE 30)*(month GE 7)*2 + $ ; 纬度30-40 7月-10月
    (latitude GE 30)*(month LT 7)*4 + $ ; 纬度30-40 4月-6月
    (latitude LT 30)*(month GE 7)*1 + $ ; 纬度20-30 7月-10月
    (latitude LT 30)*(month LT 7)*2 ;纬度20-30 4月-6月

  ;获取波长信息
  metadata = Raster.METADATA
  wavelength_units = metadata['WAVELENGTH UNITS']
  lambda = metadata['WAVELENGTH']
  ;fwhm如果没有，可设置值全部为-1，
  ;例如4个波段的多光谱数据，设置为[-1.0, -1.0, -1.0, -1.0]
  IF metadata.HasTag('FWHM') THEN $
    fwhm = metadata['FWHM'] $
  ELSE fwhm = DBLARR(raster.NBANDS)-1.0
  ;缩放系数，如果定标时设置了FLAASH Setting，则设置value=1.0即可。
  input_scale = MAKE_ARRAY(raster.NBANDS, value=1.0, /double)

  ;初始化FLAASH对象
  ;可选关键字如下：
  ; rad_remove FLAASH执行完毕后，自动关闭输入文件
  ; anc_remove FLAASH执行完毕后，自动关闭生成的辅助数据
  ; anc_delete FLAASH执行完毕后，自动关闭并删除辅助数据
  flaash_obj = obj_new('flaash_batch', /anc_delete)

  ;设置大量的输入参数
  flaash_obj->SetProperty, $
    hyper = 0, $ ;设置为1，表示高光谱；设置为0，表示多光谱
    ;
    ; FLAASH工程参数----
    radiance_file = radiance_file, $
    reflect_file = reflect_file, $
    filter_func_filename = filter_func_filename, $
    filter_func_file_index = filter_func_file_index, $
    water_band_choice = 1.13, $;针对进行水汽反演的Jm
    red_channel = red, $   ;0表示undefined，LC8红波段为第4波段,TM为3
    green_channel = green, $ ;0表示undefined，LC8绿波段为第3波段,TM为2
    blue_channel = blue, $  ;0表示undefined，LC8蓝波段为第2波段,TM为1

    ;水汽反演，没有所需波段，所以设置为0，表示undefined
    ;分别对应Multispectral Setting中Water Retrieval选项卡中的两个参数
    water_retrieval = 0, $ ;Water Retrieval参数。0表示No，1表示Yes
    water_abs_channel = 0, $
    water_ref_channel = 0, $

    ;气溶胶反演----
    ;对应Multispectral Setting中Kaufman-Tanre Aerosol Retrieval选项卡中的参数
    kt_upper_channel = swir, $ ;设置短波红外2（SWIR 2）
    kt_lower_channel = red, $ ;设置红波段（Red）
    kt_cutoff = 0.08, $ ;Maximum Upper Channel Reflectance
    kt_ratio = 0.500, $ ;Reflectance Ratio
    cirrus_channel = 0, $  ;0表示undefined

    ;前边已经定义
    user_stem_name = user_stem_name, $
    modtran_directory = modtran_directory, $
    ;
    ; MODTRAN参数---
    visvalue = 40.0000, $ ;能见度，默认40km

    ;为了进行水汽反演，需要如下3个波段范围中的一个：
    ; 1050-1210nm, 770-870nm, 870-1020nm
    ; 而且要求此范围的波段光谱分辨率最低为15nm
    f_resolution = 15.0000, $

    ;时间信息----
    day = day, $
    month = month, $
    year = year, $
    gmt = gmt, $
    latitude = latitude, $
    longitude = longitude, $
    sensor_altitude = 705.0000, $ ;传感器高度
    ground_elevation = Elevation, $ ;平均海拔，单位km

    ;分别对应 Advanced Setting 中的同名参数，默认即可
    view_zenith_angle = 180.0000, $
    view_azimuth = 0.0000, $

    ;大气模型：0-SAW；1-MLW；2-U.S. Standard；3-SAS；4-MLS；5-T
    atmosphere_model = atmosphere_model, $ ;atmosphere_model, $
    ;气溶胶模型：0-No Aerosol；1-Rural；2-Maritime；3-Urban；4-Tropospheric
    ;1-Rural 5-Urban 4-Maritime
    aerosol_model = aerosol_model, $

    ;如下几个参数对应 Advanced Setting同名参数，默认即可。
    multiscatter_model = 2, $;需要修改
    disort_streams = 8, $
    co2mix = 390.0000, $
    water_column_multiplier = 1.0000, $
    ;
    ;图像参数----
    nspatial = nspatial, $
    nlines = nlines, $
    data_type = data_type, $
    margin1 = 0, $
    margin2 = 0, $
    nskip = 0, $
    pixel_size = pixel_size, $
    sensor_name = sensor_name, $

    ;分析参数----
    ;对应Advanced Setting中的 Aerosol Scale Height 原始为2
    aerosol_scaleht = 1.5000, $
    ;对应Advanced Setting中的 Use Adjacency Correction
    ;中高分辨率设置为1，低分辨率（如Modis）设置为0
    use_adjacency = 1, $

    ;输出缩放系数，输出结果放大了10000倍，变为UINT数据类型。
    ;对应Advanced Setting中的Output Reflectance Scale Factor
    output_scale = 10000.0000, $ ;输出结果缩放系数

    ;对应 Width (number of bands) 参数，多光谱设置0即可。
    polishing_res = 0, $

    ;对应 Aerosol Retrieval 参数。
    ; 0 表示 None；1 表示 2-Band (K-T)；2 表示 2-Band Over Water
    aerosol_retrieval = 1, $

    ;对应FLAASH面板中的 Wavelength Recalibration，多光谱一般为0
    calc_wl_correction = 0, $
    reuse_modtran_calcs = 0, $
    use_square_slit_function = 0, $
    convolution_method = 'fft', $

    ;对应Advanced Setting中的 Use Tiled Processing
    ;1-Yes；0-No
    use_tiling = 1, $
    tile_size = 500.0000, $

    ; Spectral Parameters
    wavelength_units = wavelength_units, $
    lambda = lambda, $
    fwhm = fwhm, $
    input_scale = input_scale

  ;重要！！！！！！重要！！！！！！重要！！！！！
  ;执行FLAASH之前，必须在ENVI中把输入文件关闭
  Raster.Close

  ;开始执行FLAASH
  flaash_obj->processImage

  ;获取输入输出文件的FID
  flaash_obj->getResults, rad_fid=rad_fid, reflect_fid=reflect_fid

END