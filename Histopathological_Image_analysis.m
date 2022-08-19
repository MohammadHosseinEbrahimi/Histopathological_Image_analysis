%%%%%%%%%%%%%%%%%%%%%%%
% This script is to analyze histopathological images based on 
% a selected Region of Interest (ROI).  
% 
%
% Script loads the image data, allows the user to manually select up to 5
% ROIs, adjust, rotate and reshape the ROIs and cut the ROIs from the rest of image
% and extract the data.
% 
% This was particularly used to analyze digital densitometry images of cartilage samples
% to extract depth-dependent profiles. However, This can be used for various other applications.
% 
% Mohammadhossein Ebrahimi 19.08.2018
%
%%%%%%%%%%%%%%%%%%%%%%%%


clear all;
close all;
clc

[filename, pathname] = uigetfile( ...
    {'*.mat','MATLAB Image Files (*.mat)';
    '*.*',  'All Files (*.*)'}, ...
    'Multiselect','on', ...
    'Pick a file');

if iscell(filename) == 0
    filename = {filename};
end

load([pathname,filename{1}]);
kuva_az90 = Image_OD(:,:,1);
figure; %% Comment it out if you do not want to have separate figure
x_ax=size(kuva_az90,2);
x_ax_mm=(x_ax*1.4)/1000; %% to convert to mm, Comment it out if not needed
x_axis=linspace(0,x_ax_mm,x_ax);
y_ax=size(kuva_az90,1);
y_ax_mm=(y_ax*1.4)/1000;
y_axis=linspace(0,y_ax_mm,y_ax);
      
        

fig=imagesc(kuva_az90,'CDataMapping','scaled',[0 1600]) %% adjust this based on image intensity
set(fig, 'XData', x_axis,'YData',y_axis);
colormap(jet(256))
axis image

profile_H ={};profile_V={};avg={};

for i= 1:5
    
    h = drawrectangle (gca,'Position',[0,0,1,1],'Rotatable',true,'Label',num2str(i));
    wait (h)
    
    h2=h.Vertices;
	
    % Location where the ROI will appear. 
    c=[h2(1,1) h2(2,1) h2(3,1) h2(4,1)];
    r2=[h2(1,2) h2(2,2) h2(3,2) h2(4,2)];
    
    rot=h.RotationAngle;
    
    
    BW3 = createMask(h);
    
    % Use logical indexing to set area outside of ROI to zero:
    ROI = kuva_az90;
    ROI(BW3 == 0) = 0;
    
    mask = ROI ~= 0; % Find all zeros, even those inside the image.
    mask = imfill(mask, 'holes'); % Get rid of zeros inside image.
    % Invert mask and get bounding box.
    props = regionprops(~mask, 'BoundingBox');
    % Crop image.
    croppedImage1 = imcrop(ROI, props.BoundingBox);
    

    croppedImage2 = imrotate(ROI,-1*rot);
    [row,col,v]=find(croppedImage2~=0);
    croppedImage  = croppedImage2 (min(row):max(row),min(col):max(col));
    
    % for background removal
    croppedImage = double(croppedImage);
    croppedImage (croppedImage<100)= nan; %% adjust this based on image background intensity
    
    croppedImage =croppedImage/1000;
    
    profile_V1 = flipud(nanmean(croppedImage,2));
    profile_H1 = flipud(nanmean(croppedImage,1));
    avg1 = nanmean(croppedImage,'all');
    
    
    ss=char(filename);
    
    if exist([pathname '\Results'],'dir') == 0
        mkdir([pathname '\Results']);
    end
    save([pathname '\Results\DD_',ss(1:(end-4)),'_',num2str(i),'.mat'],'croppedImage');
    
    
    profile_H(1,i) = {profile_H1};
    profile_V(1,i) = {profile_V1};
    avg(1,i) = {avg1};
    save([pathname '\Results\DD_',ss(1:(end-4)),'.mat'],'profile_V','profile_H','avg');
    
    
    
    
    if i ==1
        image1= croppedImage;
    elseif i==2
        image2= croppedImage;
    elseif i==3
        image3= croppedImage;
    elseif i==4
        image4= croppedImage;
    else
        image5= croppedImage;
        
    end
end

%To save the whole image
saveas(fig,[pathname '\Results\Image_',ss(1:(end-4)),'.jpg']);
saveas(fig, [pathname '\Results\Image_',ss(1:(end-4)),'.fig']);


fig2=figure;


for j=1:5

image=['image',num2str(j)];
subplot(5,1,j);

imagee=eval(image);

imagesc(imagee,[0 1.6]);
colormap(jet(256))
axis image

end

%To save the ROIs
saveas(fig2,[pathname '\Results\ROIs_',ss(1:(end-4)),'.jpg']);
saveas(fig2, [pathname '\Results\ROIs_',ss(1:(end-4)),'.fig']);

