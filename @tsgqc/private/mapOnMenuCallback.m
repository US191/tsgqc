function mapOnMenuCallback(obj, ~)

% Desactivate Zoom and Pan toggle buttons
% TODOS: to check
% set(obj.hdlZoomInToggletool,  'state', 'off' );
% set(obj.hdlZoomOutToggletool,  'state', 'off' );
set(obj.hdlPanToggletool,   'state', 'off' );

% Make the earth map visible
set(obj.map.hdlMapFig, 'Visible', 'on' );

%erase_Line( obj.hdlPlotAxes, 4 );
%plot_map( hMainFig, hPlotAxes)

% De-activate keyPressFcn callback on main fig
% set(obj.hdlMainFig, 'KeyPressFcn', []);

end