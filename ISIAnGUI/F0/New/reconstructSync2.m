function synctimes = reconstructSync2(sync)

%2 accounts for predelay and postdelay

global ACQinfo

sp = 1000*ACQinfo.msPerLine/ACQinfo.pixelsPerLine; %(msPerLine is actually sec/line)

totaltime = pepgetparam('total_time')*1000; %Trial length (ms)
totaltime = totaltime(1);
frate = pepgetparam('refresh');  %frames/sec
frate = frate(1);
fper = pepgetparam('t_period');  %frames/period
fper = fper(1);
tper = 1000*fper/frate; %msec/period

low = min(sync(:));
high = max(sync(:));
mid = (low(1)+high(1))/2;

sync = sign(sync-mid)';

syncID = find(diff(sync)<0);
synctimes = (syncID-1)*sp;

%Fill in syncs at the beginning
for i = 1:ceil(synctimes(1)/tper)
    synctimes = [synctimes(1)-tper synctimes];
end

%Fill in syncs in the middle
dsync = diff(synctimes);
mds = max(dsync);
while mds(1) > 1.5*tper
    k = 0;
    for i = 1:length(dsync)
        if dsync(i) > 1.5*tper
            synctimes = [synctimes(1:i+k) synctimes(i+k)+tper synctimes(i+1+k:end)];
            k = k+1;
        end
    end
    dsync = diff(synctimes);
    mds = max(dsync);
end

%Fill in syncs at the end
while synctimes(end)<totaltime
    synctimes = [synctimes synctimes(end)+tper];
end
