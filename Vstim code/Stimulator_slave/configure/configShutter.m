function configShutter

global daq shutterState


shutterState=0;

DaqDConfigPort(daq,1,0);    

DaqDOut(daq, 1, 0); 
    
