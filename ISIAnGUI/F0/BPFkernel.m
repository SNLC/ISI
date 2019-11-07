function h = BPFkernel(fhi,flow,HPflag,LPflag,kernel)

%if [HPflag LPflag] = [0 1] then a low-pass filter is made using the kernel
%in the string variable 'kernel'.  e.g. kernel = 'gaussian'.

if HPflag == 1
    Hwidth = str2double(get(handles.Hpixwidth,'string'));
    ind = get(handles.HPWind,'value');
    
    switch ind
        case 1
            size = 3*Hwidth;
            H = -fspecial('gaussian',size,Hwidth);
            H(round(size/2),round(size/2)) = 1+H(round(size/2),round(size/2));
        case 2
            H = hann(Hwidth)*hann(Hwidth)';
            H = -H./sum(H(:));
            H(round(Hwidth/2),round(Hwidth/2)) = 1+H(round(Hwidth/2),round(Hwidth/2));
        case 3
            H = -fspecial('disk',round(Hwidth/2));
            H(round(Hwidth/2),round(Hwidth/2)) = 1+H(round(Hwidth/2),round(Hwidth/2));
    end
    if LPflag == 0
        BPF = H;
    end
end

if LPflag == 1
    Lwidth = str2double(get(handles.Lpixwidth,'string'));
    ind = get(handles.LPWind,'value');
    
    switch ind
        case 1
            size = 3*Lwidth;
            L = fspecial('gaussian',Lwidth,size);
        case 2
            L = hann(Lwidth)*hann(Lwidth)';
            L = L./sum(L(:));
        case 3
            L = fspecial('disk',round(Lwidth/2));
    end
    if HPflag == 0
        BPF = L;
    else
        BPF = conv2(L,H);
    end
end
