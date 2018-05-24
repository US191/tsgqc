function setQcUI(obj)
% setQcUI create a panel for QC and a contextual menu

% get local fontSize variable for next use
fontSize = obj.preference.fontSize;

% define quality panel group
obj.hdlQCPanel  = uibuttongroup(...
  'Parent', obj.hdlMainFig, ...
  'Title', 'Validation Codes', ...
  'FontSize', fontSize, 'Fontweight', 'bold', ...
  'tag', 'TAG_QC_DISPLAY_PANEL',...
  'HandleVisibility','on',...
  'Visible', 'off',...
  'BorderType', 'etchedin',...
  'Units', 'normalized', 'Position', [.0, .78, .15, .18]);

% set QC contextual menu
obj.hdlQcContextmenu = uicontextmenu(...
  'Parent',  obj.hdlMainFig, ...
  'HandleVisibility','on' );

% get cell array of struct fields
qcList = fieldnames(obj.qc);

% iterate (loop) on each key store inside structure quality
for i = 1 : length(qcList)
  
  % local counter used to positioning uicontrol
  count = i-1;
  
  % get key from cell array
  key = qcList{i};
  
  % dynamically get values from struct
  label = obj.qc.(key).label;
  color = obj.qc.(key).color;
  state = obj.qc.(key).state;
  
  % construct  menu with only state set to 'on' (valid)
  if strcmp( state, 'on')
    
    % add button QC to hbgQc uibuttongroup
    uicontrol(...
      'Parent', obj.hdlQCPanel,...
      'Style', 'radiobutton',...
      'Fontsize', fontSize-1, 'ForegroundColor', color,...
      'HorizontalAlignment', 'left', ...
      'HandleVisibility','on', ...
      'String', label,...
      'Tag', ['TAG_QC_RADIO_' key], ...
      'Units', 'normalized', 'Position', [.01, .85-count*.12, .6, 0.09],...
      'Callback', {@activeQcPopupMenu, key});
    
    % add text QC display statistic on hQcPanel
    uicontrol(...
      'Parent', obj.hdlQCPanel,...
      'Style', 'text',...
      'Fontsize', fontSize-1, 'ForegroundColor', color,...
      'HorizontalAlignment', 'right', ...
      'HandleVisibility','on', ...
      'String', 'N/A ',...
      'Tag', ['TAG_QC_TEXT_' key],...
      'Units', 'normalized', 'Position', [.61, .85-count*.12, .37, 0.09]);
    
    % create contextual menu for each qc
    uimenu(...
      'Parent', obj.hdlQcContextmenu,...
      'HandleVisibility','on', ...
      'Label', label,...
      'ForegroundColor', color,...
      'Callback', {@activeQcContextMenu, key});
    
  end
  
end

% nested function to set used to save the active code in activeQc property
% ------------------------------------------------------------------------
  function activeQcPopupMenu(src, evnt, key)
    obj.activeQc.code = obj.qc.(key).code;
    obj.activeQc.color = obj.qc.(key).color;
  end

% nested function used to save the active code.
% and change the QC radiobutton selected from contextual menu
% -------------------------------------------------------------
  function activeQcContextMenu(src, evnt, key)
    obj.activeQc.code = obj.qc.(key).code;
    obj.activeQc.color = obj.qc.(key).color;
    
  % get the QC uicontrol handle from tag and 
  hdlRadio = findobj(obj.hdlMainFig, 'tag', ['TAG_QC_RADIO_' key]);
  
  % give it the focus eventualy selected with the contextual menu
  hdlRadio.Value = 1; 
  
  % call 
  obj.QcSelectCallback
  end

end





