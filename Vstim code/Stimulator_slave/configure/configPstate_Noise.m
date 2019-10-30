function configPstate_Noise

global Pstate 

Pstate = struct;  %clear it 

Pstate.param{1} =  {'predelay'   'float' 2 0     'sec'}; 
Pstate.param{2} =  {'postdelay'  'float' 2 0     'sec'}; 
Pstate.param{3} =  {'stim_time'  'float' 1 0     'sec'}; 

Pstate.param{4} =  {'x_pos'      'int' 600 0     'pixels'}; 
Pstate.param{5} =  {'y_pos'      'int' 400 0     'pixels'}; 
Pstate.param{6} =  {'x_size'     'float' 3 1     'deg'}; 
Pstate.param{7} =  {'y_size'     'float' 3 1     'deg'}; 
Pstate.param{8} = {'x_zoom'    'int' 1 0       ''}; 
Pstate.param{9} = {'y_zoom'    'int' 1 0       ''}; 

Pstate.param{10} = {'h_per'    'int' 1 0       'frames'}; 

Pstate.param{11} =  {'background'     'int' 128 0     ''};  
Pstate.param{12} =  {'contrast'   'float' 100 0   '%'}; 

Pstate.param{13} =  {'tlp_cutoff'     'float' 3 1     'cyc/sec'}; 
Pstate.param{14} =  {'thp_cutoff'     'float' 0 1     'cyc/sec'};  
Pstate.param{15} =  {'freq_decay'     'float' 1 1     ''};  

Pstate.param{16} = {'rseed'     'int' 1 0       ''}; 

Pstate.param{17} =  {'tAmp_profile'     'string' 'none' 0     ''};  
Pstate.param{18} =  {'tAmp_period'     'int'  20  0     'frames'};  

Pstate.param{19} = {'eye_bit'    'int'   0       0                ''};
Pstate.param{20} = {'Leye_bit'    'int'   1       0                ''};
Pstate.param{21} = {'Reye_bit'    'int'   1       0                ''};