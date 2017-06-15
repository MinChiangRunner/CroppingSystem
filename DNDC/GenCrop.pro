PRO GenCrop, year, rowcolnum, pcs, cropinfo, tillinfo, fertinfo, Manureinfo, floodinfo, outdir
  COMPILE_OPT idl2

  sitename = "SC" + string(rowcolnum,format="(I07)")
  outfile = outdir + sitename +".dnd"

  OPENU,lun,outfile, /append, /get_lun
  PRINTF,Lun,"----------------------------------------"
  PRINTF,Lun,"Crop_data"
  PRINTF,Lun,""
  PRINTF,Lun,"Cropping_systems                                                      1"
  PRINTF,Lun,""
  PRINTF,Lun,"__Cropping_system                                                     1"
  PRINTF,lun,format="(A-61,I10)","__Total_years", year
  PRINTF,lun,format="(A-61,I10)","__Years_of_a_cycle", year
  printf, lun,""
  FREE_LUN,lun

  ;--------------------------------------
  ;           年号
  ;--------------------------------------

  FOR i=1,year DO BEGIN
    OPENU,lun,outfile,/append,/get_lun
    PRINTF,lun,format="(A-61,I10)","____Year", i
    ;水稻熟制PCS
    PRINTF,lun,format="(A-61,I10)","____Crops", PCS
    FREE_LUN,lun
    ;--------------------------------------
    ;           作物信息
    ;--------------------------------------

    FOR j=1,pcs DO BEGIN
      OPENU,lun,outfile,/append,/get_lun
      OPENU,lun,outfile,/append,/get_lun
      PRINTF,lun,format="(A-61,I10)","______Crop#", j
      PRINTF,lun,format="(A-61,I10)","______Crop_ID", 20
      printf, lun,format="(A-61,I10)", "______Planting_month          ",cropinfo[0,j-1] ;移栽月
      printf, lun,format="(A-61,I10)", "______Planting_day            ",cropinfo[1,j-1] ;移栽日
      printf, lun,format="(A-61,I10)", "______Harvest_month           ",cropinfo[2,j-1] ;                  7
      printf, lun,format="(A-61,I10)", "______Harvest_day             ",cropinfo[3,j-1];                  24
      printf, lun,format="(A-61,I10)", "______Harvest_year            ", 1
      printf, lun,format="(A-61,F10.4)", "______Residue_left_in_field   ",cropinfo[4,j-1] ;             0.2700
      printf, lun,format="(A-61,F10.4)", "______Maximum_yield           ",          3622.2300
      printf, lun,format="(A-61,F10.4)", "______Leaf_fraction           ",             0.1680
      printf, lun,format="(A-61,F10.4)", "______Stem_fraction           ",             0.1680
      printf, lun,format="(A-61,F10.4)", "______Root_fraction           ",             0.1500
      printf, lun,format="(A-61,F10.4)", "______Grain_fraction          ",             0.5140
      printf, lun,format="(A-61,F10.4)", "______Leaf_C/N                ",            70.0000
      printf, lun,format="(A-61,F10.4)", "______Stem_C/N                ",            70.0000
      printf, lun,format="(A-61,F10.4)", "______Root_C/N                ",            50.0000
      printf, lun,format="(A-61,F10.4)", "______Grain_C/N               ",            38.0000
      printf, lun,format="(A-61,F10.4)", "______Accumulative_temperature",          2482.77500
      printf, lun,format="(A-61,F10.4)", "______Optimum_temperature     ",            30.0000
      printf, lun,format="(A-61,F10.4)", "______Water_requirement       ",           508.0000
      printf, lun,format="(A-61,F10.4)", "______N_fixation_index        ",             1.0500
      printf, lun,format="(A-61,F10.4)", "______Vascularity             ",             1.0000
      printf, lun,format="(A-61,I10)", "______If_cover_crop           ",                  0
      printf, lun,format="(A-61,I10)", "______If_perennial_crop       ",                  0
      printf, lun,format="(A-61,I10)", "______If_transplanted         ",cropinfo[5,j-1] ;                  0
      printf, lun,format="(A-41,I30)", "______Tree_maturity_age       ",    -107374000.0000
      printf, lun,format="(A-61,I10)", "______None                    ",                  0
      printf, lun,format="(A-61,I10)", "______None                    ",                  0
      printf, lun,format="(A-61,I10)", "______None                    ",                  0
      printf, lun,format="(A-61,I10)", "______None                    ",                  0
      printf, lun,format="(A-61,I10)", "______None                    ",                  0
      printf, lun,format="(A-61,I10)", "______None                    ",                  0
      printf, lun,format="(A-61,I10)", "______None                    ",                  0
      printf, lun,format="(A-61,I10)", "______None                    ",                  0
      printf, lun,format="(A-61,I10)", "______None                    ",                  0
      printf, lun,format="(A-61,I10)", "______None                    ", 0
      printf, lun,""
      FREE_LUN,lun
    ENDFOR

    ;--------------------------------------
    ;  每季翻耕信息（默认每季翻耕一次,方式不变）
    ;--------------------------------------
    OPENU,lun,outfile,/append,/get_lun
    printf, lun, "----------------------------------------"
    PRINTF,lun,format="(A-61,I10)","____Till_applications", pcs
    FOR j=1,pcs DO BEGIN
      printf, lun, format = "(A-61,I10)", "______Till#      ", j
      printf, lun, format = "(A-61,I10)", "______Till_month ", tillinfo[0,j-1]
      printf, lun, format = "(A-61,I10)", "______Till_day   ", tillinfo[1,j-1]
      printf, lun, format = "(A-61,I10)", "______Till_method", 4
    ENDFOR
    FREE_LUN,lun
    ;--------------------------------------
    ; 施肥信息（默认每季施肥一到两次，所以季内有循环）
    ;--------------------------------------
    OPENU,lun,OUTfile,/append,/get_lun
    printf, lun, "----------------------------------------"
    dim = size(fertinfo); 一行数据表示一次施肥，获取行号就是获取施肥次数
    rownum = n_elements(fertinfo)/ dim[1]
    printf, lun, format = "(A-61,I10)", "____Fertilizer_applications", rownum
    FOR j=1,rownum DO BEGIN
      printf, lun, format = "(A-61,I10)", "______Fertilizing#                      ", j
      printf, lun, format = "(A-61,I10)", "______Fertilizing_month                 ", fertinfo[0,j-1]
      printf, lun, format = "(A-61,I10)", "______Fertilizing_day                   ", fertinfo[1,j-1]
      printf, lun, format = "(A-61,I10)", "______Fertilizing_method                ", fertinfo[2,j-1]
      printf, lun, format = "(A-61,F10.4)", "______Fertilizing_depth                 ",fertinfo[3,j-1]
      printf, lun, format = "(A-61,F10.4)", "______Nitrate                           ", fertinfo[4,j-1]
      printf, lun, format = "(A-61,F10.4)", "______Ammonium_bicarbonate              ", fertinfo[5,j-1]
      printf, lun, format = "(A-61,F10.4)", "______Urea                              ", fertinfo[6,j-1]
      printf, lun, format = "(A-61,F10.4)", "______Anhydrous_ammonia                 ", fertinfo[7,j-1]
      printf, lun, format = "(A-61,F10.4)", "______Ammonium                          ", fertinfo[8,j-1]
      printf, lun, format = "(A-61,F10.4)", "______Sulphate                          ",  0.0000
      printf, lun, format = "(A-61,F10.4)", "______Phosphate                         ",  0.0000
      printf, lun, format = "(A-61,F10.4)", "______Slow_release_rate                 ",  1.0000
      printf, lun, format = "(A-61,F10.4)", "______Nitrification_inhibitor_efficiency",  0.0000
      printf, lun, format = "(A-61,F10.4)", "______Nitrification_inhibitor_duration  ",  0.0000
      printf, lun, format = "(A-61,F10.4)", "______Urease_inhibitor_efficiency       ",  0.0000
      printf, lun, format = "(A-61,F10.4)", "______Urease_inhibitor_duration         ",  0.0000
      printf, lun, format = "(A-61,I10)", "______None                              ",       0
      printf, lun, format = "(A-61,I10)", "______None                              ",       0
      printf, lun, format = "(A-61,I10)", "______None                              ",       0
      printf, lun, format = "(A-61,I10)", "______None                              ",       0
      printf, lun, format = "(A-61,I10)", "______None                              ",       0
    ENDFOR
    printf, lun,"____Fertilization_option                                              0"
    FREE_LUN,lun
    ;--------------------------------------
    ;  农家肥信息，设置为每季仅施肥一次
    ;--------------------------------------
    OPENU,lun,OUTfile,/append,/get_lun
    printf, lun, "----------------------------------------"
    dim = size(manureinfo); 一行数据表示一次农家肥，获取行号就是获取农家肥次数
    rownum = n_elements(manureinfo)/ dim[1]
    printf, lun, format = "(A-61,I10)", "____Manure_applications", rownum
    FOR j=1,rownum DO BEGIN
      printf, lun, format = "(A-61,I10)", "______Manuring#     ", j
      printf, lun, format = "(A-61,I10)", "______Manuring_month", Manureinfo[0,j-1]
      printf, lun, format = "(A-61,I10)", "______Manuring_day  ", Manureinfo[1,j-1]
      printf, lun, format = "(A-61,F10.4)", "______Manure_amount", Manureinfo[2,j-1]
      printf, lun, format = "(A-61,F10.4)", "______Manure_C/N   ", Manureinfo[3,j-1]
      printf, lun, format = "(A-61,I10)", "______Manure_type    ", Manureinfo[4,j-1]
      printf, lun, format = "(A-61,I10)", "______Manuring_method", Manureinfo[5,j-1]
      printf, lun, format = "(A-61,I10)", "______None           ", 0
      printf, lun, format = "(A-61,I10)", "______None           ", 0
      printf, lun, format = "(A-61,I10)", "______None           ", 0
      printf, lun, format = "(A-61,I10)", "______None           ", 0
      printf, lun, format = "(A-61,I10)", "______None           ", 0
    ENDFOR
    printf, lun,"----------------------------------------"
    printf, lun,"____Film_applications                                                 0"
    printf, lun,"____Method                                                            0"
    FREE_LUN,lun
    ;--------------------------------------
    ;  淹灌信息，设置为每季可灌溉1-2次，即可烤田
    ;--------------------------------------
    OPENU, lun, OUTfile, /append, /get_lun
    printf, lun, "----------------------------------------"
    dim = size(floodinfo)
    rownum = n_elements(floodinfo)/ dim[1]; 一行数据表示一次农家肥，获取行号就是获取农家肥次数
    printf, lun, format = "(A-61,I10)", "____Flood_applications", rownum
    printf, lun, "____Water_control                                                     0"
    printf, lun, "____Flood_water_N                                                0.0000"
    printf, lun, "____Leak_rate                                                    0.0000"
    printf, lun, "____Water_gather_index                                           0.0000"
    printf, lun, "____Watertable_file                                        None0.000000"
    printf, lun, "____Empirical_para_1                                             0.0000"
    printf, lun, "____Empirical_para_2                                             0.0000"
    printf, lun, "____Empirical_para_3                                             0.0000"
    printf, lun, "____Empirical_para_4                                             0.0000"
    printf, lun, "____Empirical_para_5                                             0.0000"
    printf, lun, "____Empirical_para_6                                             0.0000"
    FOR j=1, rownum DO BEGIN
      printf,lun,format = "(A-61,I10)", "______Flooding#    " , j
      printf,lun,format = "(A-61,I10)", "______Start_month  " , floodinfo[0,j-1]
      printf,lun,format = "(A-61,I10)", "______Start_day    " , floodinfo[1,j-1]
      printf,lun,format = "(A-61,I10)", "______End_month    " , floodinfo[2,j-1]
      printf,lun,format = "(A-61,I10)", "______End_day      " , floodinfo[3,j-1]
      printf,lun,format = "(A-61,I10)", "______Water_N      " , 0.00
      printf,lun,format = "(A-61,I10)", "______Alter_wet_dry" , floodinfo[4,j-1]
      printf,lun,format = "(A-61,I10)", "______None         " , 0
      printf,lun,format = "(A-61,I10)", "______None         " , 0
      printf,lun,format = "(A-61,I10)", "______None         " , 0
      printf,lun,format = "(A-61,I10)", "______None         " , 0
      printf,lun,format = "(A-61,I10)", "______None         " , 0
    ENDFOR
    printf, lun, "----------------------------------------"
    printf, lun, "____Irrigation_applications                                           0"
    printf, lun, "____Irrigation_control                                                0"
    printf, lun, "____Irrigation_index                                             0.0000"
    printf, lun, "____Irrigation_method                                                 0"
    printf, lun, "----------------------------------------"
    printf, lun, "____Grazing_applications                                              0"
    printf, lun, "----------------------------------------"
    printf, lun, "____Cut_applications                                                  0"
    printf, lun, ""
    FREE_LUN,lun
  ENDFOR
END