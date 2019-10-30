function configPstate_Post
%periodic grater

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};
Pstate.param{4} = {'posttrig'  'int'     1       0                'frames'};

Pstate.param{5} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{6} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{7} = {'x_size'      'float'      3       1                'deg'};
Pstate.param{8} = {'y_size'      'float'      3       1                'deg'};
Pstate.param{9} = {'mask_type'   'string'   'none'       0                ''};
Pstate.param{10} = {'mask_radius' 'float'      6       1                'deg'};
Pstate.param{11} = {'x_zoom'      'int'   1       0                ''};
Pstate.param{12} = {'y_zoom'      'int'   1       0                ''};

Pstate.param{13} = {'altazimuth'      'string'   'none'       0                ''};

Pstate.param{14} = {'contrast'    'float'     100       0                '%'};
Pstate.param{15} = {'ori'         'int'        0       0                'deg'};
Pstate.param{16} = {'phase'         'float'        0       0                'deg'};

Pstate.param{17} = {'separable'   'int'     0       0                'bit'};
Pstate.param{18} = {'st_profile'  'string'   'sin'       0                ''};
Pstate.param{19} = {'s_freq'      'float'      1      -1                 'cyc/deg'};
Pstate.param{20} = {'s_profile'   'string'   'sin'       0                ''};
Pstate.param{21} = {'s_duty'      'float'   0.5       0                ''};
Pstate.param{22} = {'t_profile'   'string'   'sin'       0                ''};
Pstate.param{23} = {'t_duty'      'float'   0.5       0                ''};
Pstate.param{24} = {'t_period'    'int'       20       0                'frames'};

Pstate.param{25} = {'background'      'int'   128       0                ''};

Pstate.param{26} = {'noise_bit'      'int'   0       0                ''};
Pstate.param{27} = {'noise_amp'      'float'   100       0                '%'};
Pstate.param{28} = {'noise_width'    'int'   5       0                'deg'};
Pstate.param{29} = {'noise_lifetime' 'float'   10       0             'frames'};
Pstate.param{30} = {'noise_type' 'string'   'random'       0             ''};

Pstate.param{31} = {'redgain' 'float'   1       0             ''};
Pstate.param{32} = {'greengain' 'float'   1       0             ''};
Pstate.param{33} = {'bluegain' 'float'   1       0             ''};
Pstate.param{34} = {'redbase' 'float'   .5       0             ''};
Pstate.param{35} = {'greenbase' 'float'   .5       0             ''};
Pstate.param{36} = {'bluebase' 'float'   .5       0             ''};
Pstate.param{37} = {'colormod'    'int'   1       0                ''};

Pstate.param{38} = {'mouse_bit'    'int'   0       0                ''};

Pstate.param{39} = {'eye_bit'    'int'   1       0                ''};
Pstate.param{40} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{41} = {'Reye_bit'    'int'   1       0                ''};

Pstate.param{42} = {'plaid_bit'    'int'   0       0                ''};
Pstate.param{43} = {'contrast2'    'float'     10       0                '%'};
Pstate.param{44} = {'ori2'         'int'        90       0                'deg'};
Pstate.param{45} = {'phase2'         'float'        0       0                'deg'};
Pstate.param{46} = {'st_profile2'  'string'   'sin'       0                ''};
Pstate.param{47} = {'s_freq2'      'float'      1      -1                 'cyc/deg'};
Pstate.param{48} = {'s_profile2'   'string'   'sin'       0                ''};
Pstate.param{49} = {'s_duty2'      'float'   0.5       0                ''};
Pstate.param{50} = {'t_profile2'   'string'   'sin'       0                ''};
Pstate.param{51} = {'t_duty2'      'float'   0.5       0                ''};
Pstate.param{52} = {'t_period2'    'int'       20       0                'frames'};
