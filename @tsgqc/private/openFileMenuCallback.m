function openFileMenuCallback(obj, ~)

[theFileName, thePathName, theFilterIndex] = uigetfile(obj.preference.fileExtensions,...
  'Pick a file');
if isequal(theFileName,0) || isequal(thePathName,0)
  disp('User pressed cancel')
else
  theFullFileName = fullfile(thePathName, theFileName);
  disp(['User selected: ', theFullFileName]);
  
  % convert the index to real extention
  theExtention = char(obj.preference.fileExtensions(theFilterIndex));
  
  switch theExtention
    
    % Read discrete data (Water sample, Argo, etc.)
    % ---------------------------------------------
    case {'*.arg', '*.btl', '*.spl'}
      
      % A TSG file must have been uploaded before reading Water sample file
      % --------------------------------------------------------------------
      if isempty( tsg.SSPS )
        
        msgbox('Load a TSG file before a Water sample file', 'Read Bucket');
        return;
      else
        switch theExtention
          case '*.arg'
            % Read Argo file *.arg (G. Reverdin format)
            obj.nc = io.readArgoLocean(theFullFileName );
          case {'*.spl',  '*.btl'}
            % Read sample file *.spl
            obj.nc = io.readAsciiSample(theFullFileName, 'SPL');
            
        end
      end
      
    case '*.ast'                  % read TSG Astrolabe text file *.ast
      obj.nc = io.readTsgDataAstrolabe(theFullFileName);
    case '*.lbv'                  % read TSG labview file *.lbv
      obj.nc = io.readTsgDataLabview(theFullFileName,obj.preference );
    case '*.nc'                  % read TSG netcdf file *.nc
      obj.nc = io.readGosudNetcdf(theFullFileName );
    case 'OS_*.nc'                  % read TSG Oracle text file *.ora
      obj.nc = io.readOceanSitesNetcdf(theFullFileName);
    case '*.sdf'                  % read TSG SDF file *.sdf
      obj.nc = io.readTsgDataSDF(theFullFileName );
    case '*.transmit*'                  % read TSG Nuka transmit file *.transmit*
      obj.nc = io.readTsgDataNuka(theFullFileName);
    case '*.tsgqc'                 % read TSG text file *.tsgqc
      obj.nc = io.readAsciiTsg(theFullFileName);
  end
  
  % the last extension selected move on top in cell array preference.fileExtensions
  obj.preference.fileExtensions = ...
    circshift(obj.preference.fileExtensions, 1 - theFilterIndex);
  
  % send event dataAvailable to papplication
  notify(obj, 'dataAvailable');
end