function rc_tdomain(hper,acqT,T)

FR = 99.8
stimT = 1000*hper/FR
%stimT - temporal period of the stimulus (ms)
%acqT - temporal period of the acquisition (ms)
%T - Trail length (sec)

sp = 2; %sample period  (ms)

N = T*1000/sp; %no. of samples

%Periods in samples
stimS = round(stimT/sp); 
acqS = round(acqT/sp); 

stim = zeros(1,N);
acq = zeros(1,N);

stim(1:stimS:end) = 1;
acq(1:acqS:end) = 1;
% 
% figure,stem(stim)
% hold on
% stem(acq,'r')

tperiod = 0:sp:100;
for i = 1:length(tperiod)
    TD(i) = sum(stim(1:end-i+1).*acq(i:end));
end

figure, stem(tperiod,TD/sum(TD))
xlabel('ms')
