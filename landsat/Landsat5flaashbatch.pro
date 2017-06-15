PRO Landsat5FlaashBatch, radiance_file = radiance_file, outdir = outdir
  COMPILE_OPT idL2
  e=envi(/current);
  ;�������׷�����������
  ;radiance_file ='E:\Landsat\Processing\Radiometric\119040\1991\LT05_L1TP_119040_19910723_20170126_01_T1_MTL111Rad.dat'
  ;  radiance_file ='E:\Landsat\Processing\Radiometric\119040\1991\LT0511904019910723Rad.dat'
  ;  outdir = 'E:\Landsat\Processing\FLAASH\119040'

  ;����У���������ļ�·��
  reflect_file = Outdir + path_sep() + $
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
  modtran_directory = Outdir
  sensor = Raster.METADATA['sensor type']
  ;��ȡ������Ӧ����·��
  filter_func_filename = FILEPATH('tm.sli', $
    root_dir=e.ROOT_DIR, subdirectory=['classic','filt_func'])
  SWIR = 6 ;
  red = 3 ;
  green = 2 ;0��ʾundefined��LC8�̲���Ϊ��3����,TMΪ2
  blue = 1  ;0��ʾundefined��LC8������Ϊ��2����,TMΪ1
  sensor_name = 'Landsat TM5'
  ;filter_func_file_index = 6
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
  ;����ģ�ͣ�0-SAW��1-MLW��2-U.S. Standard��3-SAS��4-MLS��5-T �����������
  ;1-T 2-MLS 3-SAS
  atmosphere_model = (latitude GE 30)*(month GE 7)*2 + $ ; γ��30-40 7��-10��
    (latitude GE 30)*(month LT 7)*3 + $ ; γ��30-40 4��-6��
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
    filter_func_file_index = 6, $
    water_band_choice = 1.13, $;��Խ���ˮ�����ݵ�Jm
    red_channel = 3, $   ;0��ʾundefined��LC8�첨��Ϊ��4����,TMΪ3
    green_channel = 2, $ ;0��ʾundefined��LC8�̲���Ϊ��3����,TMΪ2
    blue_channel = 1, $  ;0��ʾundefined��LC8������Ϊ��2����,TMΪ1

    ;ˮ�����ݣ�û�����貨�Σ���������Ϊ0����ʾundefined
    ;�ֱ��ӦMultispectral Setting��Water Retrievalѡ��е���������
    water_retrieval = 0, $ ;Water Retrieval������0��ʾNo��1��ʾYes
    water_abs_channel = 0, $
    water_ref_channel = 0, $

    ;���ܽ�����----
    ;��ӦMultispectral Setting��Kaufman-Tanre Aerosol Retrievalѡ��еĲ���
    kt_upper_channel = 6, $ ;���ö̲�����2��SWIR 2��
    kt_lower_channel = 3, $ ;���ú첨�Σ�Red��
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
    ground_elevation = 0.372, $ ;ƽ�����Σ���λkm

    ;�ֱ��Ӧ Advanced Setting �е�ͬ��������Ĭ�ϼ���
    view_zenith_angle = 180.0000, $
    view_azimuth = 0.0000, $

    ;����ģ�ͣ�0-SAW��1-MLW��2-U.S. Standard��3-SAS��4-MLS��5-T
    atmosphere_model = 1, $ ;atmosphere_model, $
    ;���ܽ�ģ�ͣ�0-No Aerosol��1-Rural��2-Maritime��3-Urban��4-Tropospheric
    aerosol_model = 1, $

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
    tile_size = 200.0000, $

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