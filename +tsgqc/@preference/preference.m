classdef preference
  %UNTITLED Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
     % add tsg.preference to default values
    % -------------------------------------
    version         
    date       
    autoload              = 'off';
    fileExtensions         = ({'*.lbv';'*.nc';'OS_*.nc';'*.arg';'*.ast';'*.btl';...
      '*.sdf';'*.spl'; '*.transmit*'; '*.tsgqc'});
    fontSize = 11
    % Climatology
    climatology_version       = {'WOA01','WOA05','ISAS13'};
    climatology_value         = 2;  % WOA05
    climatology_depth_string  = {'0','10'};
    climatology_depth_value   = 1;
    coeff_type_string     = {'use A-D', 'use G-J'};
    coeff_type_value      = 2;
    % Plot
    map_resolution_string = {'low','medium','intermediate','high'};
    map_resolution        = 2;
    plot_connected_string = {'none', '-', '--', ':', '-.'};
    plot_connected_value  = 1;  % 0, line not connected
    % QC test
    flow_min_string       = {'1'};
    press_min_string      = {'1'};
    ship_speed_min_string = {'1'};
    ssps_min_string       = {'0'};
    ssps_max_string       = {'50'};
    ssjt_min_string       = {'-3'};
    ssjt_max_string       = {'40'};
    sstp_min_string       = {'-3'};
    sstp_max_string       = {'40'};
    
    % according with tsg_netcdf.xls file
    % change version number or delete tsgqc.mat
    % -----------------------------------------
    date_format_variable  = 'yyyymmddHHMMSS';
    date_format_attribute = 'yyyymmddHHMMSS';
    positions_format_string = {'DD°MM.SS', '+-DD.CCCC'};
    positions_format_value = 1;
    
    % use in tsg-average by tsg.cst.TSG_DT_SMOOTH
    % this value in in minute
    % ---------------------------------------------
    dt_smooth             = '60';
    
    % Salinity, in 1 hour interval, should not depart the average for more
    % than SAL_STD_MAX standard deviation
    % -------------------------------------
    ssps_stdmax           = '0.1';
    % Maximum time difference between tsg data and water sample used to
    % compute the difference : 5 minutes.
    % ------------------------------------
    ws_timediff           = '5';
  end
  
  % constructor
  % ------------
  methods
    function obj = preference(theVersion, theDate)
      obj.version = theVersion;
      obj.date = theDate;
 
    end
    
  end
end

