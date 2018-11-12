function Im2=my_threshold(Im,x)
%Im er original billed , x er 2d matrice med mindste værdi i colonne 1 og
%højeste i colonne 2.
normIm=double(Im);
tot=normIm(:,:,1)+normIm(:,:,2)+normIm(:,:,3);
normIm(:,:,1)=normIm(:,:,1)./tot;
normIm(:,:,2)=normIm(:,:,2)./tot;
normIm(:,:,3)=normIm(:,:,3)./tot;
normIm=uint8(normIm*255.0);
%My x is [120,256;37,80;37,80]
Im2=x(1,1)<normIm(:,:,1) & x(1,2)>normIm(:,:,1) & normIm(:,:,2)>x(2,1) & normIm(:,:,2)<x(2,2) & normIm(:,:,3)>x(3,1) & normIm(:,:,3)<x(3,2);