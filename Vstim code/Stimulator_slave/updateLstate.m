function updateLstate

global Lstate GUIhandles

Lstate.reps = str2num(get(GUIhandles.looper.repeats,'string'));
Lstate.rand = get(GUIhandles.looper.randomflag,'value');

Lstate.param{1} = {[get(GUIhandles.looper.symbol1,'string')] [get(GUIhandles.looper.valvec1,'string')]};
Lstate.param{2} = {[get(GUIhandles.looper.symbol2,'string')] [get(GUIhandles.looper.valvec2,'string')]};
Lstate.param{3} = {[get(GUIhandles.looper.symbol3,'string')] [get(GUIhandles.looper.valvec3,'string')]};
Lstate.param{4} = {[get(GUIhandles.looper.symbol4,'string')] [get(GUIhandles.looper.valvec4,'string')]};
Lstate.param{5} = {[get(GUIhandles.looper.symbol5,'string')] [get(GUIhandles.looper.valvec5,'string')]};

