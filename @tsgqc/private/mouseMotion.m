function mouseMotion(obj, ~)
% mouseMotion update displayUI and notify an event for plotting the new
% position on map

% get position on first plot
a = get(obj.plot.hdlPlotAxes(1), 'CurrentPoint');
x = a(2,1);
y = a(2,2);

% limx = obj.plot.hdlPlotAxes(1).XLim;
% limy = obj.plot.hdlPlotAxes(1).YLim;

% get netcdf variables as local tsg structure
tsg = obj.nc.Variables;

% if cursor is out of valid data, display blank
if x < tsg.DAYD.data__(1) && x > tsg.DAYD.data__(end)
  set( obj.hdlInfoDateText, 'String', '' );
  set( obj.hdlInfoLatText,  'String', '' );
  set( obj.hdlInfoLongText, 'String', '' );
  set( obj.hdlInfoSSPSText, 'String', '' );
  set( obj.hdlInfoSSTPText, 'String', '' );
  set( obj.hdlInfoSSJTText, 'String', '' );
else
  % get index of cursor location
  indCursor = find( tsg.DAYD.data__ > x, 1, 'first');
  
  % display informations of cursor location in text uicontrol
  set( obj.hdlInfoDateText, 'String',...
    datestr(tsg.DAYD.data__(indCursor),'dd/mm/yyyy   HH:MM'));
  %   if tsg.preference.positions_format_value == 1
  %     set( hInfoLatText,  'String', dd2dm(tsg.LATX(indCursor), 0) );
  %     set( hInfoLongText, 'String', ...
  %       dd2dm(mod(tsg.LONX(indCursor) + 180, 360) - 180, 1) );
  %   else
  set( obj.hdlInfoLatText,  'String', tsg.LATX.data__(indCursor) );
  set( obj.hdlInfoLongText, 'String', ...
    mod(tsg.LONX.data__(indCursor) + 180, 360) - 180 );
  %   end
  if ~isempty(tsg.SSPS.data__)
    set( obj.hdlInfoSSPSText, 'String', tsg.SSPS.data__(indCursor) );
  end
  if ~isempty(tsg.SSJT.data__)
    set( obj.hdlInfoSSJTText, 'String', tsg.SSJT.data__(indCursor) );
  end
  if ~isempty(tsg.SSTP.data__)
    set( obj.hdlInfoSSTPText, 'String', tsg.SSTP.data__(indCursor) );
  end
  
  % send event for plot position on map
  notify(obj.map, 'position', tsgqc.positionOnMapEventData(indCursor));
end