function fileList = TTT_d2_2_ver1_getAllFiles(dirName, check_sub_dir, extension)
% Example: filelistCSV = getAllFiles(somePath,'\d+_\d+_\d+\.csv');
 
  dirData = dir(dirName);      %# Get the data for the current directory   
  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  % 소팅기능 추가
    [~,stringLength] = sort(cellfun(@length,fileList),'ascend');
    fileList = fileList(stringLength);  
  
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
    matchstart = regexp(fileList, ['\w*\.' extension '$']);
    fileList = fileList(~cellfun(@isempty, matchstart));
  end
  if check_sub_dir
      subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
      validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                                   %#   that are not '.' or '..'
      for iDir = find(validIndex)                  %# Loop over valid subdirectories
        nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
        fileList = [fileList; TTT_d2_2_ver1_getAllFiles(nextDir, check_sub_dir, extension)];  %# Recursively call getAllFiles
      end
  end
 
end
