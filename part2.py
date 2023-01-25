import os

# need to replace 740 with your total number of images:
for each in range(740):
    command = "python3.9 detect.py --source part1_bag/imagesCam0/image" + str(
        each + 1) + ".png --save-txt --classes 0"
    os.system(str(command))
    command = "python3.9 detect.py --source part1_bag/imagesBoson/image" + str(
        each + 1) + ".png --save-txt --classes 0"
    os.system(str(command))
