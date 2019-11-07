function orimapSplit(map1,map2,bw)

ang1 = angle(map1);
ang1 = (ang1+pi*(1-sign(ang1)))/2*180/pi;
ang2 = angle(map2);
ang2 = (ang2+pi*(1-sign(ang2)))/2*180/pi;

id = find(bw(:));
figure,
scatter(ang1(id),ang2(id),'.')
