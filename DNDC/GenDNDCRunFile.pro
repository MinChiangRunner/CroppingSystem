;+
; :AUTHOR: chiangmin
;-rowcolnums: ��ˮ������դ������кţ��ҵ���Ӧ����������ֵ����ȡ��������
PRO GenSoilData, rowcolnum = rowcolnum, outdir = outdir
  COMPILE_OPT idl2

  ;��ȡ�����ռ�����
  SoilMapfile = "E:\DNDC\SoilData\Int_HWSD_CEQ_SD.tif"
  SoilMap = read_tiff(SoilMapfile)

  ; ��ȡ����������
  soilindex = "E:\DNDC\SoilData\soilIndex.txt"
  soillibr = make_array(11,936)
  openR,lun,soilindex,/get_lun
  readf,lun,soillibr
  free_lun,lun

  ;���
  ;SoilMapdim = size(soilmap)
  ;FOR j = 0, SoilMapdim[2]-1 DO BEGIN
  ;  FOR i = 0, SoilMapdim[1]-1 DO BEGIN
  ;   IF ((soilmap[i,j] GE 11000) AND (soilmap[i,j] LE 11934 )) THEN BEGIN
  ;    FOREACH rowcolnum, rowcolnums DO BEGIN

  ;�����ض�ֵ����������
  soilattri = soillibr[*, where(soillibr[0,*] EQ soilmap[rowcolnum])]
  ;soilattri = soillibr[*, where(soillibr[0,*] EQ soilmap[i,j])]
  ;soilmapxx = 11000
  ;soilattri = soillibr[*, where(soillibr[0,*] EQ soilmapxx)]
  ;i =399
  ;j = 460

  ;�����������
  ;GridNum = j * SoilMapdim[1] + i
  outfile = outdir + "SC" + string(rowcolnum,format="(I07)") + ".dnd"
  ;outfile = "E:\DNDC\SoilData\test.txt"
  openU, lun, outfile, /GET_LUN, /APPEND
  printf,lun,"----------------------------------------"
  printf,lun,"Soil_data                               "
  printf,lun,""
  printf,lun,format="(A-61,I10)","__Land_use_ID                   ", 2
  printf,lun,format="(A-61,I10)","__Soil_texture_ID               ",soilattri[1]
  printf,lun,format="(A-61,F10.4)","__Bulk_density                  ",soilattri[2]
  printf,lun,format="(A-61,F10.4)","__pH                            ",soilattri[3]
  printf,lun,format="(A-61,F10.4)","__Clay_fraction                 ",soilattri[4]
  printf,lun,format="(A-61,F10.4)","__Porosity                      ",soilattri[5]
  printf,lun,format="(A-61,F10.4)","__Bypass_flow                   ",0
  printf,lun,format="(A-61,F10.4)","__Field_capacity                ",soilattri[6]
  printf,lun,format="(A-61,F10.4)","__Wilting_point                 ",soilattri[7]
  printf,lun,format="(A-61,F10.4)","__Hydro_conductivity            ",soilattri[8]
  printf,lun,format="(A-61,F10.4)","__Top_layer_SOC                 ",soilattri[9]
  printf,lun,format="(A-61,F10.4)","__Litter_fraction               ",0.02
  printf,lun,format="(A-61,F10.4)","__Humads_fraction               ",soilattri[9] + 0.0138
  printf,lun,format="(A-61,F10.4)","__Humus_fraction                ",1-(0.02+soilattri[9]+0.0138)
  printf,lun,format="(A-61,F10.4)","__Adjusted_litter_factor        ",1
  printf,lun,format="(A-61,F10.4)","__Adjusted_humads_factor        ",1
  printf,lun,format="(A-61,F10.4)","__Adjusted_humus_factor         ",1
  printf,lun,format="(A-61,F10.4)","__Humads_C/N                    ",10
  printf,lun,format="(A-61,F10.4)","__Humus_C/N                     ",10
  printf,lun,format="(A-61,F10.4)","__Black_C                       ",0
  printf,lun,format="(A-61,F10.4)","__Black_C_C/N                   ",0
  printf,lun,format="(A-61,F10.4)","__SOC_profile_A                 ",0.2
  printf,lun,format="(A-61,F10.4)","__SOC_profile_B                 ",2.0
  printf,lun,format="(A-61,F10.4)","__Initial_nitrate_ppm           ",0.5
  printf,lun,format="(A-61,F10.4)","__Initial_ammonium_ppm          ",0.05
  printf,lun,format="(A-61,F10.4)","__Soil_microbial_index          ",1
  printf,lun,format="(A-61,F10.4)","__Soil_slope                    ",0.0
  printf,lun,format="(A-61,F10.4)","__Lateral_influx_index          ",1.0
  printf,lun,format="(A-61,F10.4)","__Watertable_depth              ",1.0
  printf,lun,format="(A-61,F10.4)","__Water_retension_layer_depth   ",9.990
  printf,lun,format="(A-61,F10.4)","__Soil_salinity                 ",0.0
  printf,lun,format="(A-61,I10)","__SCS_curve_use                 ",0
  printf,lun,format="(A-61,I10)","__None                          ",0
  printf,lun,format="(A-61,I10)","__None                          ",0
  printf,lun,format="(A-61,I10)","__None                          ",0
  printf,lun,format="(A-61,I10)","__None                          ",0
  printf,lun,format="(A-61,I10)","__None                          ",0
  free_lun,lun
  ;ENDFOREACH
  ;  ENDIF
  ; ENDFOR
  ;ENDFOR
END

;����վ����Ϣ
PRO GenSite, siteinfo = siteinfo, outdir = outdir
  COMPILE_OPT idl2
  ;��ȡγ������
  ;  latitudefile = ""
  ;  latitudedata = make_array(11,936)
  ;  openr,lun, latitudefile,/GET_LUN
  ;  readf,lun,latitudedata
  ;  free_lun, lun

  sitename = "SC" + string(siteinfo[0],format="(I07)")
  outfile = outdir + sitename +".dnd"
  openw,lun,outfile, /GET_LUN
  printf,lun,"DNDC_Input_Parameters"
  printf,lun,"----------------------------------------"
  printf,lun,"Site_infomation"
  printf,lun,""
  printf,lun,format="(A-40,A31)","__Site_name", sitename
  printf,lun,format="(A-61,I10)", "__Simulated_years",siteinfo[1]
  printf,lun,format="(A-61,F10.4)", "__Latitude       ",siteinfo[2]
  printf,lun,format="(A-61,I10)", "__Daily_record   ", 1
  printf,lun,format="(A-61,I10)", "__Unit_system    ", 0
  printf,lun,format="(A-61,I10)", "__None           ", 0
  printf,lun,format="(A-61,I10)", "__None           ", 0
  printf,lun,format="(A-61,I10)", "__None           ", 0
  printf,lun,format="(A-61,I10)", "__None           ", 0
  printf,lun,format="(A-61,I10)", "__None           ", 0
  free_lun, lun
END

PRO GenClimate, climateinfo = climateinfo, outdir = outdir
  COMPILE_OPT idl2
  sitename = "SC" + string(climateinfo[0],format="(I07)")
  outfile = outdir + sitename +".dnd"
  Climatefiles = file_search("E:\DNDC\ClimateData\SimulatedYears","*", count = n,/TEST_REGULAR)
  openw,lun,outfile, /GET_LUN, /APPEND
  printf,lun,"----------------------------------------"
  printf, lun, "Climate_data"
  printf, lun, ""
  printf, lun, "__Climate_data_type                                                   1"
  printf, lun, "__N_in_rainfall                                                  0.0000"
  printf, lun, "__Air_NH3_concentration                                          0.0600"
  printf, lun, "__Air_CO2_concentration                                        350.0000"
  printf,lun,format="(A-61,I10)", "__Climate_files", n
  FOR i=1, n DO BEGIN
    printf,lun,format="(I-40,A)", i, climatefiles[i-1]
  ENDFOR
  printf, lun, "__Climate_file_mode                                                   0"
  printf, lun, "__CO2_increase_rate                                              0.0000"
  printf, lun, "__None                                                                0"
  printf, lun, "__None                                                                0"
  printf, lun, "__None                                                                0"
  printf, lun, "__None                                                                0"
  printf, lun, "__None                                                                0"
  free_lun, lun
END


PRO GenDNDCRunFile
  COMPILE_OPT idl2
  ;��ȡ��������
  e = envi(/headless)
  Paddyfile = "E:\DNDC\PaddyCS\2015\Results\2015sPaddySZ1kmSoil(Majority)_SD.tif"
  PaddyRaster = e.OpenRaster(Paddyfile)
  PaddyCS = PaddyRaster.Getdata()

  ;γ������
  latitudefile = "E:\DNDC\latitude.tif"
  latdata = read_tiff(latitudefile)
  e.close

  ; paddyCSize = size(paddycs)
  poses = where(PaddyCS NE 3)
  FOREACH rowcolnum, poses DO BEGIN
    ;ͨ�ò���
    Year = 6 ; ģ������
    rowcolnum = poses[0]
    outdir = "E:\DNDC\RunFiles\" ;DND���λ��
    ;վ����Ϣ
    siteinfo = [rowcolnum, $ ; colunm row
      Year, $; simulated years
      latdata[rowcolnum] ]; latitude
    GenSite, Siteinfo= siteinfo ,outdir= outdir

    ;��������
    climateinfo = [rowcolnum, $ ;colunm row
      Year]; ģ�����
    GenClimate, climateinfo = CLIMATEINFO, outdir = outdir

    ;��������
    GenSoilData, rowcolnum = rowcolnum, outdir = outdir

    ;��������

    pcs = paddyCS[rowcolnum]
    ;psc = 1
    ;������������������Ǽ��У���[6,n]�ṹ��
    cropinfo = [[4, $ ;������
      6 ,$  ;������
      7 , $ ; �ջ���
      24, $ ; �ջ���
      0.2700, $ ; �ոѲ�����
      0 ],$ ;�Ƿ�����]
      []]
    ;������Ϣ
    Tillinfo = [[3, $;��������
      8]]
    ;ʩ����Ϣ
    fertinfo=[[5 ,$ ; Fertilizing_month
      3 , $; Fertilizing_day
      1, $ ; Fertilizing_method
      5.00 , $; Fertilizing_depth
      0.0 , $; Nitrate
      66.3750 , $; Ammonium_bicarbonate
      0.0 ,$ ; Urea
      0.0 ,$ ; Anhydrous_ammonia
      0.0] ,$ ; Ammonium
      [5, 13, 0, 0.2, 0.0, 0.0, 82.5, 0, 0]]
    ;ũ�ҷ���Ϣ ˫����ʩ������
    Manureinfo = [[4 ,$ ;Manuring_month
      5 ,$ ; Manuring_day
      696.825 ,$ ; Manure_amount
      9.500 ,$ ; Manure_C/N
      8 ,$ ; Manure_type
      0] ,$ ; Manuring_method
      []]
    ;��ˮ��Ϣ
    floodinfo = [[4 ,$ ; Start_month
      6, $; Start_day
      7,$ ; End_month
      24 ,$ ; End_day
      0] ,$ ; Alter_wet_dry
      []]
    GenCrop, year, rowcolnum, pcs, cropinfo, tillinfo, fertinfo, Manureinfo, floodinfo
  ENDFOREACH

END