%Add Vistalab path
%vistaroot='C:\Users\Hannah Craddock\Documents\MATLAB\packages';
%addpath(vistaroot,'Vistalab')

%% Video - fftn 
%Load movie 
count = 0;
v = VideoReader('bathsong.mp4'); %v2= VideoReader('hand_tools.mp4')
while hasFrame(v)
    frame = readFrame(v);
    count = count + 1;
end

%Stats on video
Nx = size(frame, 2);
Ny = size(frame, 1);
%N_channels = size(frame, 3);
Nt = count; 

%% Save frames of video
frames = zeros(Ny, Nx, Nt); 
%fftn_frames = zeros(Ny, Nx, N_channels, Nt); 
count = 1;

v = VideoReader('bathsong.mp4'); %v2= VideoReader('hand_tools.mp4')
while hasFrame(v)
    frame = readFrame(v);
    frame_grey = rgb2gray(frame)
    frames(:,:, count) = frame_grey;
    count = count + 1;
end

%% CSF
%Apply function
fsx = 90/1929;
fsy = 90/1080;
fst = 25 %Frames/sec 
% Nx = 640 %Number of columns in each frame
% Ny = 360 %Number of rows in each frame
% Nt = 563 %Number of frames 
estab = 0
fy0 = 0

[CSFet,csf_fx_ft,fxx,ftt]=spatio_temp_csf(fsx,fsy,fst,Nx,Ny,Nt,estab,fy0);

%Apply then to now
csf_3d = then2now(CSFet,Nx);

%Plot
imagesc(ftt,fxx,csf_fx_ft)
xlabel('ftt')
ylabel('fxx')

%% Overlap & add strategy 

count = 1;
energy_output = [];
frame_start = 1;
frame_end = 2*fst; 
while frame_end < Nt
    %Power of fftn of video across 2 seconds worth of frames x contrast
    %sensitivity function 
    energy_out_temp = abs(fftn(frames(:,:, frame_start: frame_end))).*csf_3d(:,:, frame_start:frame_end);
    energy_output(count)= mean(mean(mean(temp, 1), 2), 3); 
    %Params
    frame_start = count*fst; %
    count = count + 1;
    frame_end = frame_end + fst %Update count end  
    
end

%plot
plot(energy_output)
xlabel('Time (s)')
xlim([1,22])
ylabel('Amplitude of Energy')
title('CSF - Bathsong')