function openFileMenuCallback(obj, ~)

[theFileName, thePathName, theFilterIndex] = uigetfile(obj.preference.fileExtensions,...
  'Pick a file');
if isequal(theFileName,0) || isequal(thePathName,0)
  disp('User pressed cancel')
else
  obj.inputFile = fullfile(thePathName, theFileName);
  disp(['User selected: ', obj.inputFile]);
  
  % read file (all types)
  obj.readFile;
  
  % the last extension selected move on top in cell array preference.fileExtensions
  obj.preference.fileExtensions = ...
    circshift(obj.preference.fileExtensions, 1 - theFilterIndex);
  
end