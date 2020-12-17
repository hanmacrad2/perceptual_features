%Add Vistalab path
%vistaroot='C:\Users\Hannah Craddock\Documents\MATLAB\packages';
%addpath(vistaroot,'Vistalab')

%********************************
%% Video - fftn 
%Load movie 
%video_name = 'https://drive.google.com/drive/u/3/folders/1CmPqs8Zm_dLbP-K-5uFN5a3bl6X-OxmB/bathsong.mp4'
%video_name = 'bathsong.mp4'; %bathsong
v = VideoReader(video_name); 
%Stats on video
Nx = v.Width;
Ny = v.Height;
%N_channels = size(frame, 3);
Nt = v.NumFrames; 


%********************************
%% Save frames of video
frames = zeros(Ny, Nx, Nt); 
%fftn_frames = zeros(Ny, Nx, N_channels, Nt); 
count = 1;

while hasFrame(v)
    frame = readFrame(v);
    frame_grey = rgb2gray(frame);
    %Determine mean 
    %meanGrayLevel = mean2(frame_grey); % This is a double.
    %Image_no_dc = double(frame_grey) - meanGrayLevel;
    frames(:,:, count) = frame_grey;
    count = count + 1;
end

%% *****************
%fft
f=fftn(frames);
f2 = fftshift(f);
plot(abs(mean(mean(f2,2),3)));
ylim([0, 0.25])

plot(abs(mean(mean(f,2),3)));
ylim([0, 0.25])

%********************************
%% CSF
%Apply function
% degrees of visual angle
width_degrees=90;
%width_pixels=v.Width; % if video is full screen, this many pixels across 90 degrees
width_pixels=1929; % if projector has this many pixels across and video is video width (i.e., 640) pixels across
fst = v.FrameRate %Frames/sec 

% these two lines for testing graph
% width_degrees=30;
% fst=50;

fsx = width_pixels/width_degrees;  % pixels/degree; video width in pix/ 90 degrees of visual angle
fsy = fsx; % Assume square pixels


%%
% Nx = 640 %Number of columns in each frame
% Ny = 360 %Number of rows in each frame
% Nt = 563 %Number of frames 
estab = 0; % eye stabliation
fy0 = 0;

chunk_dur_secs=2;
chunk_shift_secs=1;

chunk_dur_nframes=fst*chunk_dur_secs;
chunk_shift_nframes=fst*chunk_shift_secs;

[CSFet,csf_fx_ft,fxx,ftt]=spatio_temp_csf(fsx,fsy,fst,Nx,Ny,chunk_dur_nframes,estab,fy0);

%Apply then to now
csf_3d = then2now(CSFet,Nx);

%Plot
figure(1)
imagesc(ftt,fxx,csf_fx_ft);
xlabel('ftt');
ylabel('fxx');

% Plot spatial CSF for unchanging stimuli 
figure(3)
ind=find(ftt==0); % zero temporal frequency
plot(fxx,mean(csf_3d(:,:,ind),1));
xlabel('Spatial frequency (cpd)');

% Plot spatio-temporal CSF averaged across pixels in one dimension
figure(3)
ind=find(ftt==0); % zero temporal frequency
csf_plane= squeeze(mean(csf_3d(Ny/2+1,:,:),1));
imagesc(fxx,ftt,csf_plane);
xlabel('Spatial frequency (cpd)');
ylabel('Temporal frequency (Hz)');

figure(4)
contour(ftt,fxx,csf_plane);
xlabel('Spatial frequency (cpd)');
ylabel('Temporal frequency (Hz)');
set(gca,'XScale','log')
set(gca,'YScale','log')

figure(5)
clf
hold on
freqs=[1,6,16, 22];
leg={};
for freqind=1:length(freqs)
    [val ind]=min(abs(ftt-freqs(freqind)));
    semilogx(fxx(321:end),csf_plane(321:end,ind));
    leg{end+1}=num2str(ftt(ind));
end;
legend(leg)
xlim([0.2,50])
ylim([2,500])
set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')
xlabel('Spatial frequency (cpd)');
ylabel('Contrast sensitivity');

xt = get(gca,'xtick');
for j=1:length(xt)
    % With log plots, MATLAB defaulted to exponential format, that is difficult for lay
    % readerst to understand. In my case, I wanted integer format.
    XTL{1,j} = num2str(xt(j),'%d');
end
xticklabels(XTL);

yt = get(gca,'ytick');
for j=1:length(yt)
    % With log plots, MATLAB defaulted to exponential format, that is difficult for lay
    % readerst to understand. In my case, I wanted integer format.
    YTL{1,j} = num2str(yt(j),'%d');
end
yticklabels(YTL);


%********************************
%% Overlap & add strategy 

count = 1;
energy_output = [];
frame_start = 1;

frame_end = chunk_dur_nframes; 
while frame_end < Nt
    %Power of fftn of video across 2 seconds worth of frames x contrast
    %sensitivity function
    chunk=frames(:,:, frame_start: frame_end);
    meanX= mean(chunk(:));
    chunk=chunk-meanX;
    energy_out_temp = abs(fftshift(fftn(chunk))).*csf_3d;
    %energy_output(count)= mean(mean(mean(energy_out_temp, 1), 2), 3); 
    energy_output = [energy_output mean(mean(mean(energy_out_temp, 1), 2), 3);] ; 
    %Params
    frame_start = frame_start + chunk_shift_nframes; %
    count = count + 1;
    frame_end = frame_end + chunk_shift_nframes %Update count end  
    
end

%% Plot
figure(2)
subplot 211
chunk_onsets_secs=(1:chunk_shift_nframes:(v.NumFrames-chunk_dur_nframes))/fst; 
xlabel('Time (s)')
xlim([1,22])
ylabel('Amplitude of Energy')
title(sprintf('CSF -', video_name));


% Let's also calculate RMS for comparison
rms=sqrt(sum(sum(diff(frames,1,3).^2,1),2)/(Nx*Ny));
subplot 212 
plot((1:v.NumFrames-1)/fst, squeeze(rms)) % one fewer timepoint as this is a difference
xlabel('Time (s)');
ylabel('RMS')
