classdef map < handle
  %TSGQC.MAP Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    parent
    hdlMapFig
    hdlMapAxes
    hdlToolbar
    hdlZoomInToggletool
    hdlZoomOutToggletool
    hdlDataAvailable
  end
  
  methods
    
    % tsgqc.map constructor; take tsgqc parent object as parameter
    % ------------------------------------------------------------
    function obj = map(parent)
      obj.parent = parent;
      obj.setUI;
      obj.setToolBarUI
      
      % add listener from tsgqc when data are available
      obj.hdlDataAvailable = addlistener(parent,'dataAvailable',@obj.dataAvailableEvent);
      
    end
    
    % build map User Interface
    % ------------------------
    function setUI(obj)
      
      % The map will be plot  a new figure
      obj.hdlMapFig = figure(...
        'BackingStore','off',...
        'Name', 'TSG SHIP TRACK', ...
        'NumberTitle', 'off', ...
        'Resize', 'on', ...
        'Menubar','figure', ...
        'Toolbar', 'none', ...
        'Tag', 'MAP_FIGURE', ...
        'Visible','off',...
        'WindowStyle', 'normal', ...
        'CloseRequestFcn', {@(src,evt) closeRequestMap(obj,src)},...
        'Units', 'normalized',...
        'Position',[0.17, 0.05, .8, .44],...
        'Color', get(0, 'DefaultUIControlBackgroundColor'));
      
      obj.hdlMapAxes = axes(...     % the axes for plotting ship track map
        'Parent', obj.hdlMapFig, ...
        'Units', 'normalized', ...
        'Visible', 'off', ...
        'Tag', 'TAG_AXES_MAP', ...
        'Color', 'none', ...
        'UserData', 'off', ...
        'HandleVisibility','on', ...
        'Position',[.05, .05, .9, .9]);
    end
    
    % define toolbar
    % should be remove in next version if we share zoom between plot and map
    % ----------------------------------------------------------------------
    function setToolBarUI(obj)
      obj.hdlToolbar       =   uitoolbar(...   % Toolbar for Open and Print buttons
        'Parent',obj.hdlMapFig, ...
        'HandleVisibility','on');
      
      obj.hdlZoomInToggletool = uitoggletool(...   % Open Zoom In (increase) toolbar button
        'Parent',obj.hdlToolbar,...
        'Separator', 'on', ...
        'TooltipString','Zoom In (increase)',...
        'CData', tsgqc.readIcon('zoomplus.mat'),...
        'HandleVisibility','on', ...
        'Tag','PUSHTOOL_ZOOM_IN',...
        'OnCallback',  {@(src,evt) zoomInOn(obj,src)},...
        'OffCallback',  'zoom off');
      
      obj.hdlZoomOutToggletool = uitoggletool(...   % Open Zoom Out (decrease) toolbar button
        'Parent',obj.hdlToolbar,...
        'Separator', 'on', ...
        'TooltipString','Zoom Out (decrease)',...
        'CData', tsgqc.readIcon('zoomminus.mat'),...
        'HandleVisibility','on', ...
        'Tag','PUSHTOOL_ZOOM_OUT',...
        'OnCallback',   {@(src,evt) zoomOutOn(obj,src)},...
        'OffCallback',  'zoom off');
    end
    
  end % end of public methods
  
  methods (Access = private)
    
    % plot coastline map and ship track
    % -----------------------------------
    function plotMap(obj,src)
      
      % Get the Geographic limit of the TSG time series
      dateLim = get(src.axes.hdlPlotAxes(1), 'Xlim');
      ind = find( src.nc.Variables.DAYD.data__ >= dateLim(1) & src.nc.Variables.DAYD.data__ <= dateLim(2));
      
      % m_grid need the use of double instead single
      latx = double(src.nc.Variables.LATX.data__);
      lonx = double(src.nc.Variables.LONX.data__);
      
      if ~isempty( ind )
        
        latMin = min(latx(ind) );
        if latMin < -90
          latMin = -90;
        end
        latMax = max( latx(ind) );
        if latMax > 90
          latMax = 90;
        end
        lonMin = min( lonx(ind) );
        lonMax = max( lonx(ind) );
        
        % Oversize window due to the large frame
        %latRange = (latMax-latMin);
        latMin = max(floor(latMin), -90);
        latMax = min(ceil(latMax), 90);
        
        %lonRange = (lonMax-lonMin);
        lonMin = floor(lonMin);
        lonMax = ceil(lonMax);
        
        lonRange = (lonMax-lonMin);
        if lonRange>=360
          lonMin = -183.6;     %to account for fancy frame
          lonMax = 183.6;
          lonplus = 180;
          lonmod = 360;
        else
          lonplus = 0;
          lonmod = 0;
        end
        
        % Positionning the right axes (set map current axe)
        axes(obj.hdlMapAxes);
        % axes set visible prop to 'on'
        set(obj.hdlMapFig,'visible','off');
        
        % Use of Mercator projection
        m_proj('Mercator','lat',[latMin latMax],'long',[lonMin lonMax]);
        
        % use different resolution
        switch src.preference.map_resolution
          
          case 1
            % Low-resolution coast lines
            m_coast('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
            
          case 2
            % Medium-resolution coast lines
            m_gshhs_l('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
            
          case 3
            % Intermediate-resolution coast lines
            m_gshhs_i('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
            
          case 4
            % High-resolution coast lines
            m_gshhs_h('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
            
          otherwise
            src.preference.map_resolution = 1;
            % Low-resolution coast lines
            m_coast('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
            
        end
        
        % Make a grid on the map with fancy box
        m_grid('box', 'fancy', 'tickdir', 'in', 'TAG', 'TAG_PLOT4_LINE_GRID', ...
          'Fontsize', src.fontSize);
        
        % change with generic value in next version
        para = 'SSPS';
        
        % plot the line with QC color
        qCode = src.nc.Quality;
        QC = src.nc.Variables.([para '_QC']).data__;
        keys = fieldnames(qCode);
        for k = 1: length(keys)
          ind = find( QC == qCode.(keys{k}).code);
          if ~isempty( ind )
            m_line( mod(lonx(ind) + lonplus, lonmod) - lonplus,...
              latx(ind), 'LineStyle', 'none', 'marker','*',...
              'markersize', 2, 'color', qCode.(keys{k}).color);
          end
        end
      end
      
    end % end of loadMap
    
    % for test
    % -------
    function zoomInOn(obj, ~)
      
      % Desactivate some toggle buttons, hZoomOutToggletool changed state
      % must be call before zoom function because the callback set zoom to
      % off
      %     set( hZoomOutToggletool,   'state', 'off' );
      %     set( hQCToggletool,        'state', 'off' );
      %     set( hPanToggletool,       'state', 'off' );
      %     set( hTimelimitToggletool, 'state', 'off' );
      
      % Hide the map. Otherwise it slows down the zooming
      %     set( hMapToggletool,       'state', 'off' );
      
      % returns a zoom mode object for the figure hMainFig handle
      hZoom = zoom(obj.hdlMapFig);
      
      % Turns off the automatic adaptation of date ticks
      tsgqc.zoomAdaptiveDateTicks('on');
      
      % turns interactive zooming to in (increase)
      set(hZoom, 'direction', 'in');
      
      % Disallows a zoom operation on the MAP axes objects
      %      setAllowAxesZoom(hZoom, hPlotAxes(4), false);
      
      % turns on interactive zooming (same effect than zoom on) but prevent
      % side effect on another figure
      set(hZoom, 'enable', 'on');
      
      % Set this callback to listen to when a zoom operation finishes
      % must be call after enable zoom (bug ?)
      % set(hZoom, 'ActionPostCallback', @ZoomPan_PostCallback);
      
    end % end of zoomInOn
    
    % for test
    % --------
    function zoomOutOn(obj, ~)
      hZoom = zoom(obj.hdlMapFig);
      
      % turns interactive zooming out (decrease)
      set(hZoom, 'direction', 'out');
      
      % Disallows a zoom operation on the MAP axes objects
      %     setAllowAxesZoom(hZoom, hPlotAxes(4), false);
      
      % turns on interactive zooming (same effect than zoom on) but prevent
      % side effect on another figure
      set(hZoom, 'enable', 'on');
      
      % Set this callback to listen to when a zoom operation finishes
      % set(hZoom, 'ActionPostCallback', @ZoomPan_PostCallback);
    end
    
    
    % Callback function run when the Quit Map Figure item is selected
    function closeRequestMap(obj, src)
      
      % make the earth map invisible, don't close figure
      set(src, 'Visible', 'off' );
      set(obj.parent.hdlMapToggletool, 'state',  'off' );
      
    end
    
    % wait for dataAvailable event from tsgqc
    % ---------------------------------------
    function dataAvailableEvent(obj,src,~)
      disp(strcat(class(obj),': data available for map'));
      obj.plotMap(src);
    end
  end
  
end

