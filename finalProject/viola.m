% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

% Read a video frame and run the detector.
videoFileReader = VideoReader(videoName);
n = 1;

while (n < 19*30)
%videoFrame      = step(videoFileReader);
    videoFrame      = read(videoFileReader,n);
    bbox            = step(faceDetector, videoFrame);

% Draw the returned bounding box around the detected face.
    videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox,'Face');
    step(videoPlayer, videoOut);

    n = n + 1;
end