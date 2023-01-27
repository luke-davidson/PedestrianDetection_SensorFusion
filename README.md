Pedestrian Detection with an IR, RGB, and LiDAR


-------------------------------
Goal:
-------------------------------
The purpose of this project was to utilize the sensors on Northeastern University’s NUance car (a 2016 Lincoln MKZ outfitted with 2 Velodyne LiDAR, 1 Ouster LiDAR, 4 IR cameras, 5 RGB cameras, an IMU, and a GPS) to detect pedestrians with the goal of finding their pose as well as their distance from the vehicle.


-------------------------------
Hardware Used:
-------------------------------
1 Velodyne Lidar
1 Ouster Lidar
1 IR Camera
1 RGB Camera


-------------------------------
Software Used:
-------------------------------
Python
Utilized YOLOv5 for object detection (https://github.com/ultralytics/yolov5)
We initially used Python but later transitioned to MATLAB for our project code
MATLAB
Primarily used for our project code because of its supported image, LiDAR, and ROS functions


-------------------------------
Required Packages/Toolboxes:
-------------------------------
For MATLAB:
Computer Vision Toolbox
Sensor Fusion and Tracking Toolbox
ROS Toolbox
Mapping Toolbox

For Python:
OS Module
YOLOv5 requirements.txt packages


-------------------------------
Main Code:
-------------------------------
export.launch - ROS launch file to extract messages.

extract_lidar_camera.m - Extracts the LiDAR, RGB and IR camera data from the bag and outputs time synced pointcloud data along with RGB and IR images. THe images are then used for the YOLO algorithm.

lidar_camera_fusion.m - Fuses the extracted lidar and camera data to produce 3D bounding boxes on the images and point clouds that represent the pose of the pedestrian.

looping.m - Iteratively fuses the extracted lidar and camera data on a series of images to produce 3D bounding boxes on the images and point clouds that represent the pose of the pedestrian.

ir_rgb_imfuse.m - Creates a transformation matrix between RGB and IR images, and fuses the resulting image together.

Run the following sequence of files to iteratively loop through a series of images to run our main code:
extract_lidar_camera.m
looping.m

Run the following sequence of files to run through a single image to run our main code:
extract_lidar_camera.m
lidar_camera_fusion.m


-------------------------------
Borrowed YOLO code:
-------------------------------
yolov5 folder - YOLOv5 runs and detections (https://github.com/ultralytics/yolov5).

detect.py - YOLO detection algorithm (https://github.com/ultralytics/yolov5).


-------------------------------
Additional Code:
-------------------------------
runYolov5OnEachImage.py - Created to iteratively run yolo.py and set up the runs/detect folder correctly for combineCodeForGifs.m (make sure that you have deleted all of the ‘exp#’ files in the yolov5/runs/detect folder first).

part1.m - Extracts and time syncs the LiDAR and camera data from the bag before generating RGB and IR images for the YOLO algorithm. (make sure you have correctly given the program the location of the .bag file first).

part2.py - Runs YOLO on 2 folders of IR and RGB images.

part3.m - Iteratively calculates the 3D bounding boxes on a set of IR or RGB images and also displays their 3D poses.

videoProcessingCode/entireImageAndVideoProcess.m - Initial video processing code to test images with yolov5. This file is intentionally out of date (it was only created for the initial stage of the project).

combineCodeForGifs.m -  (make sure you correctly specify the location of the ‘exp#’ files).

Run the following sequence to recreate the gifs that were composed of combined RGB and IR YOLO detection images:
part1.m
runYolov5OnEachImage.py 
combineCodeForGifs.m

Run the following sequence to display the 3D bounding boxes in tandem with the preYOLO/postYOLO images:
part1.m
part2.py
part3.m


-------------------------------
Additional Files:
-------------------------------
finalProjectFinalPresentation.pdf and finalProjectFinalPresentation.pptx - PowerPoint we created for our 20 minutes project presentation.

project_proposal.pdf - initial proposal for our project.
