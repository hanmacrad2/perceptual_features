%Add Vistalab path
%vistaroot='C:\Users\Hannah Craddock\Documents\MATLAB\packages';
%addpath(vistaroot,'Vistalab')

%********************************
%% Video - fftn 
%Load movie 
video_name = 'up_russell.mp4'; %bathsong
count = 0;
v = VideoReader(video_name); 
while hasFrame(v)
    frame = readFrame(v);
    count = count + 1;
end

%Stats on video
Nx = size(frame, 2);
Ny = size(frame, 1);
%N_channels = size(frame, 3);
Nt = count; 


%********************************
%% Save frames of video
frames = zeros(Ny, Nx, Nt); 
%fftn_frames = zeros(Ny, Nx, N_channels, Nt); 
count = 1;

v = VideoReader(video_name); %v2= VideoReader('hand_tools.mp4')
while hasFrame(v)
    frame = readFrame(v);
    frame_grey = rgb2gray(frame);
    frames(:,:, count) = frame_grey;
    count = count + 1;
end


%********************************
%% CSF
%Apply function
fsx = 90/1929;
fsy = 90/1080;
fst = 25 %Frames/sec 
% Nx = 640 %Number of columns in each frame
% Ny = 360 %Number of rows in each frame
% Nt = 563 %Number of frames 
estab = 0;
fy0 = 0;

chunk_nframes=50
chunk_shift=fst;

[CSFet,csf_fx_ft,fxx,ftt]=spatio_temp_csf(fsx,fsy,fst,Nx,Ny,chunk_nframes,estab,fy0);

%Apply then to now
csf_3d = then2now(CSFet,Nx);

%Plot
imagesc(ftt,fxx,csf_fx_ft);
xlabel('ftt');
ylabel('fxx');


%********************************
%% Overlap & add strategy 

count = 1;
energy_output = [];
frame_start = 1;
frame_end = chunk_nframes; 
while frame_end < Nt
    %Power of fftn of video across 2 seconds worth of frames x contrast
    %sensitivity function
    meanX = mean(mean(frames(:,:, frame_start: frame_end), 1),2); 
    frames(:,:, frame_start: frame_end) = frames(:,:, frame_start: frame_end) - meanX;
    energy_out_temp = abs(fftshift(fftn(frames(:,:, frame_start: frame_end)))).*csf_3d;
    energy_output(count)= mean(mean(mean(energy_out_temp, 1), 2), 3); 
    %Params
    frame_start = frame_start+ chunk_shift; %
    count = count + 1;
    frame_end = frame_end + chunk_shift %Update count end  
    
end

%Plot
plot(energy_output)
xlabel('Time (s)')
xlim([1,22])
ylabel('Amplitude of Energy')
title(sprintf('CSF -', video_name));