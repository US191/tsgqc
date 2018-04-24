function  readTsgIniLabview(hMainFig, fid)
% readTsgIniLabview(hMainFig, filename)
% read TSG labview acquisition .ini file
%
% Input
% -----
% hMainFig ............ Handle to the main user interface
% fid      ............ file descriptor on the .ini file opened
%
% Output
% ------
% none     ............. tsg struct is saved with setappdata
%
% $Id: readTsgIniLabview.m 800 2017-01-31 13:15:49Z jgrelet $

% Get the tsg struct from the application GUI
% -------------------------------------------
tsg = getappdata( hMainFig, 'tsg_data');

% Get an instance of dynaload objetc from file 'tsgqc_netcdf.csv'
% -----------------------------------------------------------------
nc      = dynaload('tsgqc_netcdf.csv');

% Get attributes & variables list from dynaload instance
% ------------------------------------------------------
nca_keys = keys(nc.ATTRIBUTES);
ncv_keys = keys(nc.VARIABLES);

% initialize contexte, eg [GLOBAL] in configuration file
% ------------------------------------------------------
context = [];

% read first line
% -------------
inputText = textscan(fid, '%s', 1, 'delimiter', '\n');

% test the end-of-file
% --------------------
while ~feof(fid)
  
  % use string instead cell
  % -----------------------
  str = inputText{1}{1};
  
  % check if line define a context
  % ------------------------------
  match = regexp(str , '^\[(.+)\]$', 'tokens');
  if ~isempty(match)
    context = match{1}{1};
  end
  
  % build tsg struct from global attributes
  % check if we are is the right paragraph context
  % ----------------------------------------------
  if strcmp(context, 'GLOBAL') || strcmp(context, 'GENERAL') || ...
      strcmp(context, tsg.TYPE_TSG) || strcmp(context, tsg.TYPE_TINT)
    
    % Iterate from each element from global attributes (nca object)
    % --------------------------------------------------------------
    for ii = nca_keys
      
      % get key, use char because i is cell
      % -----------------------------------
      clef = char(ii);
      
      % construct regex with pair cle=value
      % and extract value
      % use quantifier none greedy (.*?)
      % remove double quote from expression : ["]*
      % ---------------------------------------------------
      regex = strcat('^\s*', clef, '\s*=\s*["]*(.+?)["]*$');
      match = regexp( str, regex, 'tokens');
      
      
      % build tsg struct
      % ----------------
      if ~isempty(match)
        tsg.(clef) = match{1}{1};
        
        % for debbuging only
        % ------------------
        fprintf('%s -> %s\n', clef, tsg.(clef));
        continue
      end
      
    end
    
  end
  
  % get TSG installation date and S/N
  % ---------------------------------
  if strcmp(context, tsg.TYPE_TSG) || strcmp(context, tsg.TYPE_TINT) || ...
      strcmp(context, 'SENSORS')
    
    % Iterate from each element from object nca attributes
    % ----------------------------------------------------
    for ii = nca_keys
      
      % get key, use char because i is cell
      % -----------------------------------
      clef = char(ii);
      
      % construct regex with pair cle=value
      % and extract value
      % use quantifier none greedy (.*?)
      % remove double quote from expression : ["]*
      % ---------------------------------------------------
      if ~isempty(strfind(clef, 'DATE_'))
        regex = strcat('^\s*(', tsg.TYPE_TSG, '.|', tsg.TYPE_TINT, ...
          '.)?(', clef, ')?\s*=\s*["]*(.*?)["]*$');
        match = regexp( str, regex, 'tokens');
      elseif ~isempty(strfind(clef, 'NUMBER_'))
        regex = strcat('^\s*(', tsg.TYPE_TSG, '.|', tsg.TYPE_TINT, ...
          '.)?', clef, '\s*=\s*["]*(.*?)["]*$');
        match = regexp( str, regex, 'tokens');
      else
        match = [];
      end
      
      % build tsg struct
      % ----------------
      if ~isempty(match)
        
        switch size(match{1},2)
          
          % in case of calibration coefficients, have key/value pair
          % --------------------------------------------------------
          case 3
            
            % get key
            % --------
            k = match{1}{2};
            
            % get value
            % ---------
            v = match{1}{3};
            
            % convert date in yyyymmddHHMMSS convention
            % in next version use ISO8660 format yyyyddmmTHHMMSSZ
            % -------------------------------------------------------------
            if ~isempty(strfind(k, 'DATE_'))
              v = datestr(datenum(v, 'dd/mm/yyyy'), 'yyyymmddHHMMSS');
            else
              
              % in case where comma is decimal separator, replace it
              % with by dot
              % ----------------------------------------------------
              v = str2double(regexprep(v, ',', '.'));
            end
            
            % add value to coefficients array
            % -------------------------------
            tsg.(clef) = v;
            
            % for debbuging only
            % ------------------
            fprintf('%s => %s\n', clef, tsg.(clef));
            
          case 2
            
            % add value to variable array
            % in case where comma is decimal separator, replace it
            % with by dot
            % ----------------------------------------------------
            tsg.(clef) = str2double(regexprep(match{1}{2}, ',', '.'));
            
            % for debbuging only
            % ------------------
            fprintf('%s => %f\n', clef, tsg.(clef));
            
        end
        
        % quit for loop
        % -------------
        continue
        
      end
      
    end % end of match
    
  end
  
  
  % check if we are is the right paragraph context
  % since SODA V1.30, all sensors information are in SENSORS group
  % --------------------------------------------------------------
  if strcmp(context, tsg.TYPE_TSG) || strcmp(context, tsg.TYPE_TINT) || ...
      strcmp(context, 'SENSORS')
    
    % Iterate from each element from object nca and additional variables
    % ------------------------------------------------------------------
    for ii = ncv_keys
      
      % get key, use char because i is cell
      % -----------------------------------
      clef = char(ii);
      
      % construct regex with pair cle=value and extract value
      % simple variables are : SSPS_DEPH=8.00000000E+0
      % coeff variables are  : SSJT_CALCOEF_G=4,23058298E-3 or
      %                        CNDC_LINCOEF_OFFSET=0.00000000E+0
      % SODA 1.30
      % [SENSORS]
      % SBE21.DATE_TSG = "14/06/2010"
      % SBE21.NUMBER_TSG = "2653"
      % SBE38.DATE_TINT = "01/10/2007"
      % SBE38.NUMBER_TINT = "2552"
      % SBE38.SSTP_CALCOEF_G = "4.1100000000E-3"
      % ------------------------------------
      if ~isempty(strfind(clef, 'COEF'))
        regex = strcat('^\s*(', tsg.TYPE_TSG, '.|', tsg.TYPE_TINT, ...
          '.)?', clef, '_(\w+)?\s*=\s*["]*(.*?)["]*$');
        match = regexp( str, regex, 'tokens');
      elseif ~isempty(strfind(clef, 'DEPH'))
        regex = strcat('^\s*(', tsg.TYPE_TSG, '.|', tsg.TYPE_TINT, ...
          '.)?', clef, '\s*=\s*["]*(.*?)["]*$');
        match = regexp( str, regex, 'tokens');
      else
        match = [];
      end
      
      % build tsg struct
      % ----------------
      if ~isempty(match)
        
        % variable SSPS_DEPH return one match, SSJT_CALCOEF_G two
        % -------------------------------------------------------
        switch size(match{1},2)
          
          % in case of calibration coefficients, have key/value pair
          % --------------------------------------------------------
          case 3
            
            % get key
            % --------
            k = match{1}{2};
            
            % get value
            % ---------
            v = match{1}{3};
            
            % convert date in julian day when key is 'DATE', else to double
            % -------------------------------------------------------------
            if strcmpi(k, 'DATE') 
              v = datenumToJulian(datenum(v, 'dd/mm/yyyy'));              
            else
              
              % in case where comma is decimal separator, replace it
              % with by dot
              % ----------------------------------------------------
              v = str2double(regexprep(v, ',', '.'));
            end
            
            % add key to _CONV array, with length of STRING8
            % ----------------------------------------------
            tsg.([clef '_CONV']) = [tsg.([clef '_CONV']); padding(k, 8)];
            
            % add value to coefficients array
            % -------------------------------
            tsg.(clef) = [tsg.(clef); v];
            
            % for debbuging only
            % ------------------
            fprintf('%s: %s -> %f\n', clef, k, v);
            
          case 2
            
            % add value to variable array
            % in case where comma is decimal separator, replace it
            % with by dot
            % ----------------------------------------------------
            tsg.(clef) = str2double(regexprep(match{1}{2}, ',', '.'));
            
            % for debbuging only
            % ------------------
            fprintf('%s: %f\n', clef, tsg.(clef));
        end
        
        % quit for loop
        % -------------
        continue
        
      end % end of match
      
    end % end ncv_keys
    
  end % of of test in context
  
  % read next line
  % --------------
  inputText = textscan(fid, '%s', 1, 'delimiter', '\n');
  
end  % end of while loop

% Save the data in the application GUI
% ------------------------------------
setappdata( hMainFig, 'tsg_data', tsg );

% close .ini file
% ---------------
fclose(fid);



