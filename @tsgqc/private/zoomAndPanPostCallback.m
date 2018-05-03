function zoomAndPanPostCallback(obj, ~)

% send event zoomPost to application (map)
disp('zoomAndPanPostCallback : je passe !');
notify(obj, 'zoomPost');

