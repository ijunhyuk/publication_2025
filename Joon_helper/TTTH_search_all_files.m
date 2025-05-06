function filelist_st = TTTH_search_all_files(dirName, check_sub_dir, str_pattern)
% Example: file_list = TTTH_search_all_files('D:\root\sub_root', 0, 'JL_su_*.mat');

if contains(str_pattern,'*')
    dirData = dir([dirName '\' str_pattern]);      %# Get the data for the current directory
else
    dirData = dir([dirName '\*' str_pattern '*']);      %# Get the data for the current directory
end
dirIndex = [dirData.isdir];  %# Find the index for directories
filelist_st = {dirData(~dirIndex).name}';  %'# Get a list of the files
% 소팅기능 추가
[~,stringLength] = sort(cellfun(@length,filelist_st),'ascend');
filelist_st = filelist_st(stringLength);

if ~isempty(filelist_st)
    filelist_st = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
        filelist_st,'UniformOutput',false);
    %     matchstart = regexp(filelist_st, ['\w*\.' str_pattern '$']);
    %     filelist_st = filelist_st(~cellfun(@isempty, matchstart));
end
if check_sub_dir
    dirData2 = dir(dirName);      %# Get the data for the current directory
    dirIndex2 = [dirData2.isdir];  %# Find the index for directories
    subDirs = {dirData2(dirIndex2).name};  %# Get a list of the subdirectories
    validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
    %#   that are not '.' or '..'
    for iDir = find(validIndex)                  %# Loop over valid subdirectories
        nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
        filelist_st = [filelist_st; TTTH_search_all_files(nextDir, check_sub_dir, str_pattern)];  %# Recursively call getAllFiles
    end
end

end
