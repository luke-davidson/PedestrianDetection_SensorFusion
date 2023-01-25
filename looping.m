clear all
rgb_files = dir('/media/arvinder/T7/Final_Project/online_dataset/RGB_data/*.jpg');
ptCloud_files = dir('/media/arvinder/T7/Final_Project/online_dataset/pointcloud_data/*.pcd');
ir_files = dir('/media/arvinder/T7/Final_Project/online_dataset/IR_data/*.jpg');
bbox_files_RGB = dir('/home/arvinder/RSN/src/final_project/yolov5/runs/detect/online/online_IR/*.txt');

%bag_dataPath = '/media/arvinder/T7/Final_Project/ouster_night_stationary_dataset/ouster_night_stationary.bag';
%bag = rosbag(bag_dataPath);

w = 1224;
h = 1024;
%640X512
%1224X1024

focalLength_IR = 2*[5.24888150200348832e+02, 5.21776791343664968e+02];
principalPoint_IR = 2*[3.25596989785447420e+02, 3.25596989785447420e+02];

focalLength_RGB = [1888.4451558202136, 1888.4000949073984];
principalPoint_RGB = [613.1897651359767, 482.1189409211585];
imageSize = [h, w];
intrinsics = cameraIntrinsics(focalLength_IR,principalPoint_IR,imageSize);

rotm = [-4.896527627806790e-12 4.896527627806790e-12 1; -1 0 -4.896527627806790e-12; 0 -1 4.896527627806790e-12];
trans_RGB_velodyne = [0.1 0 -0.1];
trans_RGB_ouster = [0.9 0.4 -0.1];
trans_IR = [-0.8 -0.23 0];

tform = rigid3d(rotm, trans_IR);


for q = 1:numel(bbox_files_RGB)
    rgb_filepath = fullfile(rgb_files(q).folder, rgb_files(q).name);
    ptCloud_filepath = fullfile(ptCloud_files(q).folder, ptCloud_files(q).name);
    ir_filepath = fullfile(ir_files(q).folder, ir_files(q).name);
    labels_loc = fullfile(bbox_files_RGB(q).folder, bbox_files_RGB(q).name); % exp3 test1

    size_rgb = size(imread(rgb_filepath));
    size_ir = size(imread(ir_filepath));
    img = imresize(imread(ir_filepath), 'OutputSize', size_rgb(1, 1:2));
    %img = imread(rgb_filepath);

    pc = pcread(ptCloud_filepath);    
    imPts = projectLidarPointsOnImage(pc,intrinsics,tform);
    %hold off
    %figure(1)
    %imshow(img)
    %hold on
    try 
        figure(2)
        hold off
        pcshow(pc)
        xlim([-10 20])
        ylim([-10 20])
        zlim([-2.5 20])
        %view(-90,10)
        fileID = fopen(labels_loc,'r');
        formatSpec = '%f';
        A = fscanf(fileID,formatSpec);
        k = 1;
        clusterpoints = [];
        if length(A)>=5
            for i = 1:5:length(A)
                if A(i)==0
                    x_center= A(i+1,1)*w;
                    y_center= A(i+2,1)*h;
                    width= A(i+3,1)*w;
                    height= A(i+4,1)*h;
                    xLeft = x_center - width/2;
                    yLeft = y_center - width/2;
                    xBottom = x_center - height/2;
                    yBottom = y_center - height/2;
                    bbox = [xLeft, yBottom, width, height];
                    %figure(1)
                    %hold on 
                    
                    %{
                    for j = 1:length(imPts)
                        if imPts(j,1)<=xLeft+width &&  imPts(j,1)>=xLeft
                            if imPts(j,2)<=yBottom+height &&  imPts(j,2)>=yBottom
                                clusterpoints(k, 1) = imPts(j,1);
                                clusterpoints(k, 2) = imPts(j,2);
                                k = k+1;
                            end
                        end
                    end
                    
                    
                    %rectangle('Position', bbox, 'EdgeColor', 'b', 'LineWidth', 2);
        
                    if isempty(clusterpoints) == false
                        plot(clusterpoints(:,1),clusterpoints(:,2),'.','Color','r')
                    end
        %}
                    bboxLidar = bboxCameraToLidar(bbox,pc,intrinsics,invert(tform),'ClusterThreshold',1);
                    bbox=[floor(xLeft), floor(yBottom), floor(width), floor(height)];
                    dist_x=bboxLidar(:,1);
                    dist_y=bboxLidar(:,2);
                    dist_z=bboxLidar(:,3);
                    if isempty(dist_x)==false
                        dist=sqrt(dist_x^2+dist_y^2+dist_z^2)-2;
                        labels="pedestrian"+dist+"m";
                        %figure(1)
                        %hold on 
                        %showShape('rectangle',bbox,'color','yellow','Label',labels)
        
                        figure(2)
                        hold on
                        showShape('cuboid',bboxLidar,'Opacity',0.5,'Color','red','Label',labels,'LabelTextColor','green','LabelFontSize',6)
                    end

                end
            end
        end
    
    catch

    end 
hold off
end
