function updateMonitor


global Mstate screenPTR 


switch Mstate.monitor
    
    case 'LCD'
        
        Mstate.screenXcm = 33.7;  %Smaller LCD
        Mstate.screenYcm = 27;
        
        %Mstate.screenXcm = 51;  %New big LCD
        %Mstate.screenYcm = 28.5;
       
        load('/Matlab_code/calibration_stuff/measurements/LCD (big) 1-8-11/LUT.mat','bufLUT')
        
    case 'CRT'
        
        %Actual screen width
        %Mstate.screenXcm = 32.5;
        %Mstate.screenYcm = 24;
        
        %Display size
        %Mstate.screenXcm = 30.5;
        Mstate.screenXcm = 29;  %old crt
        Mstate.screenYcm = 22;  

%         Mstate.screenXcm = 37;  %new crt
%         Mstate.screenYcm = 27.75;  
        
        %load('/Matlab_code/calibration_stuff/measurements/CRT 5-18-10 PR650/LUT.mat','bufLUT')
        %load('/Matlab_code/calibration_stuff/measurements/CRT 6-9-10 UDT/LUT.mat','bufLUT')
        
        %This one is only slightly different than the UDT measurement, but
        %occured after I changed the monitor cable, which eliminated the
        %aliasing.
        %load('/Matlab_code/calibration_stuff/measurements/CRT (new) 7-8-11/LUT.mat','bufLUT')
        %load('/Matlab_code/calibration_stuff/measurements/CRT (new) 7-8-11 UDT/LUT.mat','bufLUT')
        
        load('/Matlab_code/calibration_stuff/measurements/CRT 7-9-11 UDT/LUT.mat','bufLUT')
        
    case 'LIN'   %load a linear table
        
        Mstate.screenXcm = 32.5;
        Mstate.screenYcm = 24;        
        
        bufLUT = (0:255)/255;
        bufLUT = bufLUT'*[1 1 1];
        
   case 'TEL'  
        
        Mstate.screenXcm = 121;
        Mstate.screenYcm = 68.3;        
        
        load('/Matlab_code/calibration_stuff/measurements/TELEV 9-29-10/LUT.mat','bufLUT')
        
   case '40in'  
        
        Mstate.screenXcm = 88.8;
        Mstate.screenYcm = 50;        
        %load('/Matlab_code/calibration_stuff/measurements/LCD (big) 1-8-11/LUT.mat','bufLUT')
        load('/Matlab_code/calibration_stuff/measurements/NEWTV 3-15-12/LUT.mat','bufLUT')
        
end


Screen('LoadNormalizedGammaTable', screenPTR, bufLUT);  %gamma LUT

