img = '/media/arvinder/T7/Final_Project/part1/camera_data/0557.png';
ptCloud = '/media/arvinder/T7/Final_Project/part1/pointcloud_data/0557.pcd';
dataPath = '/media/arvinder/T7/Final_Project/part1/part1.bag';
bag = rosbag(dataPath);

pc = pcread(ptCloud);

focalLength = [1888.4451558202136, 1888.4000949073984];
principalPoint = [613.1897651359767, 482.1189409211585];
imageSize = [1024, 1224];
intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);
camera_info = select(bag,'Topic','/camera_array/cam0/camera_info');
cameraMsgs = readMessages(camera_info);

frames = bag.AvailableFrames;
gettf= getTransform(bag,frames{21},frames{4});
tf = gettf.Transform;
ros_quat = tf.Rotation;
quat = [ros_quat.X ros_quat.Y ros_quat.Z ros_quat.W];
rotm = quat2rotm(quat);


ros_trans = tf.Translation;
trans = [ros_trans.X ros_trans.Y ros_trans.Z];

tform = rigid3d(rotm, trans);

p1 = pcdownsample(pc,'gridAverage',0.5);
imPts = projectLidarPointsOnImage(pc,intrinsics,tform);
figure(1)
imshow(img)

%plot(imPts(:,1),imPts(:,2),'.','Color','r')

figure(2)
pcshow(pc)

labels_loc = '/home/arvinder/RSN/src/final_project/yolov5/runs/detect/exp5/labels/part1_557.txt';
fileID = fopen(labels_loc,'r');
formatSpec = '%f';
A = fscanf(fileID,formatSpec);
w = 1224;
h = 1024;
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
            figure(1)
            hold on 
            
            
            for j = 1:length(imPts)
                if imPts(j,1)<=xLeft+width &&  imPts(j,1)>=xLeft
                    if imPts(j,2)<=yBottom+height &&  imPts(j,2)>=yBottom
                        clusterpoints(k, 1) = imPts(j,1);
                        clusterpoints(k, 2) = imPts(j,2);
                        k = k+1;
                    end
                end
            end
            
            
            rectangle('Position', bbox, 'EdgeColor', 'b', 'LineWidth', 2);

            if isempty(clusterpoints) == false
                plot(clusterpoints(:,1),clusterpoints(:,2),'.','Color','r')
            end

            bboxLidar = bboxCameraToLidar(bbox,pc,intrinsics,invert(tform),'ClusterThreshold',1);
            figure(2)
            hold on
            showShape('cuboid',bboxLidar,'Opacity',0.5,'Color','red')

        end
    end
end

hold off



