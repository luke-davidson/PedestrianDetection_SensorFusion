% ------ Steps to run the code:
% 1. You must have the bag file in the same location as this code.
% 2. You need to create a folder in the same location as this code
%    called "'name of bag'_bag" (for ex: if your bag is named 
% 'asdf.bag', you'll need to name the folder: 'asdf_bag')
% 3. Inside of this newly created bag folder, also add the following 
% folders: 'imagesCam0' and 'imagesBoson'
% 4. change the string variable called 'front' (located on line 22) 
% with the correct name of your bag file and bag file folder. 
% For example: If your bag was called 'asdf.bag'
% then the string you store in the variable 'front' should be 'asdf'

% ------ Additional Info:
% Cam0 is RGB
% Boson is IR
% We are no longer using Cam4 (it is on the other side of the car)
% (The side lidar that we recorded is on the Cam0 side)

% I chose to hardcode this stuff instead of using a for loop because
% I'm pretty sure the for loop kept forcing my MATLAB to close. I assumed
% that it kept closing because the data in a for loop gets stored in a
% smaller temporary data location. This could have been entirely 
% unrelated, though. The code still works this way.

% ... means that the line of code continues on the next line.

front = "2022-04-09-02-15-56"; % name of the bag before the file type
bag_name = front + "_bag";
bag = rosbag(string([front + '.bag']));
bag.AvailableTopics

pauseDelay = 10; % 10 seconds pause between each step
% The image and video processing takes a lot of CPU usage so the 10 
% seconds between each video and set of images just gives your CPU a small 
% break. (I added this because my computer got pretty hot without it)

bagSelectRaw = select(bag,"Topic",...
    "/boson_camera_array/cam_right/image_raw"); 
msgStructsRaw = readMessages(bagSelectRaw, 'DataFormat','struct');
height = cellfun(@(m) double(m.Height),msgStructsRaw);
height = height(1,:);
width = cellfun(@(m) double(m.Width),msgStructsRaw);
width = width(1,:);

numImages = length(msgStructsRaw);
numBoson = numImages;
for eachIn=1:numImages
    data = arrayfun(@(m) double(m.Data), msgStructsRaw{eachIn},...
        'uniformOutput', false);
    data = cell2mat(data);
    image = zeros(height, width, 1);
    a = 1;
    for row=1:height
        for col=1:width
            image(row, col, 1) = data(a,1);
            a = a + 1;
        end
    end
    filename = string(bag_name) + '/imagesBoson/image'...
        + num2str(eachIn) + '.jpg';
    imwrite(uint8(image), filename);
    disp(string(filename) + ' has been saved.')
end
disp('Boson images are all created.')
pause(pauseDelay);

bagSelectRaw = select(bag,"Topic", "/camera_array/cam0/image_raw");
msgStructsRaw = readMessages(bagSelectRaw, 'DataFormat','struct');
height = cellfun(@(m) double(m.Height),msgStructsRaw);
height = height(1,:);
width = cellfun(@(m) double(m.Width),msgStructsRaw);
width = width(1,:);

numImages = length(msgStructsRaw);
numCam0 = numImages;
for eachIn=1:numImages
    data = arrayfun(@(m) double(m.Data), msgStructsRaw{eachIn},...
        'uniformOutput', false);
    data = cell2mat(data);
    image = zeros(height, width, 3);
    a = 1;
    for row=1:height
        for col=1:width
            image(row, col, 1) = data(a,1); a = a + 1;
            image(row, col, 2) = data(a,1); a = a + 1;
            image(row, col, 3) = data(a,1); a = a + 1;
        end
    end
    filename = string(bag_name) + '/imagesCam0/image'...
        + num2str(eachIn) + '.jpg';
    imwrite(uint8(image), filename);
    disp(string(string(filename) + ' has been saved.'))
end
disp('Cam0 images are all created.')
pause(pauseDelay);

video = VideoWriter(string(bag_name) + '/videoCam0.mp4',...
    'MPEG-4'); %create the video object
video.FrameRate = 30; % frames per second (fps)
open(video); %open the file for writing
N = numCam0;
for each=1:N %where N is the number of images
  filename = string(bag_name) + '/imagesCam0/image' + num2str(each)... 
      + '.jpg';
  I = imread(string(filename)); %read the next image
  writeVideo(video,I); %write the image to file
end
close(video); %close the file
disp(string(bag_name) + '/videoCam0.mp4 finished.')
pause(pauseDelay);

video = VideoWriter(string(bag_name) + '/videoBoson.mp4',...
    'MPEG-4'); %create the video object
video.FrameRate = 8; % frames per second (fps)
open(video); %open the file for writing
N = numBoson;
for each=1:N %where N is the number of images
  filename = string(bag_name) + '/imagesBoson/image'...
      + num2str(each) + '.jpg';
  I = imread(string(filename)); %read the next image
  writeVideo(video,I); %write the image to file
end
close(video); %close the file
disp(string(bag_name) + '/videoBoson.mp4 finished.')

disp('Program had finished. Figures have been saved as images.')
disp('Your Cam0 video is located at: ' + string(bag_name)...
    + '/videoCam0.mp4')
disp('Your Boson video is located at: ' + string(bag_name)...
    + '/videoBoson.mp4')