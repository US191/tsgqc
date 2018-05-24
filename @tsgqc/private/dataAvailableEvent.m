function dataAvailableEvent(obj,~,~)

% enable mouse motion
obj.hdlMainFig.WindowButtonMotionFcn = {@(src,evt) mouseMotion(obj,src)};
           
% enable  toolbar pushButtons when data is read from file and
% available for processing
set(obj.hdlSaveMenu,             'Enable', 'on');
set(obj.hdlExportMenu,           'Enable', 'on');
set(obj.hdlSavePushtool,         'Enable', 'on');
set(obj.hdlPrintFigPushtool,     'Enable', 'on');
set(obj.hdlZoomInToggletool,     'Enable', 'on');
set(obj.hdlZoomOutToggletool,    'Enable', 'on');
set(obj.hdlPanToggletool,        'Enable', 'on');
set(obj.hdlQCToggletool,         'Enable', 'on');
set(obj.hdlTimelimitToggletool,  'Enable', 'on');
set(obj.hdlMapToggletool,        'Enable', 'on');
set(obj.hdlGoogleEarthPushtool,  'Enable', 'on');
set(obj.hdlClimToggletool,       'Enable', 'on');
set(obj.hdlCalToggletool,        'Enable', 'on');
set(obj.hdlInterpToggletool,     'Enable', 'on');
set(obj.hdlBottleToggletool,     'Enable', 'on');
set(obj.hdlHeaderPushtool,       'Enable', 'on');
set(obj.hdlReportPushtool,       'Enable', 'on');

% enable left panel
set(obj.hdlLeftPanel,            'Visible', 'on');
end