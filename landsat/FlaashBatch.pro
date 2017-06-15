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
  ;�������׷�����������
  ; radiance_file = infile

  ;����У���������ļ�·��
  reflect_file = FlaashDir + path_sep() + $
    file_basename(radiance_file,".dat")+"Flaash.dat"

  ;��դ�����ݣ���ȡԪ������Ϣ
  Raster = e.OpenRaster(radiance_file)

  ;������Ϣ
  nspatial = raster.NCOLUMNS   ;����
  nlines = raster.NROWS        ;����
  fid = ENVIRasterToFID(raster)
  ENVI_FILE_QUERY, fid, data_type = data_type;��������

  ;��ȡ�����ļ���׺ ��.dat��
  exten = stregex(radiance_file, '\..+$', /extract)
  ;��Ӧ Rootname for FLAASH files ����������Ϊ Landsat_8_OLI_Rad_
  user_stem_name = FILE_BASENAME(radiance_file, exten)+'_'

  ;��Ӧ Output Directory for FLAASH Files ����
  ;ʹ�����·����Ϊ��ʱ·����������ʹ��ϵͳ��ʱ·����
  modtran_directory = FlaashDir
  sensor = Raster.METADATA['sensor type']
  ;��ȡ������Ӧ����·��
  CASE sensor OF
    'Landsat TM':BEGIN
      filter_func_filename = FILEPATH('tm.sli', $
        root_dir=e.ROOT_DIR, subdirectory=['resource','filterfuncs'])
      SWIR = 6 ;
      red = 3 ;
      green = 2 ;0��ʾundefined��LC8�̲���Ϊ��3����,TMΪ2
      blue = 0  ;0��ʾundefined��LC8������Ϊ��2����,TMΪ1
      sensor_name = 'Landsat TM5'
      filter_func_file_index = 6
    END
    'Landsat OLI': BEGIN
      filter_func_filename = FILEPATH('landsat8_oli.sli', $
        root_dir=e.ROOT_DIR, subdirectory=['resource','filterfuncs'])
      SWIR = 7; 6
      red = 4
      green = 3 ;0��ʾundefined��LC8�̲���Ϊ��3����,TMΪ2
      blue = 2  ;0��ʾundefined��LC8������Ϊ��2����,TMΪ1
      sensor_name = 'Landsat-8 OLI'
      filter_func_file_index = 0
    END
    'Landsat ETM': BEGIN
      filter_func_filename = FILEPATH('tm.sli', $
        root_dir=e.ROOT_DIR, subdirectory=['resource','filterfuncs'])
      SWIR = 6 ;
      red = 3 ;
      green = 2 ;0��ʾundefined��LC8�̲���Ϊ��3����,TMΪ2
      blue = 1  ;0��ʾundefined��LC8������Ϊ��2����,TMΪ1
      sensor_name = 'Landsat ETM'
      filter_func_file_index = 12
    END
  ENDCASE
  Colrow = long(FlaashDir.extract('[0-9]{6}'))
  Getelevation, Colrow, Elevation

  ;��ȡʱ����Ϣ
  IF OBJ_VALID(raster.TIME) THEN BEGIN
    ;���Ԫ��������ʱ����Ϣ�����Զ���ȡ
    tmpTimes = STRSPLIT(raster.TIME.ACQUISITION, '-T:Z', /extract)
    year = FIX(tmpTimes[0])
    month = FIX(tmpTimes[1])
    day = FIX(tmpTimes[2])
    gmt = DOUBLE(tmpTimes[3]) + $
      DOUBLE(tmpTimes[4])/60D + DOUBLE(tmpTimes[5])/60D^2
  ENDIF ELSE BEGIN
    ;���Ԫ������û�У����ֶ�����
    year = 2013
    month = 10
    day = 3
    gmt = 2.923418
  ENDELSE

  ;������Ϣ
  ref = raster.SPATIALREF
  IF ref NE !NULL THEN BEGIN
    ;���������ϵ�����Զ���ȡ��γ�ȡ��ֱ���
    pixel_size = (ref.PIXEL_SIZE)[0]
    ref.ConvertFileToMap, nspatial/2, nlines/2, MapX, MapY
    ref.ConvertMapToLonLat, MapX, MapY, longitude, latitude
  ENDIF ELSE BEGIN
    ;���û������ϵ�����ֶ�����
    pixel_size = 30.0
    longitude = 117.08846
    latitude = 40.506906
  ENDELSE

  ;*-------����ʱ��;�γ��ѡ��У��ģ��
  ;����ģ�ͣ�0-SAW��1-MLW��2-U.S. Standard��3-SAS��4-MLS��5-T
  ;1-T 2-MLS 4-SAS
  ATMOSPHERE_MODEL = (latitude GE 30)*(month GE 7)*2 + $ ; γ��30-40 7��-10��
    (latitude GE 30)*(month LT 7)*4 + $ ; γ��30-40 4��-6��
    (latitude LT 30)*(month GE 7)*1 + $ ; γ��20-30 7��-10��
    (latitude LT 30)*(month LT 7)*2 ;γ��20-30 4��-6��

  ;��ȡ������Ϣ
  metadata = Raster.METADATA
  wavelength_units = metadata['WAVELENGTH UNITS']
  lambda = metadata['WAVELENGTH']
  ;fwhm���û�У�������ֵȫ��Ϊ-1��
  ;����4�����εĶ�������ݣ�����Ϊ[-1.0, -1.0, -1.0, -1.0]
  IF metadata.HasTag('FWHM') THEN $
    fwhm = metadata['FWHM'] $
  ELSE fwhm = DBLARR(raster.NBANDS)-1.0
  ;����ϵ�����������ʱ������FLAASH Setting��������value=1.0���ɡ�
  input_scale = MAKE_ARRAY(raster.NBANDS, value=1.0, /double)

  ;��ʼ��FLAASH����
  ;��ѡ�ؼ������£�
  ; rad_remove FLAASHִ����Ϻ��Զ��ر������ļ�
  ; anc_remove FLAASHִ����Ϻ��Զ��ر����ɵĸ�������
  ; anc_delete FLAASHִ����Ϻ��Զ��رղ�ɾ����������
  flaash_obj = obj_new('flaash_batch', /anc_delete)

  ;���ô������������
  flaash_obj->SetProperty, $
    hyper = 0, $ ;����Ϊ1����ʾ�߹��ף�����Ϊ0����ʾ�����
    ;
    ; FLAASH���̲���----
    radiance_file = radiance_file, $
    reflect_file = reflect_file, $
    filter_func_filename = filter_func_filename, $
    filter_func_file_index = filter_func_file_index, $
    water_band_choice = 1.13, $;��Խ���ˮ�����ݵ�Jm
    red_channel = red, $   ;0��ʾundefined��LC8�첨��Ϊ��4����,TMΪ3
    green_channel = green, $ ;0��ʾundefined��LC8�̲���Ϊ��3����,TMΪ2
    blue_channel = blue, $  ;0��ʾundefined��LC8������Ϊ��2����,TMΪ1

    ;ˮ�����ݣ�û�����貨�Σ���������Ϊ0����ʾundefined
    ;�ֱ��ӦMultispectral Setting��Water Retrievalѡ��е���������
    water_retrieval = 0, $ ;Water Retrieval������0��ʾNo��1��ʾYes
    water_abs_channel = 0, $
    water_ref_channel = 0, $

    ;���ܽ�����----
    ;��ӦMultispectral Setting��Kaufman-Tanre Aerosol Retrievalѡ��еĲ���
    kt_upper_channel = swir, $ ;���ö̲�����2��SWIR 2��
    kt_lower_channel = red, $ ;���ú첨�Σ�Red��
    kt_cutoff = 0.08, $ ;Maximum Upper Channel Reflectance
    kt_ratio = 0.500, $ ;Reflectance Ratio
    cirrus_channel = 0, $  ;0��ʾundefined

    ;ǰ���Ѿ�����
    user_stem_name = user_stem_name, $
    modtran_directory = modtran_directory, $
    ;
    ; MODTRAN����---
    visvalue = 40.0000, $ ;�ܼ��ȣ�Ĭ��40km

    ;Ϊ�˽���ˮ�����ݣ���Ҫ����3�����η�Χ�е�һ����
    ; 1050-1210nm, 770-870nm, 870-1020nm
    ; ����Ҫ��˷�Χ�Ĳ��ι��׷ֱ������Ϊ15nm
    f_resolution = 15.0000, $

    ;ʱ����Ϣ----
    day = day, $
    month = month, $
    year = year, $
    gmt = gmt, $
    latitude = latitude, $
    longitude = longitude, $
    sensor_altitude = 705.0000, $ ;�������߶�
    ground_elevation = Elevation, $ ;ƽ�����Σ���λkm

    ;�ֱ��Ӧ Advanced Setting �е�ͬ��������Ĭ�ϼ���
    view_zenith_angle = 180.0000, $
    view_azimuth = 0.0000, $

    ;����ģ�ͣ�0-SAW��1-MLW��2-U.S. Standard��3-SAS��4-MLS��5-T
    atmosphere_model = atmosphere_model, $ ;atmosphere_model, $
    ;���ܽ�ģ�ͣ�0-No Aerosol��1-Rural��2-Maritime��3-Urban��4-Tropospheric
    ;1-Rural 5-Urban 4-Maritime
    aerosol_model = aerosol_model, $

    ;���¼���������Ӧ Advanced Settingͬ��������Ĭ�ϼ��ɡ�
    multiscatter_model = 2, $;��Ҫ�޸�
    disort_streams = 8, $
    co2mix = 390.0000, $
    water_column_multiplier = 1.0000, $
    ;
    ;ͼ�����----
    nspatial = nspatial, $
    nlines = nlines, $
    data_type = data_type, $
    margin1 = 0, $
    margin2 = 0, $
    nskip = 0, $
    pixel_size = pixel_size, $
    sensor_name = sensor_name, $

    ;��������----
    ;��ӦAdvanced Setting�е� Aerosol Scale Height ԭʼΪ2
    aerosol_scaleht = 1.5000, $
    ;��ӦAdvanced Setting�е� Use Adjacency Correction
    ;�и߷ֱ�������Ϊ1���ͷֱ��ʣ���Modis������Ϊ0
    use_adjacency = 1, $

    ;�������ϵ�����������Ŵ���10000������ΪUINT�������͡�
    ;��ӦAdvanced Setting�е�Output Reflectance Scale Factor
    output_scale = 10000.0000, $ ;����������ϵ��

    ;��Ӧ Width (number of bands) ���������������0���ɡ�
    polishing_res = 0, $

    ;��Ӧ Aerosol Retrieval ������
    ; 0 ��ʾ None��1 ��ʾ 2-Band (K-T)��2 ��ʾ 2-Band Over Water
    aerosol_retrieval = 1, $

    ;��ӦFLAASH����е� Wavelength Recalibration�������һ��Ϊ0
    calc_wl_correction = 0, $
    reuse_modtran_calcs = 0, $
    use_square_slit_function = 0, $
    convolution_method = 'fft', $

    ;��ӦAdvanced Setting�е� Use Tiled Processing
    ;1-Yes��0-No
    use_tiling = 1, $
    tile_size = 500.0000, $

    ; Spectral Parameters
    wavelength_units = wavelength_units, $
    lambda = lambda, $
    fwhm = fwhm, $
    input_scale = input_scale

  ;��Ҫ��������������Ҫ��������������Ҫ����������
  ;ִ��FLAASH֮ǰ��������ENVI�а������ļ��ر�
  Raster.Close

  ;��ʼִ��FLAASH
  flaash_obj->processImage

  ;��ȡ��������ļ���FID
  flaash_obj->getResults, rad_fid=rad_fid, reflect_fid=reflect_fid

END