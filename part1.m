% Extract Lidar Camera:
clear
close all

% Read Bag:
dataPath = 'finalProjectData/part1.bag';
bag_name = 'part1_bag';
% '/media/arvinder/T7/Final_Project/stationary_day_dataset/stationary.bag';
bag = rosbag(dataPath);
bag.AvailableTopics % Lists the available topics

% Select Topics
cameraTopic = select(bag,'Topic','/camera_array/cam0/image_raw');
lidarTopic = select(bag,'Topic','/ns1/velodyne_points');
% osLidarTopic = select(bag,'Topic','/os_cloud_node/points');
irTopic = select(bag,'Topic','/flir_boson/image_raw');
% irTopic = select(bag, 'Topic', '/boson_camera_array/cam_right/image_raw');

% Read topic messages:
cameraMsgs = readMessages(cameraTopic);
lidarMsgs = readMessages(lidarTopic);
irMsgs = readMessages(irTopic);
% osLidarMsgs = readMessages(osLidarTopic);

% Gather time series info for each message and store it in a time series:
timeSeriesCam = timeseries(cameraTopic);
timeSeriesLidar = timeseries(lidarTopic);
% timeSeriesOSLidar = timeseries(osLidarTopic);
timeSeriesIR = timeseries(irTopic);

% Extract the time information from the time series variables:
timeCam = timeSeriesCam.Time;
timeLidar = timeSeriesLidar.Time;
% timeOSLidar = timeSeriesOSLidar.Time;
timeIR = timeSeriesIR.Time;

% Incrementing variables for later:
k = 1;
k2 = 1;

% Check to see if there are more lidar times or cam times:
if size(timeLidar,1) > size(timeCam,1)
    % There are more lidar times than cam times:
    for i = 1:size(timeCam,1)
        [val,indx] = min(abs(timeCam(i) - timeLidar));
        if val <= 0.1
            idx(k,:) = [i indx];
            k = k + 1;
        end
    end
else
    % There are more cam times than lidar times:
    for i = 1:size(timeLidar,1)
        [val,indx] = min(abs(timeLidar(i) - timeCam));
        if val <= 0.1
            idx(k,:) = [indx i];
            k = k + 1;
        end
    end
end

% Check to see if there are more IR times or Cam times:
if size(timeIR,1) > size(timeCam,1)
    % There are more IR times than Cam times:
    for j = 1:size(timeCam,1)
        [val2,indx2] = min(abs(timeCam(j) - timeIR));
        if val2 <= 0.1
            idx2(k2,:) = [j indx2];
            k2 = k2 + 1;
        end
    end
else
    % There are more cam times than IR times: 
    for j = 1:size(timeIR,1)
        [val2,indx2] = min(abs(timeIR(j) - timeCam));
        if val2 <= 0.1
            idx2(k2,:) = [indx2 j];
            k2 = k2 + 1;
        end
    end
end


% Interpret Intrinsic Camera data:
focalLength = [1888.4451558202136, 1888.4000949073984];
principalPoint = [613.1897651359767, 482.1189409211585];
imageSize = [1024, 1224];
intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);

% We need this in here for now (so we can make the images with the rest of
% the code commented out) until we can iterate through each image and
% run the python program in the script.
for i = 1:length(idx)
    RGB = readImage(cameraMsgs{idx(i,1)});
    IR = readImage(irMsgs{idx2(i,2)});
    filename = string(bag_name) + '/imagesCam0/image'...
        + num2str(i) + '.png';
    imwrite(uint8(RGB), filename);
    disp(string(filename) + ' has been saved.')

    filename = string(bag_name) + '/imagesBoson/image'...
        + num2str(i) + '.png';
    imwrite(IR, filename);
    disp(string(filename) + ' has been saved.')
end

% Store the results for the next program (we're trying to get rid of this)
% You can remove this next line if you don't close your matlab workspace
% in between running part1 and part3
% save('savedWorkspace', '-v7.3')