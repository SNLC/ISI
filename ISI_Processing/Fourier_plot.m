function Fourier_plot(x)

global frameang ce cef Analyzer

x = x-mean(x);

%%%%
dt = trimmean(diff(Analyzer.loops.conds{1}.repeats{1}.acqSyncs),50);
Fs = 1/dt;  %frames/sec
T = mean(diff(Analyzer.loops.conds{1}.repeats{1}.dispSyncs(2:end-1)));  %Period of stimulus based on syncs

H = cos(j*2*pi/(T*Fs)*(0:length(x)-1)) .* hann(length(x))';
%x = ifft(abs(fft(H)).*fft(x));
%%%%

t_domain = (0:length(x)-1)/Fs;
xw = 2*fft(x)/length(x);
xw = xw(1:floor(length(xw)/2));
xw_mag = abs(xw);
xw_phase = angle(xw)*180/pi;
f_domain = 0:(Fs/2)/(length(xw)-1):Fs/2;

k = round(length(x)/(T*Fs));
ce = exp(j*2*pi/(T*Fs)*(0:length(x)-1));

H = cos(j*2*pi/(T*Fs)*(0:length(x)-1)) .* hann(length(x))';
%cef = exp(j*frameang);

f1_phase = -xw_phase(k+1)    % k = 0 to N-1; Take negative because exp(-wt)!
f1_mag = xw_mag(k+1)

figure
subplot(3,1,1)
plot(t_domain,x)
hold on
plot(t_domain,f1_mag*cos(2*pi*t_domain/T - f1_phase*pi/180),'r')
xlabel('seconds')
ylabel('x(t)')
subplot(3,1,2)
semilogx(f_domain,xw_mag)
xlabel('Hertz')
ylabel('|X(w)|')
line([1/T 1/T], max(xw_mag)*[0 .1],'color','r') 
subplot(3,1,3)
plot(f_domain,xw_phase)
xlabel('Hertz')
ylabel('X(w) phase')
line([1/T 1/T], [min(xw_phase) max(xw_phase)],'color','r') 
hold off


%  angle(2*cef*x'/length(x))*180/pi
%  angle(2*ce*x'/length(x))*180/pi
% angle(2*cef*x'/length(x))*180/pi

% abs(2*cef*x'/length(x))
% abs(2*ce*x'/length(x))


 