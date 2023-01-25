% This code was used to combine videos for the presentation to guarantee
% that the videos would be synced after they were added to the powerpoint.
% (When we made the videos into gifs and added them to the powerpoint
% they weren't synced so we had to write this code to combine the videos)

videoCam0 = VideoWriter('part1_bag/videoCam0.mp4', 'MPEG-4'); %create the video object
videoCam0.FrameRate = 8; %30 fps
open(videoCam0); %open the file for writing

videoIR = VideoWriter('part1_bag/videoBoson.mp4', 'MPEG-4'); %create the video object
videoIR.FrameRate = 8; %30 fps
open(videoIR); %open the file for writing

videoCombined = VideoWriter('part1_bag/videoCombined.mp4', 'MPEG-4');
videoCombined.FrameRate = 8; %30 fps
open(videoCombined); %open the file for writing

N = 128;
expNum = 1;
for each=1:N %where N is the number of images
  if expNum == 1
      filename = (['runs/detect/exp/image' num2str(each) '.png']);
  else
      filename = (['runs/detect/exp' num2str(expNum) '/image' num2str(each) '.png']);
  end
  expNum = expNum + 1;
  A = imread(string(filename)); %read the next image
  writeVideo(videoCam0,A); %write the image to file

  filename = (['runs/detect/exp' num2str(expNum) '/image' num2str(each) '.png']);
  I = imread(string(filename)); %read the next image
  writeVideo(videoIR,I); %write the image to file
  
  newA = imresize(A, 0.5);
  writeVideo(videoCombined, [newA I])
  expNum = expNum + 1;
end
close(videoCam0); %close the file
disp('rgbVideoCam0.mp4 finished.')

close(videoIR); %close the file

close(videoCombined);
disp('irVideoBoson.mp4 finished.')
disp('Program had finished. Figures have been saved as images.')