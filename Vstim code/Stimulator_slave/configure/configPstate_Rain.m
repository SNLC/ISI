function configPstate_Rain

global Pstate

Pstate = struct; %clear it

Pstate.param{1} = {'predelay'  'float'      2       0                'sec'};
Pstate.param{2} = {'postdelay'  'float'     2       0                'sec'};
Pstate.param{3} = {'stim_time'  'float'     1       0                'sec'};

Pstate.param{4} = {'x_pos'       'int'      600       0                'pixels'};
Pstate.param{5} = {'y_pos'       'int'      400       0                'pixels'};
Pstate.param{6} = {'x_size'      'float'      3       1                'deg'};
Pstate.param{7} = {'y_size'      'float'      3       1                'deg'};
Pstate.param{8} = {'x_zoom'      'int'   1       0                ''};
Pstate.param{9} = {'y_zoom'      'int'   1       0                ''};

Pstate.param{10} = {'background'      'int'   128       0                ''};
Pstate.param{11} = {'contrast'    'float'     100       0                '%'};

Pstate.param{12} = {'ori'         'int'        0       0                'deg'};
Pstate.param{13} = {'n_ori'    'int'   8       0                ''};
Pstate.param{14} = {'h_per'      'int'   3       0                'frames'};

Pstate.param{15} = {'Nx'    'int'   10       0                ''};
Pstate.param{16} = {'Ny'    'int'   10       0                ''};
Pstate.param{17} = {'gridType'    'string'   'Cartesian'       0                ''};
Pstate.param{18} = {'speed'    'float'   0       0                'deg/frame'};

Pstate.param{19} = {'barWidth'      'float'   1       1                'deg'};
Pstate.param{20} = {'barLength'      'float'   1       1                'deg'};
Pstate.param{21} = {'bw_bit'    'int'   2       0                ''};


Pstate.param{22} = {'redgain' 'float'   1       0             ''};
Pstate.param{23} = {'greengain' 'float'   1       0             ''};
Pstate.param{24} = {'bluegain' 'float'   1       0             ''};

Pstate.param{25} = {'redbase' 'float'   .5       0             ''};
Pstate.param{26} = {'greenbase' 'float'   .5       0             ''};
Pstate.param{27} = {'bluebase' 'float'   .5       0             ''};

Pstate.param{28} = {'colorspace' 'string'   'gray'       0             ''};


Pstate.param{29} = {'Ndrops'    'int'   1       0                ''};

Pstate.param{30} = {'rseed'    'int'   1       0                ''};

Pstate.param{31} = {'eye_bit'    'int'   0       0                ''};
Pstate.param{32} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{33} = {'Reye_bit'    'int'   1       0                ''};