%% Multiple Image Blending using Gaussian & Laplacian Pyramids
%
% Author: Tilemachos S. Doganis
%
% The purpose of the script is to load a single background and mutliple
% foreground images, produce the corresponding masks, and then construct a
% final composite image using Gaussian and Laplacian Pyramids of the
% aforementioned original images.
%
% 1. Load, crop and scale original images and create corresponding masks
% (manually)
%
% 2. Construct Gaussian Pyramids for the mask and the images
%
% 3. Construct Laplacian Pyramids for the images
%
% 4. Construct each level of the Blend Laplacian Pyramid by feathering
% using the corresponding Mask Gaussian and Image Laplacian pyramid
% levels.
%
% 5. Construct the Blend Gaussian Pyramid using the Blend Laplacian
% Pyramid. The base level of the Gaussian pyramid is the desired composite
% image.
%
clear
clc

% Define Pyramid level parameter
Level = 4;

% Load  background image
Ip = im2double(imread('P200.jpg'));
[M,N,clr] = size(Ip);

% Crop background
Ip = Ip(1500:end,1:2000,:);

% Binary mask creation using tutorial:
% https://www.mathworks.com/help/images/create-binary-mask-using-an-roi-object.html

%% CREATE BENCH MASK
close all;
Ib = im2double(imread('bench.jpg'));

% Create mask
h_im = imshow(Ib);
pb = impoly(gca,[ 2796 1540; 3012 1550; 3012 1432; 2792 1419; 2794 1287; 3012 1296; 3019 1167;...
    2799 1157; 2800 1125; 3018 1126; 3023 998; 957 1016; 938 1031; 931 1105;...
    1074 1112; 1073 1137; 931 1136; 922 1224; 1066 1233; 1057 1332; 905 1325;...
    702 1349; 683 1363; 683 1395; 815 1405; 815 1446; 850 1490; 863 1498; 869 1750;...
    941 1731; 967 1485; 1058 1468; 1080 1673; 1111 1675; 1148 1663; 1143 1428; 1613 1459; ...
    1612 1509; 1645 1562; 1648 1834; 1687 1844; 1714 1828; 1732 1537; 1781 1521;...
    1794 1748; 1831 1757; 1856 1737; 1853 1473; 2689 1526; 2683 1977; 2740 1987;...
    2750 1975; 2755 1859; 2778 1860; 2786 1852;
    ]);
maskb = double(createMask(pb,h_im));

% Remove inside regions
prm = impoly(gca,[1134 1337; 1133 1232; 1790 1251; 1781 1369]);
rm1 = double(createMask(prm,h_im));
prm = impoly(gca,[1853 1371; 1851 1253; 2739 1281; 2733 1416]);
rm2 = double(createMask(prm,h_im));
prm = impoly(gca,[2741 1160; 2743 1121; 1852 1113; 1853 1149]);
rm3 = double(createMask(prm,h_im));
prm = impoly(gca,[1795 1148; 1796 1113; 1131 1108; 1131 1143]);
rm4 = double(createMask(prm,h_im));
maskb = maskb-rm1-rm2-rm3-rm4;
clearvars rm1 rm2 rm3 rm4
close

% Scale mask & image
maskb = my_scale(maskb,0.35);
Ib = my_scale(Ib,0.35);
[m,n] = size(maskb);

% Initialize Background as all-black mask and image
BGmask = zeros(M,N);
BGIm = zeros(M,N,3);

% Define image position in background
start_M = ceil(M/2 + M/8-55);
end_M = start_M + m - 1;
start_N = ceil(M/4);
end_N = start_N + n - 1;

% Place mask in the MxN background
BGmask(start_M:end_M,start_N:end_N) = maskb;
maskb = BGmask;
BGIm(start_M:end_M,start_N:end_N,1) = Ib(:,:,1);
BGIm(start_M:end_M,start_N:end_N,2) = Ib(:,:,2);
BGIm(start_M:end_M,start_N:end_N,3) = Ib(:,:,3);
Ib = BGIm;

% Crop image
maskb = maskb(1500:end,1:2000);
Ib = Ib(1500:end,1:2000,:);

% Find mask edges using diagonal 3x3 Sobel masks
sob3 = [  0  1  2 ; -1  0  1 ; -2 -1  0 ];
sob4 = [ -2 -1  0 ; -1  0  1 ;  0  1  2 ];
sb3 = conv2(maskb,sob3,'same');
sb4 = conv2(maskb,sob4,'same');
sbfin = abs(sb3)+abs(sb4);

% Remove edges and smoothen image using gaussian kernel
maskb = maskb-sbfin;
hsize = 15;
sigma = 2;
hb = fspecial('gaussian',hsize,sigma);
maskb = conv2(maskb,hb,'same');
maskb(maskb<0)=0; %Replace any negative values with 0

%% CREATE CAT MASK
close all;
Ic = im2double(imread('cat.jpg'));

%Create mask
h_im = imshow(Ic);
pb = impoly(gca,[1153 1167; 1149 1313; 1126 1381 ; 1061 1446; 1063 1554;...
     1127 1566 ;1193 1384; 1264 1496; 1308 1657; ...
    1638 1754; 1638 1679; 1521 1590; 1878 1337; 1932 1621;1963 1743; 2013 1707;...
    2045 1587; 2047 1277; 2148 1227; 2153 1324; 2241 1287; 2327 1331; 2460 1311;...
    2501 1280; 2540 1276; 2555 1086; 2479 972; 2440 874; 2310 740; 2010 659; ...
    1670 673; 1491 792; 
]);
maskc = double(createMask(pb,h_im));
close all;

%Scale mask & image
maskc = my_scale(maskc,0.1);
Ic = my_scale(Ic,0.1);
[m,n] = size(maskc);

%Define image position in background
start_M = ceil(M/2 + M/3);
end_M = start_M + m - 1;
start_N = ceil(N/4+50);
end_N = start_N + n - 1;

%Place image in MxN background
BGmask = zeros(M,N);
BGIm = zeros(M,N,3);
BGmask(start_M:end_M,start_N:end_N) = maskc;
maskc = BGmask;
BGIm(start_M:end_M,start_N:end_N,1) = Ic(:,:,1);
BGIm(start_M:end_M,start_N:end_N,2) = Ic(:,:,2);
BGIm(start_M:end_M,start_N:end_N,3) = Ic(:,:,3);
Ic = BGIm;

% Crop image
maskc = maskc(1500:end,1:2000);
Ic = Ic(1500:end,1:2000,:);

% Smoothen mask
hsize = 5;
sigma = 8;
hc = fspecial('gaussian', hsize, sigma);
maskc = conv2(maskc,hc,'same');

%% CREATE DOG 1 MASK
close all;
Id1 = im2double(imread('dog1.jpg'));

% Create mask
h_im = imshow(Id1);
pb = impoly(gca,[ 1440 947; 1375 765 ;1387 669; 1504 700 ; 1547 763;...
    1667 761; 1780 657; 1830 704; 1762 945; 2138 944; 2401 1184; 2471 1368;...
    2423 1478;2166 1563; 2100 1462; 1918 1514; 1865 1499;1851 1441; 1711 1458; ...
    1511 1640; 1481 1718; 1432 1742; 1355 1709; 1347 1649; 1529 1481; 1500 1475;...
    1391 1558; 1322 1638; 1255 1668; 1149 1633; 1296 1512; 1364 1409]);
maskd1 = double(createMask(pb,h_im));
close all;

% Scale mask & image
maskd1 = my_scale(maskd1,0.2);
Id1 = my_scale(Id1,0.2);
[m,n] = size(maskd1);

% Define image position in background
start_M = ceil(M-M/4);
end_M = start_M + m - 1;
start_N = 300;
end_N = start_N + n - 1;

% Place image in MxN background
BGmask = zeros(M,N);
BGIm = zeros(M,N,3);
BGmask(start_M:end_M,start_N:end_N) = maskd1;
maskd1 = BGmask;
BGIm(start_M:end_M,start_N:end_N,1) = Id1(:,:,1);
BGIm(start_M:end_M,start_N:end_N,2) = Id1(:,:,2);
BGIm(start_M:end_M,start_N:end_N,3) = Id1(:,:,3);
Id1 = BGIm;

% Crop image
maskd1 = maskd1(1500:end,1:2000);
Id1 = Id1(1500:end,1:2000,:);

% Smoothen mask
hsize = 30;
sigma = 10;
hd1 = fspecial('gaussian', hsize, sigma);
maskd1 = conv2(maskd1,hd1,'same');

%% CREATE DOG 2 MASK
close all;
Id2 = im2double(imread('dog2.jpg'));

% Create mask
h_im = imshow(Id2);
pb = impoly(gca,[1627 1356; 1645 1435; 1721 1559; 1729 1584;1723 1625;...
    1717 1714; 1729 1762; 1767 1779; 1789 1809; 1800 1787; 1826 1805;...
    1838 1783; 1865 1757; 1872 1735; 1883 1702; 1847 1596; 2061 1594;...
    2144 1490; 2169 1472; 2181 1431; 2243 1297; 2241 1224; 2200 1086;...
    2193 1016; 2134 916; 2001 790;1949 755; 1857 729;1780 730;1713 751;...
    1679 775; 1596 880; 1509 955; 1435 937; 1366 962; 1332 964; 1298 974;...
    1245 988; 1202 1023; 1219 1044; 1315 1048; 1381 1071; 1432 1072; 1445 1084;...
    1422 1136; 1405 1154; 1247 1250; 1238 1268; 1243 1286; 1272 1325; 1311 1362;...
    1369 1375; 1433 1370; 1540 1350; 1624 1342]);
maskd2 = double(createMask(pb,h_im));
imshow(maskd2);
close all;
clear pb;

% Scale mask & image
maskd2 = my_scale(maskd2,0.15);
Id2 = my_scale(Id2,0.15);
[m,n] = size(maskd2);

% Define image position in background
start_M = ceil(M-M/5);
end_M = start_M + m - 1;
start_N = ceil(N/2 - 200);
end_N = start_N + n - 1;

% Place image in MxN background
BGmask = zeros(M,N);
BGIm = zeros(M,N,3);
BGmask(start_M:end_M,start_N:end_N) = maskd2;
maskd2 = BGmask;
BGIm(start_M:end_M,start_N:end_N,1) = Id2(:,:,1);
BGIm(start_M:end_M,start_N:end_N,2) = Id2(:,:,2);
BGIm(start_M:end_M,start_N:end_N,3) = Id2(:,:,3);
Id2 = BGIm;

% Crop image
maskd2 = maskd2(1500:end,1:2000);
Id2 = Id2(1500:end,1:2000,:);

% Smoothen mask
hsize = 5;
sigma = 2;
hd2 = fspecial('gaussian', hsize, sigma);
maskd2 = conv2(maskd2,hd2,'same');

%% CREATE DOUKAS MASK
close all;
ID = im2double(imread('doukas.jpg'));

% Create mask
h_im = imshow(ID);
pb = impoly(gca,[330 100; 363 181; 428 186; 482 106; 521 180; 518 252;...
    599 322; 615 441; 615 456;598 471; 576 474; 582 526; 575 587; 599 635;...
    587 663; 559 678; 548 716; 551 739; 547 764; 525 772; 514 765; 513 738; 512 688; 515 658;...
    489 640;367 645; 315 643; 296 689; 289 734; 249 750; 226 721; 228 672; 226 625; 232 531;...
    239 452; 253 404; 251 316; 273 270; 265 230; 270 186; 318 104]);
maskD = double(createMask(pb,h_im));
imshow(maskD);
close all;
clear pb;

% Scale mask & image
maskD = my_scale(maskD,0.38);
ID = my_scale(ID,0.38);
[m,n] = size(maskD);

% Define image position in background
start_M = M-ceil(M/6)-85;
end_M = start_M + m - 1;
start_N = ceil(N/4+400);
end_N = start_N + n - 1;

% Place image in MxN background
BGmask = zeros(M,N);
BGIm = zeros(M,N,3);
BGmask(start_M:end_M,start_N:end_N) = maskD;
maskD = BGmask;
BGIm(start_M:end_M,start_N:end_N,1) = ID(:,:,1);
BGIm(start_M:end_M,start_N:end_N,2) = ID(:,:,2);
BGIm(start_M:end_M,start_N:end_N,3) = ID(:,:,3);
ID = BGIm;

% Crop image
maskD = maskD(1500:end,1:2000);
ID = ID(1500:end,1:2000,:);

% Smoothen mask
hsize = 5;
sigma = 5;
hD = fspecial('gaussian',hsize,sigma);
maskD = conv2(maskD,hD,'same');

clear hb hc hd1 hd2 hD
%% PYRAMID CONSTRUCTION

% Create background mask by complementing sum of other masks
maskBG = 1-(maskb+maskc+maskd1+maskd2+maskD);

%Produce gaussian kernel for Gaussian pyramids
hsize = 5;
sigma = 9/8;

% Construct Gaussian Pyramids for the images
Gb = gen_gaussPyr(Ib,Level,sigma,hsize);
clear Ib;
fprintf('Bench gaussian pyramid constructed\n');
Gc = gen_gaussPyr(Ic,Level,sigma,hsize);
clear Ic;
fprintf('Cat gaussian pyramid constructed\n');
Gd1 = gen_gaussPyr(Id1,Level,sigma,hsize);
clear Id1;
fprintf('Dog1 gaussian pyramid constructed\n');
Gd2 = gen_gaussPyr(Id2,Level,sigma,hsize);
clear Id2;
fprintf('Dog2 gaussian pyramid constructed\n');
Gp = gen_gaussPyr(Ip,Level,sigma,hsize);
clear Ip;
fprintf('P200 gaussian pyramid constructed\n');
GD = gen_gaussPyr(ID,Level,sigma,hsize);
clear ID;
fprintf('Doukas gaussian pyramid constructed\n');

% Construct Gaussian Pyramids for the masks
GMb = gen_gaussPyr(maskb,Level,sigma/1.65,hsize); 
clear maskb;
fprintf('Bench mask gaussian pyramid constructed\n');
GMc = gen_gaussPyr(maskc,Level,sigma*1.2,hsize); 
clear maskc;
fprintf('Cat mask gaussian pyramid constructed\n');
GMd1 = gen_gaussPyr(maskd1,Level,sigma,hsize); 
clear maskd1;
fprintf('Dog1 mask gaussian pyramid constructed\n');
GMd2 = gen_gaussPyr(maskd2,Level,sigma/1.6,hsize); 
clear maskd2;
fprintf('Dog2 mask gaussian pyramid constructed\n');
GMD = gen_gaussPyr(maskD,Level,sigma/1.8,hsize); 
clear maskD;
fprintf('Doukas mask gaussian pyramid constructed\n');
GMBG = gen_gaussPyr(maskBG,Level,sigma,hsize); 
clear maskBG;
fprintf('BG mask gaussian pyramid constructed\n');

% Construct Laplacian Pyramids for the images
Lb = gen_laplPyr(Gb);
fprintf('Bench Laplacian pyramid constructed\n');
Lc = gen_laplPyr(Gc);
fprintf('Cat Laplacian pyramid constructed\n');
Ld1 = gen_laplPyr(Gd1);
fprintf('Dog1 Laplacian pyramid constructed\n');
Ld2 = gen_laplPyr(Gd2);
fprintf('Dog2 Laplacian pyramid constructed\n');
LD = gen_laplPyr(GD);
fprintf('Doukas Laplacian pyramid created\n');
Lp = gen_laplPyr(Gp);
fprintf('P200 Laplacian pyramid constructed\n');

% Construct Blend Laplacian Pyramid
B = cell(Level+1,1);
B{1} = Lb{1}; % Same matrices as the other Laplacians

for k = 1:clr
    for j=2:Level
       B{j}(:,:,k) = GMb{j}.*(Lb{j}(:,:,k)) + GMc{j}.*(Lc{j}(:,:,k)) + GMd1{j}.*(Ld1{j}(:,:,k)) + ...
           GMd2{j}.*(Ld2{j}(:,:,k)) + GMD{j}.*(LD{j}(:,:,k)) + ...
           GMBG{j}.*(Lp{j}(:,:,k));  
    end
    % Last level is same as Gaussian
    B{Level+1}(:,:,k) = GMb{Level+1}.*(Gb{Level+1}(:,:,k)) + GMc{Level+1}.*(Gc{Level+1}(:,:,k)) + ...
        GMd1{Level+1}.*(Gd1{Level+1}(:,:,k)) + GMd2{Level+1}.*(Gd2{Level+1}(:,:,k)) + GMD{Level+1}.*(GD{Level+1}(:,:,k)) + ...
        GMBG{Level+1}.*(Gp{Level+1}(:,:,k));
end

% Construct Blend Gaussian Pyramid from the Laplacian
B_gauss = l2gPyr(B);

% Collapse Blend Gaussian into composite image
BGIm = B_gauss{2};

% Visualize Image
imshow(BGIm);
imwrite(BGIm,'blend.jpg');