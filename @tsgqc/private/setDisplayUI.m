function setDisplayUI(obj)
% setDisplayUI draw a plot area that displays the loaded filename, date, position and
% salinity, temperature above the first plot

% Create an uipanel
obj.hdlInfoPanel = uipanel( ...
  'Parent', obj.hdlMainFig, ...
  'Units', 'normalized', ...
  'BorderType', 'none',...
  'Visible', 'on', ...
  'Position',[.01, .96, .98, .04]);

% Dynamic text area that displays the date
uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Units', 'normalized', ...
  'Style', 'Text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Fontweight', 'bold', ...
  'HorizontalAlignment', 'left', ...
  'Position',[.01, .25, .04, .6], ...
  'String', 'File:');

obj.hdlInfoFileText = uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Style', 'text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Visible','on',...
  'Units', 'normalized',...
  'HorizontalAlignment', 'left', ...
  'String', 'No file loaded', ...
  'Position', [.05, .25, .1, .6]);

% Text area that displays the date
uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Units', 'normalized', ...
  'Style', 'Text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Fontweight', 'bold', ...
  'HorizontalAlignment', 'left', ...
  'Position',[.15, .25, .04, .6], ...
  'String', 'Date:');

obj.hdlInfoDateText = uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Style', 'text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Visible','on',...
  'Units', 'normalized',...
  'HorizontalAlignment', 'left', ...
  'String', 'N/A', ...
  'Position', [.20, .25, .13, .6]);

% Text area that displays the latitude
uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Units', 'normalized', ...
  'Style', 'Text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Fontweight', 'bold', ...
  'HorizontalAlignment', 'left', ...
  'Position',[.33, .25, .06, .6], ...
  'String', 'Latitude:');

obj.hdlInfoLatText = uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Style', 'text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Visible','on',...
  'Units', 'normalized',...
  'HorizontalAlignment', 'left', ...
  'String', 'N/A', ...
  'Position', [.4, .25, .9, .6]);

% Text area that displays the longitude
uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Units', 'normalized', ...
  'Style', 'Text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Fontweight', 'bold', ...
  'HorizontalAlignment', 'left', ...
  'Position',[.495, .25, .08, .6], ...
  'String', 'Longitude:');

obj.hdlInfoLongText = uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Style', 'text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Visible','on',...
  'Units', 'normalized',...
  'HorizontalAlignment', 'left', ...
  'String', 'N/A', ...
  'Position', [.585, .25, .09, .6]);

% Text area that display salinity and temperature
uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Units', 'normalized', ...
  'Style', 'Text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Fontweight', 'bold', ...
  'HorizontalAlignment', 'left', ...
  'Position', [.68, .25, .05, .6], ...
  'String', 'SSPS:');

obj.hdlInfoSSPSText = uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Style', 'text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Visible','on',...
  'Units', 'normalized',...
  'HorizontalAlignment', 'left', ...
  'String', 'N/A', ...
  'Position', [.73, .25, .05, .6]);
uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Units', 'normalized', ...
  'Style', 'Text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Fontweight', 'bold', ...
  'HorizontalAlignment', 'left', ...
  'Position',[.785, .25, .05, .6], ...
  'String', 'SSJT:');

obj.hdlInfoSSJTText = uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Style', 'text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Visible','on',...
  'Units', 'normalized',...
  'HorizontalAlignment', 'left', ...
  'String', 'N/A', ...
  'Position', [.835, .25, .05, .6]);
uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Units', 'normalized', ...
  'Style', 'Text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Fontweight', 'bold', ...
  'HorizontalAlignment', 'left', ...
  'Position',[.89, .25, .05, .6], ...
  'String', 'SSTP:');

obj.hdlInfoSSTPText = uicontrol(...
  'Parent', obj.hdlInfoPanel, ...
  'Style', 'text', ...
  'Fontsize', obj.preference.fontSize, ...
  'Visible','on',...
  'Units', 'normalized',...
  'HorizontalAlignment', 'left', ...
  'String', 'N/A', ...
  'Position', [.94, .25, .05, .6]);
