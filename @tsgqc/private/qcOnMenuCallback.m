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
set(obj.axes.hdlPlotAxes,'UIContextMenu', obj.hdlQcContextmenu);

% activate clic mouse menu on first axes (salinity) for next rbbox
%set(hPlotAxes(1),'ButtonDownFcn', @QC_SelectCallback);

% change cursor to crosshair aspect
set( obj.hdlMainFig, 'Pointer', 'crosshair');


