function [sdom, tdom, x_ecc, y_ecc] = makeGraterDomain_Beta(xN,yN,ori,s_freq,t_period,altazimuth)

%Ian Nauhaus

global Mstate

P = getParamStruct;


switch altazimuth

    case 'none'  %For this case we assume that the screen is curved
        
        x_ecc = P.x_size/2;
        y_ecc = P.y_size/2;
        
        x_ecc = single(linspace(-x_ecc,x_ecc,xN));  %deg
        y_ecc = single(linspace(-y_ecc,y_ecc,yN));
        
        [x_ecc y_ecc] = meshgrid(x_ecc,y_ecc);  %deg

        
    case 'altitude'
        
        %%%Get the xy domain
        x_ecc = single(tan(P.x_size/2*pi/180)*Mstate.screenDist);  %cm
        y_ecc = single(tan(P.y_size/2*pi/180)*Mstate.screenDist);
        
        x_ecc = single(linspace(-x_ecc,x_ecc,xN)); %cm
        y_ecc = single(linspace(-y_ecc,y_ecc,yN));
        
        [x_ecc y_ecc] = meshgrid(x_ecc,y_ecc);
        
    case  'azimuth'
        
        %%%Get the xy domain
        x_ecc = single(tan(P.x_size/2*pi/180)*Mstate.screenDist);  %cm
        y_ecc = single(tan(P.y_size/2*pi/180)*Mstate.screenDist);
        
        x_ecc = single(linspace(-x_ecc,x_ecc,xN)); %cm
        y_ecc = single(linspace(-y_ecc,y_ecc,yN));
        
        [x_ecc y_ecc] = meshgrid(x_ecc,y_ecc);
             
end


%Change location of perpendicular bisector relative to stimulus center
x_ecc = x_ecc-P.dx_perpbis;
y_ecc = y_ecc-P.dy_perpbis;
%%%%%%%%%%%%%%%%%%%%%%%


switch altazimuth
    
    case 'none'
        
        sdom = x_ecc*cos(ori*pi/180) - y_ecc*sin(ori*pi/180);    %deg
        
    case 'altitude'
        
        %Apply "tilt" to y/z dimensions: rotation around x axis
        z_ecc = Mstate.screenDist*ones(size(x_ecc));  %dimension perpendicular to screen
        y_eccT = y_ecc*cos(P.tilt_alt*pi/180) - z_ecc*sin(P.tilt_alt*pi/180);
        z_eccT = y_ecc*sin(P.tilt_alt*pi/180) + z_ecc*cos(P.tilt_alt*pi/180);       
             
        %Apply "tilt direction", i.e. rotation around y axis   
        x_eccR = x_ecc*cos(P.tilt_az*pi/180) - z_eccT*sin(P.tilt_az*pi/180);
        z_eccR = x_ecc*sin(P.tilt_az*pi/180) + z_eccT*cos(P.tilt_az*pi/180); 
        
        %Apply "orientation" to the x/y dimensions: rotation around z axis
        x_eccO = x_eccR*cos(ori*pi/180) - y_eccT*sin(ori*pi/180); 
        y_eccO = x_eccR*sin(ori*pi/180) + y_eccT*cos(ori*pi/180); 
        
        sdom = asin(y_eccO./sqrt(x_eccO.^2 + y_eccO.^2 + z_eccR.^2))*180/pi;

    case 'azimuth' %The projection of azimuth onto a plane is the same as a cylinder on a plane       
                
        %Apply "tilt" to y/z dimensions: rotation around x axis
        z_ecc = Mstate.screenDist*ones(size(x_ecc));  %dimension perpendicular to screen
        y_eccT = y_ecc*cos(P.tilt_alt*pi/180) - z_ecc*sin(P.tilt_alt*pi/180);
        z_eccT = y_ecc*sin(P.tilt_alt*pi/180) + z_ecc*cos(P.tilt_alt*pi/180);       
             
        %Apply "tilt direction", i.e. rotation around y axis   
        x_eccR = x_ecc*cos(P.tilt_az*pi/180) - z_eccT*sin(P.tilt_az*pi/180);
        z_eccR = x_ecc*sin(P.tilt_az*pi/180) + z_eccT*cos(P.tilt_az*pi/180); 
        
        %Apply "orientation" to the x/y dimensions: rotation around z axis
        x_eccO = x_eccR*cos(ori*pi/180) - y_eccT*sin(ori*pi/180); 
        
        sdom = atan(x_eccO./z_eccR)*180/pi; %deg
        
end

sdom = sdom*s_freq*2*pi; %radians
tdom = single(linspace(0,2*pi,t_period+1));
tdom = tdom(1:end-1);
    

    