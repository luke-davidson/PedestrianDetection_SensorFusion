% Load the results from part1
% You can remove this next line if you don't close your matlab workspace
% in between running part1 and part3
% load savedWorkspace 
% disp('Saved workspace loaded')
close all
frames = bag.AvailableFrames;
gettf = getTransform(bag,frames{21},frames{4});
tf = gettf.Transform;
ros_quat = tf.Rotation;
quat = [ros_quat.X ros_quat.Y ros_quat.Z ros_quat.W];
rotm = quat2rotm(quat);

% Get transformation data:
ros_trans = tf.Translation;
trans = [ros_trans.X ros_trans.Y ros_trans.Z];

% Transform the data:
tform = rigid3d(rotm, trans);

% counter to store the txt name numbers:
counter = 0;

% Lidar Camera Fusion:
for i = 1:2:length(idx) % steps by 2
    ptCloud = pointCloud(readXYZ(lidarMsgs{idx(i,2)}));

    % Project points onto the image:
    % p1 = pcdownsample(ptCloud,'gridAverage',0.5);
    imPts = projectLidarPointsOnImage(ptCloud,intrinsics,tform);

    % Instead we're reading in the already run yolo images:
    counter = counter + 1; % counter from exp to exp1468 (for this bag)
    if i == 1
        labels_loc = 'runs/detect/exp/labels/image1.txt';
        img = '2022-04-21-14-28-34_bag/imagesCam0/image1.png';
        % img = 'runs/detect/exp/image1.png';
    else
        labels_loc = strcat('runs/detect/exp', num2str(i), '/labels/image', ...
            num2str(counter), '.txt');
        img = strcat('2022-04-21-14-28-34_bag/imagesCam0/image',...
            num2str(counter), '.png');
        % img = strcat('runs/detect/exp', num2str(i), '/image', ...
        %     num2str(counter), '.png');
    end
    disp(strcat("Displaying image: ", img))

    if i == 1
        figure(1)
        imshow(img)
        % player = pcplayer([0 60] ,[-40 40],[-5 30]);
        player = pcplayer([-5 20] ,[-5 10],[-2.5 5]);
    end
    if isOpen(player)
        view(player, ptCloud);
    end 
    
    fileID = fopen(labels_loc,'r');
    formatSpec = '%f';
    A = fscanf(fileID,formatSpec);
    w = 1224;
    h = 1024;
    k = 1;
    clusterpoints = [];
    if length(A)>=5
        for inner_i = 1:5:length(A)
            if A(inner_i)==0
                x_center= A(inner_i+1,1)*w;
                y_center= A(inner_i+2,1)*h;
                width= A(inner_i+3,1)*w;
                height= A(inner_i+4,1)*h;
                xLeft = x_center - width/2;
                yLeft = y_center - width/2;
                xBottom = x_center - height/2;
                yBottom = y_center - height/2;
                bbox = [xLeft, yBottom, width, height];
                figure(1)
                imshow(img)
                movegui(1, 'west');
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

                bboxLidar = bboxCameraToLidar(bbox,ptCloud,intrinsics,...
                    invert(tform),'ClusterThreshold',1);

                % Checks to make sure that the player is open before it
                % tries plotting:
                if isOpen(player)
                    % Displays the point cloud:
                    view(player, ptCloud);

                    % Displays the 3D boxes on the pedestrians:
                    showShape('cuboid',bboxLidar,'Parent',player.Axes,...
                        'Opacity',0.5,'Color','red') 

                    % Syncs the drawn shapes with the pcplayer
                    drawnow
                else
                    % This is unneeded. It is here for debugging
                    % purposes incase you're worried that it's not
                    % actually plotting everything:
                    disp("Player was closed?")
                end
            end
        end
    end
    % drawnow

    % This is so we do not draw stuff again on the same image by
    % closing the current image before we open the next:
    hold off
end
