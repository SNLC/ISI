function configSync

global daq

daq = DaqDeviceIndex;

if ~isempty(daq)
    
    DaqDConfigPort(daq,0,0);    
    
    DaqDOut(daq, 0, 0); 
    
else
    
    'Daq device does not appear to be connected'
    
end