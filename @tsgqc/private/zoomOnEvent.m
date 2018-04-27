function zoomOnEvent(obj,~,~)

% if one of two toggletool zoom is cliked (state on) the other one
% is release (state off) and disable (enable off)  
if strcmp(obj.hdlZoomInToggletool.State, 'on')
  obj.hdlZoomOutToggletool.State = 'off';
  obj.hdlZoomOutToggletool.Enable = 'off';
elseif strcmp(obj.hdlZoomOutToggletool.State, 'on')
   obj.hdlZoomInToggletool.State = 'off';
  obj.hdlZoomInToggletool.Enable = 'off';
end

% enable some toolbar pushButton when zoon is off
obj.hdlPanToggletool.Enable = 'off';
obj.hdlQCToggletool.Enable = 'off';
obj.hdlTimelimitToggletool.Enable = 'off';
%set(obj.hdlGoogleEarthPushtool,  'Enable', 'off');
obj.hdlHeaderPushtool.Enable = 'off';
obj.hdlReportPushtool.Enable = 'off';

