classdef plot < handle
  %tsgqc.plot
  %   Detailed explanation goes here
  
  properties
    hdlParent
    hdlPlotsPanel
    hdlPlotAxes
    hdlDataAvailable
  end
  
  methods
    
    % tsgqc.plot constructor; take tsgqc parent object as parameter
    % ---------------------------------------------------------------
    function obj = plot(parent)
      
      obj.hdlParent = parent.hdlMainFig;
      obj.setUI;
      % add listener from tsgqc when data are available
      obj.hdlDataAvailable = addlistener(parent,'dataAvailable',@obj.dataAvailableEvent);
    end
    
    % build plot data User Interface
    % --------------------------------
    function setUI(obj)
      obj.hdlPlotsPanel = uipanel( ...
        'Parent', obj.hdlParent, ...
        'Units', 'normalized', ...
        'BorderType', 'etchedin',...
        'Visible', 'on',...
        'Position',[0.15, 0.0, .85, .95]);
      
      obj.hdlPlotAxes(1) = axes( 'Parent', obj.hdlPlotsPanel, 'Visible', 'off', ...
        'box', 'on', 'Units', 'normalized','Tag', 'TAG_AXES_1', ...
        'HandleVisibility','on', 'Position',[.05, .64, .93, .35]);
      obj.hdlPlotAxes(2) = axes( 'Parent', obj.hdlPlotsPanel, 'Visible', 'off',...
        'box', 'on', 'Units', 'normalized', 'Tag', 'TAG_AXES_2', ...
        'HandleVisibility','on', 'Position',[.05, .33, .93, .27]);
      obj.hdlPlotAxes(3) = axes('Parent', obj.hdlPlotsPanel, 'Visible', 'off',...
        'box', 'on', 'Units', 'normalized', 'Tag', 'TAG_AXES_3', ...
        'HandleVisibility','on', 'Position',[.05, .02, .93, .27]);
    end % end of tsgqc.plot constructor
    
  end % end of public methods
  
  methods (Access = private)
    
    % plot data
    % ---------
    function loadPlots(obj,tsg)
      lineType =  'none';
      markType = '*';
      colVal = 'b';
      markSize = 2;
      % Positionning the right axes (set map current axe)
      axes(obj.hdlPlotAxes(1));
      line( tsg.nc.Variables.DAYD.data__, tsg.nc.Variables.SSPS.data__, ...
        'Tag', ['TAG_PLOT' '_SSPS' '_LINE_'], ...
        'LineStyle', lineType, ...
        'Marker', markType, 'MarkerSize', markSize, 'Color', colVal);
      obj.axesCommonProp;
    end
    
    function axesCommonProp(obj)
      %
      % $Id: axesCommonProp.m 775 2017-01-17 15:07:06Z jgrelet $
      
      datetick(obj.hdlPlotAxes(1), 'x', 'keeplimits');
      datetick(obj.hdlPlotAxes(2), 'x', 'keeplimits');
      datetick(obj.hdlPlotAxes(3), 'x', 'keeplimits');
      
      % Make the axes visible
      % ---------------------
      set(obj.hdlPlotAxes(1), 'Visible', 'on' );
      set(obj.hdlPlotAxes(2), 'Visible', 'on' );
      set(obj.hdlPlotAxes(3), 'Visible', 'on' );
      
      drawnow
      
      % The 3 axes will behave identically when zoomed and panned
      % Since R2014b figure became an object, linkaxes failed if
      % the 3 axes not defined
      % ---------------------------------------------------------
      if verLessThan('matlab','8.4')
        linkaxes([obj.hdlPlotAxes(1),obj.hdlPlotAxes(2),obj.hdlPlotAxes(3)], 'x');
      else
        if obj.hdlPlotAxes(2).XLim(1) ~= 0 && obj.hdlPlotAxes(3).XLim(1) ~= 0
          linkaxes([obj.hdlPlotAxes(1),obj.hdlPlotAxes(2),obj.hdlPlotAxes(3)], 'x');
        end
      end
      
    end
    
    
    % wait for dataAvailable event from tsgqc
    % ---------------------------------------
    function dataAvailableEvent(obj,src,~)
      disp(strcat(class(obj),': data available for plot'));
      obj.loadPlots(src);
    end
  end
  
end

