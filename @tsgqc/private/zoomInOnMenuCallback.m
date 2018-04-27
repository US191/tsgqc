function zoomInOnMenuCallback(obj, ~)

% send event zoomOn to application
notify(obj, 'zoomOn');

hdlZoom = zoom(obj.axes.hdlPlotAxes(1));

util.zoomAdaptiveDateTicks('off');

 set(hdlZoom, 'direction', 'in');
 
 set(hdlZoom, 'enable', 'on');
 

 %hdlZoom.hdl.ActionPostCallback = {@(src,evt) zoomAndPanPostCallback(obj,src)};
