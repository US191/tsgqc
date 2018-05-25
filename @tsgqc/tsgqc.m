classdef tsgqc < handle
  %TSGQC: Thermosalinograph (TSG) Quality Control software
  %
  % For debug:
  % close all force
  % clear classes
  
  %   %% COPYRIGHT & LICENSE
  %  Copyright 2007 - IRD US191, all rights reserved.
  %
  %  This file is part of TSGQC.
  %
  %    TSGQC is free software; you can redistribute it and/or modify
  %    it under the terms of the GNU General Public License as published by
  %    the Free Software Foundation; either version 2 of the License, or
  %    (at your option) any later version.
  %
  %    TSGQC is distributed in the hope that it will be useful,
  %    but WITHOUT ANY WARRANTY; without even the implied warranty of
  %    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  %    GNU General Public License for more details.
  %
  %    You should have received a copy of the GNU General Public License
  %    along with Datagui; if not, write to the Free Software
  %    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  
  properties (Access = public)
    VERSION = '1.9.0.4 alpha'
    DATE    = '05/23/2018'
    nc
    qc         % struct for quality code (QC)
    activeQc   % struct to save active QC
    inputFile
    outputFile
    preference % preference class load from mat file
    path
    configFile
    debug = false
    help
    plot
    map
  end
  
  % public handle UI object
  properties (Access = public)
    hdlMainFig
    hdlMapToggletool
    hdlInfoFileText
    % left panel
    hdlParameter
  end
  
  
  properties (Access = private)
    % menu
    hdlFileMenu
    hdlOpenMenu
    hdlSaveMenu
    hdlExportMenu
    hdlExportTsg
    hdlExportSample
    hdlQuitMenu
    hdlPreferencesMenu
    % display panel (up)
    hdlInfoPanel
    hdlInfoDateText
    hdlInfoSSPSText
    hdlInfoSSJTText
    hdlInfoSSTPText
    hdlInfoLatText
    hdlInfoLongText
    hdlToolbar
    hdlOpenPushtool
    hdlSavePushtool
    hdlPrintFigPushtool
    hdlZoomInToggletool
    hdlZoomOutToggletool
    hdlPanToggletool
    hdlQCToggletool
    hdlTimelimitToggletool
    hdlGoogleEarthPushtool
    hdlClimToggletool
    hdlCalToggletool
    hdlInterpToggletool
    hdlBottleToggletool
    hdlHeaderPushtool
    hdlReportPushtool
    % left panel
    hdlLeftPanel
    hdlParameterText
    % QC panel and contextual menu
    hdlQCPanel
    hdlQC
    hdlQcContextmenu
    
    % more handle
    hdlZoom
    hdlPan
    
    % handle event
    hdlDataAvailable
    hdlZoomOn
    hdlZoomOff
    hdlPosition
    
    % index of selected QC
    rbboxInd
  end
  
  events
    dataAvailable
    dataAvailableForMap
    fileclose
    axesVisible
    zoomOn
    zoomOff
    position
    positionOnMap
  end
  
  methods
    
    % constructor
    % -----------
    function obj = tsgqc(varargin)
      if length(varargin) == 1
        obj.inputFile = varargin{1};
      end
      propArgin = varargin(1:end);
      while length(propArgin) >= 2
        property = propArgin{1};
        value    = propArgin{2};
        propArgin = propArgin(3:end);
        switch lower(property)
          case {'inputfile', 'input'}
            obj.inputFile = value;
          case {'outputfile', 'output'}
            obj.outputFile = value;
          case 'debug'
            obj.debug = value;
          case 'help'
            obj.help = value;
          otherwise
            error('Unknow property: "%s"', property);
        end
      end
      
      % code to run in MATLAB R2014b and earlier here
      if verLessThan('matlab','9.1')
        errordlg({'TSGQC need a Matlab version R2016b or higher. !!!', ...
          'Please, install an up2date Matlab version'}, 'Error TSGQC');
        return;
      end
      
      % if TSGQC figure exist and still running, don't create a new instance
      if ~isempty(findobj('Tag', 'TAG_TSG-QC_GUI_V2'))
        % display error dialog box and quit
        errordlg({'An instance of TSGQC is still running !!!', ...
          'Open it from you task bar'}, 'Warning TSGQC');
        return;
      end
      
      % display user interface
      obj.path = mfilename('fullpath');
      obj.configFile = [prefdir, filesep, mfilename, '-v2.mat'];
      
      % load config preference class from mat file
      obj.loadConfig;
      
      % create and then hide the GUI as it is being constructed.
      handleVisibility = 'on';
      
      % screen limits for the GUI
      r = groot;
      r.Units = 'normalized';
      guiLimits = r.ScreenSize;
      guiLimits(1) = guiLimits(1) + 0.01;
      guiLimits(2) = guiLimits(2) + 0.05;
      guiLimits(3) = guiLimits(3) - 0.02;
      guiLimits(4) = guiLimits(4) - 0.15;
      
      % define main figure
      obj.hdlMainFig = figure(...
        'Name', strcat('TSG Validation - v', obj.preference.version), ...
        'NumberTitle', 'off', ...
        'Resize', 'on', ...
        'Menubar', 'none', ...
        'Toolbar', 'none', ...
        'UserData', 'ButtonMotionOff', ...
        'HandleVisibility', handleVisibility,...
        'Visible','on',...
        'Tag','TAG_TSG-QC_GUI_V2',...
        'Units', 'normalized',...
        'Position',guiLimits, ...
        'Color', get( 0, 'DefaultUIControlBackgroundColor' ),...
        'KeyPressFcn',  {@obj.keyPressFcnCallback},...
        'KeyReleaseFcn',  {@(src,evt) keyReleaseFcnCallback(obj,src,evt)},...
        'CloseRequestFcn', {@(src,evt) delete(obj)});
      
      % add Quality property to obj.qc 
      % TODOS: netcdf instance add Quality property, dynaload include this prop
      % this should be moving or not use in the future
      obj.loadQuality;
      
      % call the User Interface
      obj.setMenuUI(handleVisibility);
      obj.setDisplayUI;
      obj.setToolBarUI;
      obj.setLeftUI;
      obj.setQcUI;
      
      % create an instance off classes plot and map with events
      obj.plot = tsgqc.plot(obj);
      obj.map = tsgqc.map(obj);
      
      % add listeners
      obj.hdlDataAvailable = addlistener(obj,'dataAvailable',@obj.dataAvailableEvent);
      obj.hdlZoomOn = addlistener(obj,'zoomOn',@obj.zoomOnEvent);
      obj.hdlZoomOff = addlistener(obj,'zoomOff',@obj.zoomOffEvent);
      obj.hdlPosition = addlistener(obj,'positionOnMap',@obj.positionOnMapEvent);
      
      % batch mode
      if ~isempty(obj.inputFile)
        obj.readFile;
      end
      
    end
    
    % destructor
    % ----------
    function delete(obj)
      % method save_config
      saveConfig(obj);
      if ~isempty(obj.map.hdlMapFig)
        close(obj.map.hdlMapFig);
      end
      closereq;
    end
    
    % display overloaded method
    % -------------------------
%     function disp(obj)
%       if obj.debug
%         % disp not implemented
%       end
%     end
    
  end % end of public methods
  
  methods(Static)
    
    function cdata = readIcon(filename)
      thePath = fileparts(which(mfilename));
      data = load(strcat(thePath,filesep,'../icons',filesep,filename));
      cdata = data.cdata;
    end
    
  end % end of static methods
end

