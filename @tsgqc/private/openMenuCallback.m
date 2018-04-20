function openMenuCallback(obj, ~)

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
            obj.nc = tsgqc.readArgoLocean(theFullFileName );
          case {'*.spl',  '*.btl'}
            % Read sample file *.spl
            obj.nc = tsgqc.readAsciiSample(theFullFileName, 'SPL');
            
        end
      end
      
    case '*.ast'                  % read TSG Astrolabe text file *.ast
      obj.nc = tsgqc.readTsgDataAstrolabe(theFullFileName);
    case '*.lbv'                  % read TSG labview file *.lbv
      obj.nc = tsgqc.readTsgDataLabview(theFullFileName );
    case '*.nc'                  % read TSG netcdf file *.nc
      obj.nc = tsgqc.netcdf(theFullFileName );
    case '*.ora'                  % read TSG Oracle text file *.ora
      obj.nc = tsgqc.readTsgDataOracle(theFullFileName);
    case '*.sdf'                  % read TSG SDF file *.sdf
      obj.nc = tsgqc.readTsgDataSDF(theFullFileName );
    case '*.transmit*'                  % read TSG Nuka transmit file *.transmit*
      obj.nc = readTsgDataNuka(theFullFileName);
    case '*.tsgqc'                 % read TSG text file *.tsgqc
      obj.nc = tsgqc.readAsciiTsg(theFullFileName);
  end
  % the last extension chosen become first in cell array preference.fileExtensions
  obj.preference.fileExtensions = ...
    circshift(obj.preference.fileExtensions, 1 - theFilterIndex);
  
  notify(obj, 'dataAvailable');
end

end % end of openMenu