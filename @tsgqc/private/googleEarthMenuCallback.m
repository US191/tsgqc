function googleEarthMenuCallback(obj, ~)
% googleEarthMenuCallback function run when the Google Earth toolbar item is selected
% this function create a kml file with the name of file and open Google
% Earth

% call KML Toolbox functions
k = tsgqc.kml(obj.nc.Attributes.CYCLE_MESURE);

% get indice from the selected area
ind = find(obj.nc.Variables.DAYD.data__ > obj.axes.hdlPlotAxes(1).XLim(1) & ...
  obj.nc.Variables.DAYD.data__ < obj.axes.hdlPlotAxes(1).XLim(2) );

% Color value format must be passed as a character array according
% to the format string 'AABBGGRR', eg: red = 'FF0000FF'
k.plot(obj.nc.Variables.LONX.data__(ind), obj.nc.Variables.LATX.data__(ind), 'linewidth', 2,...
  'linecolor', 'FF0000FF');
k.run;

end