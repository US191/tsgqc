function openFileMenuCallback(obj, ~)

[theFileName, thePathName, theFilterIndex] = uigetfile(obj.preference.fileExtensions,...
  'Pick a file');
if isequal(theFileName,0) || isequal(thePathName,0)
  disp('User press cancel')
else
  obj.inputFile = fullfile(thePathName, theFileName);
  fprintf(1, '\nUser select file: %s\n', obj.inputFile);
  
  % read file (all types)
  obj.readFile;
  
  % the last extension selected move on top in cell array preference.fileExtensions
  obj.preference.fileExtensions = ...
    circshift(obj.preference.fileExtensions, 1 - theFilterIndex);
  
end