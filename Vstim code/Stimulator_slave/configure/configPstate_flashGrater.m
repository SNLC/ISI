function configPstate_flashGrater

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'x_size'      'float'      3       1                'deg'};
Pstate.param{7} = {'y_size'      'float'      3       1                'deg'};
Pstate.param{8} = {'mask_type'   'string'   'none'       0                ''};
Pstate.param{9} = {'mask_radius' 'float'      6       1                'deg'};
Pstate.param{10} = {'x_zoom'      'int'   1       0                ''};
Pstate.param{11} = {'y_zoom'      'int'   1       0                ''};

Pstate.param{12} = {'background'      'int'   128       0                ''};
Pstate.param{13} = {'contrast'    'float'     100       0                '%'};

Pstate.param{14} = {'ori'         'int'        0       0                'deg'};

Pstate.param{15} = {'h_per'      'int'   3       0                'frames'};
Pstate.param{16} = {'n_ori'    'int'   8       0                ''};
Pstate.param{17} = {'n_phase' 'int'   4       0             ''};

Pstate.param{18} = {'min_sf'   'float'   1       0                ''};
Pstate.param{19} = {'max_sf'   'float'   1       0                ''};
Pstate.param{20} = {'n_sfreq' 'int'   1       0             ''};
Pstate.param{21} = {'sf_domain'   'string'   'log'       0                ''};

Pstate.param{22} = {'separable'   'int'     0       0                'bit'};
Pstate.param{23} = {'st_profile'  'string'   'sin'       0                ''};
Pstate.param{24} = {'s_profile'   'string'   'sin'       0                ''};
Pstate.param{25} = {'s_duty'      'float'   0.5       0                ''};

Pstate.param{26} = {'redgain' 'float'   1       0             ''};
Pstate.param{27} = {'greengain' 'float'   1       0             ''};
Pstate.param{28} = {'bluegain' 'float'   1       0             ''};

Pstate.param{29} = {'redbase' 'float'   .5       0             ''};
Pstate.param{30} = {'greenbase' 'float'   .5       0             ''};
Pstate.param{31} = {'bluebase' 'float'   .5       0             ''};

Pstate.param{32} = {'colorspace' 'string'   'gray'       0             ''};

Pstate.param{33} = {'FourierBit'   'int'   0       0                ''};

Pstate.param{34} = {'rseed'    'int'   1       0                ''};

Pstate.param{35} = {'blankProb'    'float'   0       0                ''};

Pstate.param{36} = {'eye_bit'    'int'   0       0                ''};
Pstate.param{37} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{38} = {'Reye_bit'    'int'   1       0                ''};