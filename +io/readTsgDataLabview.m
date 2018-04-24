function nc = readTsgDataLabview(filename, prefs)



% readTsgDataLabview( hMainFig, filename )
% This function read TSG files from acquisition software LabView
%
% Usage:
% [error] = readTsgDataLabview( hMainFig, filename )
%
% Input:
% hMainFig ........... Handle to the main user interface
% filename ........... Data filename
%
% Output:
% error .............. 1 : OK
%                      0 : Selection canceled
%                     -1 : an error occured
%
% Description of columns from Labview files header:
% Date
%     Pc Date  - RMC_Date - ZDA_Date
% Time
%     Pc Time - RMC_Time - ZDA_Time - GLL_Time
% Position
%     RMC_Latmn - RMC_Lonmn - RMC_Latdec - RMC_Londec -
%     GGA_Latdec - GGA_Londec - GLL_Latdec - GLL_Londec
% Measurement
%     SBE21_Temp1 - SBE21_Sal - SBE21_StdDev - SBE21_Cond - SBE21_Raw
% Heading speed and direction
%     RMC_Sog - RMC_Cog - 3026L_Cog - 3026L_Sog
% Miscellaneous
%     RMC_Status - GGA_Hog - VTG True Track - T - Magn Track - M -
%     Ground spd- N - Ground Spd - K - dd - tete - ttt
%     SBE21_AD1,SBE21_AD2
%
% Focntions appelees : choixparametres, decodeficlabview, readTsgIniLabview
%

% $Id: readTsgDataLabview.m 800 2017-01-31 13:15:49Z jgrelet $

% initialize netCDF instance from template
nc = tsgqc.netcdf('+tsgqc\@dynaload\tsgqc_netcdf.csv');

% display read file info on console
fprintf('\nREAD_LABVIEW_FILE\n'); tic;

% each column separated by DELIMITER comma
DELIMITER = ',';

% open file
fid = fopen( filename, 'r');

% test if exist
if fid ~= -1
  
  % display more info about read file on console
  fprintf('...reading %s : ', filename);
  
  % Choix des parametres qui seront utilises par TSG-QC
  % ColNo : structure des numeros de colonnes a conserver
  [choix, ColNo, paraName, DELIMITER] = choixparametres( fid );
  
  if strcmp( choix, 'ok' )
    
    % Lecture et decodage du fichier TSG LabView. En sortie
    % ------------------------------------------
    [theDate, theTime, lat, lon, sst, sss, sssStd, cond, TsgRaw, sog, cog, flow] =...
      decodeficlabview( fid, DELIMITER, ColNo, paraName );
    
    % Nombre de lignes du fichier
    % ---------------------------
    nbrecords = length(sst);
    
    % decode tsg raw data
    % -------------------
    % The SBE 21 outputs data in raw, hexadecimal form as described below.
    % SBE 21 Format (F1) - ttttccccrrrrrruuuvvvwwwxxx (use this format if you
    % will be using SEASAVE to acquire real-time data and/or SBE Data
    % Processing to process the data)
    % where
    % tttt = primary temperature
    % cccc = conductivity
    % rrrrrr = remote temperature (from SBE 38 or SBE 3 remote sensor)
    % uuu, vvv, www, xxx = voltage outputs 0, 1, 2, and 3 respectively
    % # = attention character
    % nnnn = lineal sample count (0, 1, 2, etc.)
    %
    % Calculation of the parameter from the data is described below (use the decimal
    % equivalent of the hex data in the equations).
    %
    % 1. Temperature
    % temperature frequency (Hz) = ( tttt / 19 ) + 2100
    % 2. Conductivity
    % conductivity frequency (Hz) = square root [ ( cccc * 2100 ) + 6250000 ]
    % 3. SBE 3 secondary temperature (if SBE3=Y)
    % SBE 3 temperature frequency (Hz) = rrrrrr / 256
    % 4. SBE 38 secondary temperature (if SBE38=Y)
    % SBE 38 temperature psuedo frequency (Hz) = rrrrrr / 256
    % 5. External voltage 0 (if 1 or more external voltages defined with SVx)
    % external voltage 0 (volts) = uuu / 819
    % 6. External voltage 1 (if 2 or more external voltages defined with SVx)
    % external voltage 1 (volts) = vvv / 819
    % 7. External voltage 2 (if 3 or more external voltages defined with SVx)
    % external voltage 2 (volts) = www / 819
    % 8. External voltage 3 (if 4 external voltages defined with SVx)
    % external voltage 3 (volts) = xxx / 819
    
    % see http://www.seabird.com/pdf_documents/manuals/21_022.pdf
    % section 4: data output format
    
    % initialize and set <data>_FREQ to NaN
    % -------------------------------------
    ssjt_freq = nan(nbrecords,1);
    cndc_freq = nan(nbrecords,1);
    
    % loop on all TsgRaw data
    % -----------------------
    for i=1:nbrecords
      
      % remove leading and trailing white space when string contain NaN
      % ---------------------------------------------------------------
      if ~strcmp(strtrim(TsgRaw(i,:)), 'NaN')
        
        % get frenquencies from string
        % ----------------------------
        [freq, count, errmsg]  = sscanf(TsgRaw(i,:), '%4x%4x%*s');
        
        % compute frenquencies
        % --------------------
        if isempty( errmsg )
          if ~isempty( freq )
            if size(freq,1) == 2
              ssjt_freq(i) = freq(1)/19 + 2100;
              cndc_freq(i) =  sqrt(freq(2)*2100 + 6250000);
            end
          end
        else
          sprintf( '\n Function readTsgDataLabview' );
          sprintf( 'Problem reading frequency %s \n', errmsg );
          sprintf( 'Records # %d\n', i );
        end
      end
    end
    
    % Indices where dates and hours are correct (no NaN)
    noNaN = find( strcmp( theDate, 'NaN') == 0 & strcmp( theTime, 'NaN') == 0 );
    
    if ~isempty( noNaN )
      
      % Every variable are put in a structure
      blanc = char( blanks(1) * ones(length(noNaN),1));
      
      nc.Variables.DAYD.data__ = datenum( [char(theDate(noNaN)) blanc char(theTime(noNaN))],...
        'dd/mm/yyyy HH:MM:SS');
      
      % Save original data. If date or time are incorrect data are deleted
      nc.Variables.DATE.data__       = deblank( datestr(nc.Variables.DAYD.data__,...
        prefs.date_format_variable) );
      nc.Variables.LATX.data__       = lat(noNaN);
      nc.Variables.LONX.data__       = lon(noNaN);
      nc.Variables.SSJT.data__       = sst(noNaN);
      nc.Variables.SSPS.data__       = sss(noNaN);
      nc.Variables.SSPS_STD.data__   = sssStd(noNaN);
      
      if isempty( find(isnan(nc.Variables.LATX.data__) == 0) )
        warndlg( '...No latitude ', 'LabView error dialog');
        error = -1;
        return;
      end
      if isempty( find(isnan(nc.Variables.LONX.data__) == 0) )
        warndlg( '...No longitude', 'LabView error dialog');
        error = -1;
        return;
      end
      
      if ~isempty(cond) && ~isempty( find(isnan(cond) == 0))
        nc.Variables.CNDC.data__     = cond(noNaN);
      end
      if ~isempty(sog) && ~isempty( find( isnan(sog) == 0))
        nc.Variables.SPDC.data__     = sog(noNaN);
      end
      if ~isempty(flow) && ~isempty( find( isnan(flow) == 0))
        nc.Variables.FLOW.data__     = flow(noNaN);
      end
      
      if ~isempty( ssjt_freq ) && ~isempty( find( isnan(ssjt_freq) == 0))
        nc.Variables.SSJT_FREQ.data__  = ssjt_freq(noNaN);
      end
      if ~isempty( cndc_freq ) && ~isempty( find( isnan(cndc_freq) == 0))
        nc.Variables.CNDC_FREQ.data__  = cndc_freq(noNaN);
      end
      
      % Set <PARAM>_QC with NOCONTROL code
      nc.Variables.SSPS_QC.data__ = util.castByteQC( nc.Quality.NO_CONTROL.code, noNaN );
      nc.Variables.SSJT_QC.data__ = util.castByteQC( nc.Quality.NO_CONTROL.code, noNaN );
      nc.Variables.POSITION_QC.data__ = util.castByteQC( nc.Quality.NO_CONTROL.code, noNaN );
      
%       % populate tsg.file structure
%       % ---------------------------
%       [tsg.file.pathstr, tsg.file.name, tsg.file.ext] = ...
%         fileparts(filename);
%       tsg.file.type = 'LABVIEW';
      
      % display information on command window
      % --------------------------------------
      fprintf(' %d lines', nbrecords);
      
%       % check if .ini file exist in data
%       % --------------------------------
%       file_ini = fullfile(tsg.file.pathstr, strcat(tsg.file.name, '.ini'));
%       
%       % check if filename exist and should be open in read mode
%       % -------------------------------------------------------
%       file_ini_id = fopen(file_ini, 'r');
%       
%       if (file_ini_id ~= -1)
%         
%         % display information on command window
%         % --------------------------------------
%         fprintf('\n...reading %s : \n', file_ini);
%         
%         % Save the data in the application GUI
%         % ------------------------------------
%         setappdata( hMainFig, 'tsg_data', tsg );
%         
%         % read .ini file
%         % --------------
%         readTsgIniLabview(hMainFig, file_ini_id);
%         
%         % Get the tsg struct from the application GUI
%         % -------------------------------------------
%         tsg = getappdata( hMainFig, 'tsg_data');
%         
%       end
%       
      
%       % Keep somme information for the log file
%       % ---------------------------------------
%       tsg.report.tsgfile  = filename;
%       tsg.report.nodate   = nbrecords - length(noNaN);
%       
%       
%       % Perform somme automatic tests
%       % -----------------------------
%       automaticQC( hMainFig )
%       
      % Close the file
      % --------------
      fclose( fid );
      
      % Display time to read file on console
      % ------------------------------------
      t = toc; fprintf('...done (%6.2f sec).\n\n',t);
      
      error = 1;
    else
      
      % Gestion d'erreur All Date and Time at NaN
      % -----------------------------------------
      msg_error = {['TSG_LABVIEW file_read : ' filename];...
        ' '; '...no valid Date and Time'};
      warndlg( msg_error, 'LabView error dialog');
      nc = [];
      return;
      
    end
  else
    
    % Parameter selection has been canceled in lbvParameterChoice
    % -----------------------------------------------------------
    error = -1;
    
  end  % fin de boucle if strcmp(choix,'ok')
  
else
  
  % Gestion d'erreur ouverture de fichier
  % -------------------------------------
  msg_error = ['TSG_LABVIEW file_lecture : Open file error : ' filename];
  warndlg( msg_error, 'LabView error dialog');
  sprintf('...cannot locate %s\n', filename);
  error = -1;
  return;
  
end

