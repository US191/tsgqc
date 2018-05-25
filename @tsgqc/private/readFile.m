function readFile(obj)
%UNTITLED Summary of this function goes here

% use local variable
filename = obj.inputFile;

% Get parts of file name
[~,~,ext] = fileparts(filename);

switch ext
  
  % Read discrete data (Water sample, Argo, etc.)
  case {'.arg', '.btl', '.spl'}
    
    % A TSG file must have been uploaded before reading Water sample file
    if isempty( tsg.SSPS )
      
      msgbox('Load a TSG file before a Water sample file', 'Read Bucket');
      return;
    else
      switch ext
        case '.arg'
          % Read Argo file *.arg (G. Reverdin format)
          obj.nc = io.readArgoLocean(filename );
        case {'.spl',  '.btl'}
          % Read sample file *.spl
          obj.nc = io.readAsciiSample(filename, 'SPL');
          
      end
    end
    
    % read TSG files
  case '.ast'                  % read TSG Astrolabe text file *.ast
    obj.nc = io.readTsgDataAstrolabe(filename);
  case '.lbv'                  % read TSG labview file *.lbv
    obj.nc = io.readTsgDataLabview(filename,obj.preference );
  case '.nc'                  % read TSG netcdf file *.nc
    obj.nc = io.readGosudNetcdf(filename );
  case 'OS_.nc'                  % read TSG Oracle text file *.ora
    obj.nc = io.readOceanSitesNetcdf(filename);
  case '.sdf'                  % read TSG SDF file *.sdf
    obj.nc = io.readTsgDataSDF(filename );
  case '.transmit*'                  % read TSG Nuka transmit file *.transmit*
    obj.nc = io.readTsgDataNuka(filename);
  case '.tsgqc'                 % read TSG text file *.tsgqc
    obj.nc = io.readAsciiTsg(filename);
end

% set popup parameters from list of variables read in file
set(obj.hdlParameter(1), 'string', obj.initParameterChoice(1) );
set(obj.hdlParameter(2), 'string', obj.initParameterChoice(2) );
set(obj.hdlParameter(3), 'string', obj.initParameterChoice(3) );

para1 = get(obj.hdlParameter(1), 'string');
para2 = get(obj.hdlParameter(2), 'string');
para3 = get(obj.hdlParameter(3), 'string');

PARA = {para1{get(obj.hdlParameter(1), 'value')}, ...
  para2{get(obj.hdlParameter(2), 'value')},...
  para3{get(obj.hdlParameter(3), 'value')}};

evtData = tsgqc.parameterChoiceEventData(PARA);

% send event dataAvailable to application
%notify(obj, 'dataAvailable', evtData);
obj.dataAvailableEvent;
obj.plot.plotData(evtData);
obj.map.plotMap;
%notify(obj, 'dataAvailableForMap');
