classdef initialisation
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
   fontSize = 11;
   
end

%% Constants for NetCDF DATA FORMAT TSG
% -------------------------------------

% define netcdf dimensions
% ------------------------
dim.STRING256 = 256;
tsg.dim.STRING16  = 16;  % use for ISO8601 date format
tsg.dim.STRING14  = 14;  % use for oldest date format
tsg.dim.STRING8   = 8;
tsg.dim.STRING4   = 4;
tsg.dim.N1        = 1;
tsg.dim.CALCOEF   = 7;
tsg.dim.LINCOEF   = 2;

% variable tsg.CALCOEF_CONV is char array of (CALCOEF x STRING8)
% --------------------------------------------------------------
tsg.dim.COEF_CONV_SIZE = tsg.dim.STRING8;

% date of reference for julian days, is 1st january 1950
% ------------------------------------------------------
REFERENCE_DATE_TIME    = '19500101000000';

% get actual date with ISO8601
% ----------------------------
date = datestr(now, 'yyyymmddHHMMSS');

% -------------------------------------------------------------------------
%%              Levitus fields for climatology
% -------------------------------------------------------------------------
tsg.levitus.data    = [];
tsg.levitus.type    = 'none';
tsg.levitus.version = 'none';
tsg.levitus.time    = 1;

% -------------------------------------------------------------------------
%%              file fields
% -------------------------------------------------------------------------
tsg.file.pathstr = [];
tsg.file.name    = [];
tsg.file.ext     = [];
tsg.file.versn   = [];
tsg.file.type    = [];

% -------------------------------------------------------------------------
%%              Smooth TSG time serie fields
% -------------------------------------------------------------------------
% tsg.ssps_smooth      = [];
% tsg.ssps_smooth.nval = [];
% tsg.SSTP_smooth      = [];
% tsg.SSTP_smooth.nval = [];

% -------------------------------------------------------------------------
%%              Variable used for the report
% -------------------------------------------------------------------------
tsg.report.tsgfile  = '';  % Name of the TSG file
tsg.report.wsfile   = '';  % Name of the Water sample file
tsg.report.extfile  = '';  % Name of the External sample file
tsg.report.nodate   =  0;  % Records deleted because they have no date
tsg.report.sortdate =  0;  % Records deleted because date is not increasing
tsg.report.badvelocity = 0;  % Records deleted because of bad velocity
% (> 50 knots - test in shipVelocity)

% -------------------------------------------------------------------------
%%              Structure used to merge WS and EXT sample
% need to be intialise (isempty test performed on tsg.SSPS_SPL
% -------------------------------------------------------------------------
% tsg.DAYD_SPL      = [];
% tsg.LATX_SPL      = [];
% tsg.LONX_SPL      = [];
% tsg.SSPS_SPL      = [];
% tsg.SSPS_SPL_QC   = [];
% tsg.SSPS_SPL_TYPE = [];
% tsg.SSTP_SPL      = [];
% tsg.SSTP_SPL_QC   = [];
% tsg.SSTP_SPL_TYPE = [];
% tsg.SSJT_SPL      = [];
% tsg.SSJT_SPL_QC   = [];
% tsg.SSJT_SPL_TYPE = [];
%
% -------------------------------------------------------------------------
%%              Constants for the quality control procedure
% -------------------------------------------------------------------------

% Quality flags reference table, see GOSUD, DATA FORMAT TSG V1.6, table 4
% -----------------------------------------------------------------------
%  Code      Key                  Meaning
%
%  0         NO_CONTROL           No QC was performed
%  1         GOOD                 Good data
%  2         PROBABLY_GOOD        Probably good data
%  3         PROBABLY_BAD         Bad data that are potentially correctable
%  4         BAD                  Bad data
%  5         VALUE_CHANGED        Value changed
%  6         HARBOUR              Data acquired in harbour
%  7         NOT_USED             Not used
%  8         INTERPOLATED_VALUE   Interpolated value
%  9         MISSING_VALUE        Missing value

% Quality definition, we use an instance of dynaload object 
% ---------------------------------------------------------
d = dynaload('tsgqc_netcdf.csv');

% Get hashtable QUALITY from dynaload instance
% --------------------------------------------
tsg.qc.hash = d.QUALITY;

% set default code at startup
% old syntax already works
% ---------------------------
tsg.qc.active.Code   = d.QUALITY.NO_CONTROL.code;
tsg.qc.active.Color  = d.QUALITY.NO_CONTROL.color;

% set empty stack (use for undo/redo)
% -----------------------------------
%tsg.queue = queue;

% -------------------------------------------------------------------------
%%              Constants for the Correction procedure
% -------------------------------------------------------------------------

% Smoothing of tsg time series :
% Salinity, in 1 hour interval, should not depart the average for more
% than SAL_STD_MAX standard deviation
% --------------------------------------------------------------------
tsg.SSJT_STDMAX = 1.0;
tsg.SSTP_STDMAX = 1.0;

% Correction is estimated by computing the median value of X tsg-sample
% differences
% Time window in days used to compute the correction
% ---------------------------------------------------------------------
tsg.cst.COR_TIME_WINDOWS = 10;

% Get attributes & variables list from dynaload instance
% ------------------------------------------------------
nca = keys(d.ATTRIBUTES);
ncv = keys(d.VARIABLES);

% store tsg NetCDF data structure
% -------------------------------

% dimensions
% ----------
tsg.DAYD                  = [];
tsg.DAYD_EXT              = [];

% initialise tsg structure from tsg_nc objects
% --------------------------------------------

% assign empty matrix to all variables
% ------------------------------------
for key = ncv
  tsg.(char(key)) = [];
end

% assign empty string to all globals attributes
% ---------------------------------------------
for key = nca
  tsg.(char(key)) = '';
end

% set some fields
% ---------------
tsg.FORMAT_VERSION        =  GOSUD_FORMAT_VERSION;
tsg.DATE_CREATION         =  date;
tsg.DATE_UPDATE           =  tsg.DATE_CREATION;
tsg.REFERENCE_DATE_TIME   =  REFERENCE_DATE_TIME;
tsg.conventions           =  [];
  end
  
  methods
    function obj = initialisation(inputArg1,inputArg2)
      %UNTITLED2 Construct an instance of this class
      %   Detailed explanation goes here
      obj.Property1 = inputArg1 + inputArg2;
    end
    

  end
end

