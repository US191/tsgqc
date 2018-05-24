function qcOnMenuCallback(obj, ~)
% qcOnMenuCallback desactivate calibration and interpolate functions
% and activate QC panel and QC context menu

set(obj.hdlCalToggletool,        'Enable', 'off');
set(obj.hdlInterpToggletool,     'Enable', 'off');

% desactivate left TSG parameter panel
set(obj.hdlLeftPanel,            'Visible', 'off');

% update panel with effective number for each QC
obj.updateQcPanel;

% activate QC panel and QC context menu
set(obj.hdlQCPanel,              'Visible', 'on');
%set(obj.hdlQcContextmenu,        'Visible', 'on');

% activate right clic context on axes
set(obj.axes.hdlPlotAxes, 'UIContextMenu', obj.hdlQcContextmenu);

% activate clic mouse menu on first axes (salinity) for next rbbox
set(obj.axes.hdlPlotAxes, 'ButtonDownFcn', @QC_SelectCallback);

% change cursor to crosshair aspect
set( obj.hdlMainFig, 'Pointer', 'crosshair');


% nested function QC_SelectCallback
% ---------------------------------
  function QC_SelectCallback(src, evnt)
    
    % Selection of the data within the figure
    point1    = get(gca,'CurrentPoint');    % button down detected
    finalRect = rbbox;                      % return figure units
    point2    = get(gca,'CurrentPoint');    % button up detected
    
    point1 = point1(1,1:2);                 % extract x and y
    point2 = point2(1,1:2);
    
    p1 = min(point1,point2);
    p2 = max(point1,point2);
    
         % TODOS: pass array para as argument of eventData
      para1 = get(obj.hdlParameter(1), 'string');
      para2 = get(obj.hdlParameter(2), 'string');
      para3 = get(obj.hdlParameter(3), 'string');
      PARA = {para1{get(obj.hdlParameter(1), 'value')}, ...
        para2{get(obj.hdlParameter(2), 'value')},...
        para3{get(obj.hdlParameter(3), 'value')}};
    
    % get index on selected zone
    ind = find(obj.nc.Variables.DAYD.data__ > p1(1,1) & ...
      obj.nc.Variables.DAYD.data__ < p2(1,1) & ...
      obj.nc.Variables.(PARA{1}).data__ > p1(1,2) & ...
      obj.nc.Variables.(PARA{1}).data__ < p2(1,2));
    
    disp(ind)
    
  end

end