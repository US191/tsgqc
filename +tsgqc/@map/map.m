classdef map < handle
  %TSGQC.MAP Summary of this class goes here
  %   Detailed explanation goes here
  %
  
  properties
    parent
    dayd
    latx
    lonx
    latMin
    latMax
    lonMin
    lonMax
    lonplus
    lonmod
    hdlMapFig
    hdlMapAxes
    hdlToolbar
    hdlZoomInToggletool
    hdlZoomOutToggletool
    hdlDataAvailable
    hdlPositionOnMap
    hdlZoomPost
  end
  
  events
    position
    positionOnMap
    zoomPost
  end
  
  methods
    
    % tsgqc.map constructor; take tsgqc parent object as parameter
    % ------------------------------------------------------------
    function obj = map(parent)
      obj.parent = parent;
      obj.setUI;
      %obj.setToolBarUI
      
      % add listener from tsgqc when data are available
      obj.hdlDataAvailable = addlistener(parent,'dataAvailableForMap',@obj.dataAvailableEvent);
      obj.hdlPositionOnMap = addlistener(obj,'position',@obj.positionOnMapEvent);
      obj.hdlZoomPost = addlistener(obj,'zoomPost',@obj.zoomPostEvent);

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
        'Menubar','none', ...
        'Toolbar', 'none', ...
        'Tag', 'MAP_FIGURE', ...
        'Visible','off',...
        'WindowStyle', 'normal', ...
        'CloseRequestFcn', {@(src,evt) closeRequestMap(obj,src)},...
        'Units', 'normalized',...
        'Position',[0.17, 0.05, .8, .44],...
        'WindowButtonMotionFcn', {@(src,evt) mouseMotion(obj,src)}, ...
        'Color', get(0, 'DefaultUIControlBackgroundColor'));
      
      obj.hdlMapAxes = axes(...     % the axes for plotting ship track map
        'Parent', obj.hdlMapFig, ...
        'Units', 'normalized', ...
        'Visible', 'off', ...
        'Tag', 'TAG_AXES_MAP', ...
        'Color', 'none', ...
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
      
      % initialize map properties
      % m_grid need the use of double instead single
      obj.dayd = double(src.nc.Variables.DAYD.data__);
      obj.latx = double(src.nc.Variables.LATX.data__);
      obj.lonx = double(src.nc.Variables.LONX.data__);
      
      % Get the Geographic limit of the TSG time series
      dateLim = get(src.axes.hdlPlotAxes(1), 'Xlim');
      ind = find( obj.dayd >= dateLim(1) & obj.dayd <= dateLim(2));
      % BUG: empty indice ....
      if ~isempty( ind )
        
        obj.latMin = min(obj.latx(ind) );
        if obj.latMin < -90
          obj.latMin = -90;
        end
        obj.latMax = max( obj.latx(ind) );
        if obj.latMax > 90
          obj.latMax = 90;
        end
        obj.lonMin = min( obj.lonx(ind) );
        obj.lonMax = max( obj.lonx(ind) );
        
        % Oversize window due to the large frame
        %latRange = (latMax-latMin);
        obj.latMin = max(floor(obj.latMin), -90);
        obj.latMax = min(ceil(obj.latMax), 90);
        
        %lonRange = (lonMax-lonMin);
        obj.lonMin = floor(obj.lonMin);
        obj.lonMax = ceil(obj.lonMax);
        
        lonRange = (obj.lonMax-obj.lonMin);
        if lonRange>=360
          obj.lonMin = -183.6;     %to account for fancy frame
          obj.lonMax = 183.6;
          obj.lonplus = 180;
          obj.lonmod = 360;
        else
          obj.lonplus = 0;
          obj.lonmod = 0;
        end
        
        % Positionning the right axes (set map current axe)
        % axes set visible prop to 'on'
        axes(obj.hdlMapAxes);
        obj.eraseLine;
        %set(obj.hdlMapAxes, 'XLimMode', 'auto', 'YLimMode', 'auto');
        
        % if toolbar map is selected, give focus to map
        obj.hdlMapFig.Visible = src.hdlMapToggletool.State;
        
        % display info on console
        tic;
        fprintf(1, 'load map with ');
        
        % Use of Mercator projection
        m_proj('Mercator','lat',[obj.latMin obj.latMax],'long',[obj.lonMin obj.lonMax]);
        
        % use different resolution
        switch src.preference.map_resolution
          case 1
            % Low-resolution coast lines
            fprintf(1, 'low resolution');
            m_coast('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
            
          case 2
            % Medium-resolution coast lines
            fprintf(1, 'medium resolution');
            m_gshhs_l('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
            
          case 3
            % Intermediate-resolution coast lines
            fprintf(1, 'intermediate resolution');
            m_gshhs_i('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
            
          case 4
            % High-resolution coast lines
            fprintf(1, 'high resolution');
            m_gshhs_h('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
          otherwise
            src.preference.map_resolution = 1;
            % Low-resolution coast lines
            fprintf(1, 'low resolution');
            m_coast('patch',[.7 .7 .7], 'TAG', 'TAG_PLOT4_LINE_COAST');
            
        end
        
        t = toc;  fprintf(1, ' ...done (%6.2f sec).\n',t);
        
        % Make a grid on the map with fancy box
        m_grid('box', 'fancy', 'tickdir', 'in', 'TAG', 'TAG_PLOT4_LINE_GRID', ...
          'Fontsize', src.preference.fontSize);
        
        % change with generic value in next version
        para = 'SSPS';
        
        % plot the line with QC color
        qCode = src.qc;
        QC = src.nc.Variables.([para '_QC']).data__;
        keys = fieldnames(qCode);
        for k = 1: length(keys)
          ind = find( QC == qCode.(keys{k}).code);
          if ~isempty( ind )
            m_line( mod(obj.lonx(ind) + obj.lonplus, obj.lonmod) - obj.lonplus,...
              obj.latx(ind),...
              'Tag', 'TAG_MAP_LINE','LineStyle', 'none', 'marker','*',...
              'markersize', 2, 'color', qCode.(keys{k}).color);
          end
        end
      end
      
    end % end of loadMap
    
    % zoomInOn
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
      hdlZoom.hdl = zoom(obj.hdlMapFig);
      hdlZoom.hdl.ActionPostCallback = {@(src,evt) zoomAndPanPostCallback(obj,src)};
      
      % Turns off the automatic adaptation of date ticks
      util.zoomAdaptiveDateTicks('on');
      
      % turns interactive zooming to in (increase)
      set(hdlZoom.hdl, 'direction', 'in');
      
      % Disallows a zoom operation on the MAP axes objects
      %      setAllowAxesZoom(hZoom, hPlotAxes(4), false);
      
      % turns on interactive zooming (same effect than zoom on) but prevent
      % side effect on another figure
      set(hdlZoom.hdl, 'enable', 'on');
      
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
    
    % Callback function run when zoom or pan action finishes: redraw axes
    % -------------------------------------------------------------------
    function zoomAndPanPostCallback(obj, src)
      
      % Set the right limit and interval to the 3 axes
      %     for iaxe = 1:3
      %       set(hPlotAxes(iaxe), 'XTickMode', 'auto')
      %       datetick(hPlotAxes(iaxe), 'x', 'keeplimits')
      %     end
      
      % Re-draw the map once the zoom/pan is off
      if strcmp( get(obj.hdlMapFig,'visible'), 'on') == 1
        % erase_Line( hPlotAxes, 4 );
        obj.plotMap(src);
      end
      
    end
    
    % Callback function run when the Quit Map Figure item is selected
    % ---------------------------------------------------------------
    function closeRequestMap(obj, src)
      
      % make the earth map invisible, don't close figure
      set(src, 'Visible', 'off' );
      set(obj.parent.hdlMapToggletool, 'state',  'off' );
      
    end
    
    % Erase line children of axe hAxe
    % -------------------------------
    function eraseLine( obj )
      hLines = findobj( obj.hdlMapAxes, '-regexp', ...
        'Tag', 'TAG_MAP_LINE');
      if ~isempty( hLines )
        delete(hLines);
      end
      
    end
    
    % wait for dataAvailableForMap event, plot map
    % --------------------------------------------
    function dataAvailableEvent(obj,src,~)
      fprintf(1, 'data available for %s\n', class(obj));
      obj.plotMap(src);
    end
    
    % executed on 'position' event reception from mousemotion callback
    % the maker handle is stored in axes userdata property
    % ----------------------------------------------------------------
    function positionOnMapEvent(obj,~,eventData)
      if eventData.index < length(obj.lonx)
        % if there is no Marker
        if isempty(obj.hdlMapAxes.UserData)
          % Plot a Marker (Red point) on the ship track
          hdlMarker = m_line( mod(obj.lonx(eventData.index) + ...
            obj.lonplus, obj.lonmod) - obj.lonplus,...
            obj.latx(eventData.index),...
            'Marker', 'o', 'MarkerSize', 5, ...
            'Color', 'r', 'MarkerFaceColor', 'r');
          % Put a tag on the Marker - This tag allows to get the handle
          % of the Marker
          obj.hdlMapAxes.UserData = hdlMarker;
        else         % a marker exists
          % Delete the Marker and redraw it
          delete(obj.hdlMapAxes.UserData);
          hdlMarker = m_line( ...
            obj.lonx(eventData.index), obj.latx(eventData.index),...
            'Marker', 'o', 'MarkerSize', 5, ...
            'Color', 'r', 'MarkerFaceColor', 'r');
          % Put a tag on the Marker - This tag allows to get the handle
          % of the Marker
          obj.hdlMapAxes.UserData = hdlMarker;
        end
      end
    end
    
       % wait for zoomPost event, zoom on map 
    % --------------------------------------------
    function zoomPostEvent(obj,src,~)
      fprintf(1, 'zoom available for %s\n', class(obj));
      %obj.plotMap(src);
    end
    
    %
    % ------------------------
    function mouseMotion(obj, ~)
      a = get(obj.hdlMapAxes, 'CurrentPoint');
      x = a(2,1);
      y = a(2,2);
      indCursor = find(obj.lonx > x, 1, 'first');
      % send event for plot position on map
      notify(obj, 'positionOnMap', tsgqc.positionOnMapEventData(indCursor));
    end
  end
  
end

