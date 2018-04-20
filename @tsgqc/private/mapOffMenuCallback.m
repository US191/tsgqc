function mapOffMenuCallback(obj, ~)

% Make the earth map invisible
set(obj.map.hdlMapFig, 'Visible', 'off' );

% Re-activate keyPressFcn callback on main fig
set(obj.hdlMainFig, 'KeyPressFcn', @keyPressFcnCallback);

end