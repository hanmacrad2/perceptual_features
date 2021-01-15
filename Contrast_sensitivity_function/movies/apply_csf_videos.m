%Apply csf function


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data - get movies 
dirData = dir('movies');      %# Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories
video_names = {dirData(~dirIndex).name}';  %'# Get a list of the files

subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                             %#   that are not '.' or '..'
for iDir = find(validIndex)                  %# Loop over valid subdirectories
  nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
  video_names = [video_names; getAllFiles(nextDir)];  %# Recursively call getAllFiles
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%Apply Csf

%Params
num_secs = 21;
tot_energy_output = zeros(num_secs, length(video_names)); 

for i = 1:length(video_names) 
    video_name = video_names{i}; 
    video_name
    energy_output = apply_csf(video_name); 
    tot_energy_output(:,i) = energy_output
   
end

%Table
table_energy_output = array2table(tot_energy_output)
table_energy_output.Properties.VariableNames = video_names 

%Save as csv
writetable(table_energy_output, 'total_energy.csv') 
