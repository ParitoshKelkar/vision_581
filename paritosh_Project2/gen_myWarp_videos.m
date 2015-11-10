%% generate videos for warping results
do_trig = 0;
%% INITIALIZE
% load the points
load('myBat.mat');
im2 = im2double(myBat);
load('batPoints_preProcess.mat'); % batman
im2_pts = batPoints;

load('myNC.mat');
im1 = im2double(myNC);
load('nolanPoints_preProcess2.mat'); % nol
im1_pts = nolanPoints;

    deltaR = batPoints(:,1) - nolanPoints(:,1);
    deltaC = batPoints(:,2) - nolanPoints(:,2);
    
% meanPts 
meanPtsR = nolanPoints(:,1) + 0.5.*deltaR;
meanPtsC = nolanPoints(:,2) + 0.5.*deltaC;

% preprocess the menPtsR and meanPtsC
meanPtsR(meanPtsR < 3) = 1;
meanPtsR(meanPtsR > 187) = 188;

meanPtsC(meanPtsC < 3) = 1;
meanPtsC(meanPtsC > 217) = 219;

meanPts = [round(meanPtsR) round(meanPtsC)];


% compute the triangulation for the mean triangle
tri = delaunay((meanPtsR), (meanPtsC));

% Figure 
h = figure(2); clf;
whitebg(h,[0 0 0]);


%% EVAL
if do_trig
    fname = 'my_Project2_face_eval_trig.avi';
else
    fname = 'my_Project2_face_eval_tps.avi';
end

    % VideoWriter based video creation
    h_avi = VideoWriter(fname);
    h_avi.FrameRate = 10;
    open(h_avi);

% Warp images
for w= 1/60:1/60:1
    img_source = im1;
    p_source = im1_pts;
    img_dest = im2;
    p_dest = im2_pts;
    
    
    
    
    
                       

    if (do_trig == 0)
        img_morphed = morph_tps_wrapper(img_source, img_dest, p_source, p_dest, w, w);
    else
        img_morphed = morph(img_source, img_dest, p_source, p_dest, tri, w, w);
    end
    % if image type is double, modify the following line accordingly if necessary
    writeVideo(h_avi, img_morphed);
end
close(h_avi);
clear h_avi;