% EECE 5554 - Group 4
% IR and RGB Fusion - Pedestrian Detection

close all;

%% Reading, grayscale, sizing
                % Reading and conversion
% ir_im = imread('/Users/lukedavidson/Downloads/northeastern/eece5554_rsn/ir_rgb_fuse/ir_im2.jpg');
% rgb_im = imread('/Users/lukedavidson/Downloads/northeastern/eece5554_rsn/ir_rgb_fuse/rgb_im2.jpg');

ir_im = imread('/Users/lukedavidson/Desktop/ir_im_box2.png');
rgb_im = imread('/Users/lukedavidson/Desktop/rgb_im_box2.png');

rgb_to_gray = rgb2gray(rgb_im);
imresize(rgb_to_gray,[1024 1224]);
% size_ir = size(ir_im);
% rgb_im_resize = imresize(rgb_im,size_ir);

                % Sizing
size_rgb = size(rgb_to_gray);
ir_im_resize = imresize(ir_im,size_rgb);


                % Display Images
% figure
% subplot(1,2,1)
% imshow(rgb_to_gray)
% title('Grayscale RGB Image')
% subplot(1,2,2)
% imshow(ir_im_resize)
% title('IR Image')


%% Finding Transformation Matrix
                % Matching Points
% Random
% movingPoints = [397 99; 765 853; 895 93; 143 533; 523 505; 1127 685];
% fixedPoints = [447 307; 499 735; 705 305; 303 543; 503 531; 737 635];

% More Random
% movingPoints = [397 99; 895 93; 143 533; 523 505; 1127 685; 765 853; 593 889; 699 647; 661 389; 527 579; 605 697];
% fixedPoints = [447 307; 705 305; 303 543; 503 531; 737 635; 499 735; 399 743; 461 619; 447 479; 381 577; 419 643];

% ME

                % Transformation
movingPoints = [765 853; 593 889; 699 647; 661 389; 527 579; 605 697];
fixedPoints = [499 735; 399 743; 461 619; 447 479; 381 577; 419 643];

tform = fitgeotrans(movingPoints,fixedPoints,'projective');


% tform.T;

                % Projection
rgb_warped = imwarp(rgb_im,tform);
rgb_warped_translated = imtranslate(rgb_warped,[155,220],"OutputView","full"); % non = [85,250]; projective = [155,220]
                

                % Display
figure
imshow(ir_im_resize)
alpha(0.4)
hold on
imshow(rgb_warped_translated)
alpha(0.4)
title('Projective Transformation')


%% Plot Overlying Transparent Images

% figure
% image(rgb_im)
% axis image
% hold on
% im = image(ir_im_resize);
% im.AlphaData = max(ir_im_resize,[],3);    
% hold off

% figure
% image(ir_im_resize)
% axis image
% hold on
% im = image(rgb_warped);
% im.AlphaData = max(rgb_warped,[],3);    
% hold off