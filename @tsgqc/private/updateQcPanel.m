function updateQcPanel(obj)
% updateQcPanel refresh QC statistic panel

% get cell array of struct fields
qcList = fieldnames(obj.qc);

% iterate (loop) on each key store inside structure quality
for i = 1 : length(qcList)
  
  % get key from cell array
  key = qcList{i};
  
  % retrieve QC value
  code = obj.qc.(key).code;
  
  % get the uicontrol handle from tag construct with key
  hdlText = findobj(obj.hdlMainFig, 'tag', ['TAG_QC_TEXT_' key]);

  % find number of sample flag with this QC code
  ind = find(obj.nc.Variables.SSPS_QC.data__ == code);

  % if index empty, no data with this flag, set field to zero (char)
  if isempty(ind)
    set(hdlText, 'String', '0');
  else
    set(hdlText, 'String', num2str(numel(ind)));
  end
  
end

