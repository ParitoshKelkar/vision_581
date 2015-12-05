%% test to see what is better - detect and track or detect everytime
 

% get the video
videoName = 'Anchorman.mp4';
inputVideo = VideoReader(videoName);

% read frames of the incoming video
frame1 = read(inputVideo);

% Create the face detector object.
faceDetector = vision.CascadeObjectDetector();

% Create the point tracker object.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Capture one frame to get its size.
frameSize = size(frame1);

% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);



