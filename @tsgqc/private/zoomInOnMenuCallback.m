function zoomInOnMenuCallback(obj, ~)

% send event zoomOn to application
notify(obj, 'zoomOn');

obj.hdlZoom = zoom(obj.axes.hdlPlotAxes(1));

obj.hdlZoom.ActionPostCallback = {@(src,evt) zoomAndPanPostCallback(obj,src)};

util.zoomAdaptiveDateTicks('off');

obj.hdlZoom.Direction = 'in';

obj.hdlZoom.Enable = 'on';

end