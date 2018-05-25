function QcSelectCallback(obj, src, evnt)
% TODOS: add bottle selection, see tsgqc V1 line 2139

% Selection of the data within the figure
point1    = get(gca,'CurrentPoint');    % button down detected
rbbox;                      % return figure units
point2    = get(gca,'CurrentPoint');    % button up detected

point1 = point1(1,1:2);                 % extract x and y
point2 = point2(1,1:2);

p1 = min(point1,point2);
p2 = max(point1,point2);

% TODOS: pass array para as argument of eventData
para = get(obj.hdlParameter(1), 'string');
PARA = {para{get(obj.hdlParameter(1), 'value')}};

if ~strcmp( get(gcf, 'SelectionType'), 'alt')
  % get index on selected zone
  ind = find(obj.nc.Variables.DAYD.data__ > p1(1,1) & ...
    obj.nc.Variables.DAYD.data__ < p2(1,1) & ...
    obj.nc.Variables.(PARA{1}).data__ > p1(1,2) & ...
    obj.nc.Variables.(PARA{1}).data__ < p2(1,2));
  
  % keep the information on the indices of the selected zone
  obj.rbboxInd = ind .* ones(size(ind));
else
  ind =  obj.rbboxInd;
end

% modifiy the QC
obj.nc.Variables.([PARA{1} '_QC']).data__(ind) = obj.activeQc.code;

% fill eventData
evtData = tsgqc.parameterChoiceEventData(PARA);

% send event dataAvailable to application
%notify(obj, 'dataAvailable', evtData);
% notify(obj, 'dataAvailableForMap');
obj.plot.plotData(evtData);
obj.map.plotMap;

% update QC panel
obj.updateQcPanel;


