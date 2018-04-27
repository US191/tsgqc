function zoomOffEvent(obj,~,~)

% if one of two toggletool zoom is cliked (state on) the other one
% is release (state off) and disable (enable off)  
if strcmp(obj.hdlZoomInToggletool.State, 'off')
   obj.hdlZoomOutToggletool.State = 'off';
  obj.hdlZoomOutToggletool.Enable = 'on';
elseif strcmp(obj.hdlZoomOutToggletool.State, 'off')
  obj.hdlZoomInToggletool.State = 'off';
  obj.hdlZoomInToggletool.Enable = 'on';
end

% enable some toolbar pushButton when zoon is off
obj.hdlPanToggletool.Enable = 'on';
obj.hdlQCToggletool.Enable = 'on';
obj.hdlTimelimitToggletool.Enable = 'on';
%set(obj.hdlGoogleEarthPushtool,  'Enable', 'on');
obj.hdlHeaderPushtool.Enable = 'on';
obj.hdlReportPushtool.Enable = 'on';