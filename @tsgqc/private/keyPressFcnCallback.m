% callback function run when key is pressed
function keyPressFcnCallback(obj, src, evnt)

% MATLAB generates repeated KeyPressFcn events, desactivate callback
set(src, 'KeyPressFcn', []);

% check if key is pressed
if ~isempty(evnt.Key)
  %
  % test key, shift or alt/control
  switch evnt.Key
    
    case 'shift'
      
      % set cursor to fullcross or reset to normal arrow
      set(src, 'pointer', 'crosshair');
      
    case {'alt','control'}
      
      % get current position of cusor and return its coordinates in
      % axes
      a = get(obj.axes.hdlPlotAxes(1), 'CurrentPoint');
      x = a(2,1);
      
      % test if cursor is inside data interval
      if x > obj.nc.Variables.DAYD.data__(1) && x < obj.nc.Variables.DAYD.data__(end)
        
        % loop over 3 subplot and draw vertical lines
        for iplot = 1:3
          limy = get(obj.axes.hdlPlotAxes(iplot), 'YLim');
          line(obj.axes.hdlPlotAxes(iplot), [x x], limy, 'color', 'k',...
            'tag', 'VERTICAL_TAG_LINE');
        end
        
      end
      
  end % end of switch
  
end

