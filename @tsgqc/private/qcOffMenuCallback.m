function qcOffMenuCallback(obj, ~)
% qcOffMenuCallback activate calibration and interpolate toolbar function

set(obj.hdlCalToggletool,        'Enable',  'on');
set(obj.hdlInterpToggletool,     'Enable',  'on');

% activate left TSG parameter panel
set(obj.hdlLeftPanel,            'Visible', 'on');

% desactivate QC panel and QC context menu
set(obj.hdlQCPanel,              'Visible', 'off');
%set(obj.hdlQcContextmenu,        'Visible', 'off');

set(obj.plot.hdlPlotAxes,'UIContextMenu', []);

% return back cursor to arrow aspect
set( obj.hdlMainFig, 'Pointer', 'arrow');

