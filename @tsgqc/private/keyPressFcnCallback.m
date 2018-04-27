% Callback function run when key is pressed
  function keyPressFcnCallback(obj, evnt)
    disp(strcat(class(obj),': keyPressFcnCallback callback module not yet implemented'));
    
%     % MATLAB generates repeated KeyPressFcn events, desactivate callback
%     % ------------------------------------------------------------------
%     set(hObject, 'KeyPressFcn', []);
%     
%     % check if key is pressed
%     % -----------------------
%     if ~isempty(evnt.Key)
%       
%       % test key, shift or control
%       % --------------------------
%       switch evnt.Key
%         
%         case 'shift'
%           
%           % get current pointer shape
%           % -------------------------
%           pointerShape = get(hObject, 'pointer');
%           
%           % save current cursor shape
%           % -------------------------
%           setappdata( hMainFig, 'tsg_pointer', pointerShape);
%           
%           % set cursor to fullcross or reset to normal arrow
%           % ------------------------------------------------
%           set(hObject, 'pointer', 'fullcrosshair');
%           
%         case 'control'
%           
%           % Get current position of cusor and return its coordinates in
%           % axes
%           % -----------------------------------------------------------
%           a = get(hPlotAxes(1), 'CurrentPoint');
%           x = a(2,1);
%           
%           % Test if cursor is inside data interval
%           % -------------------------------------
%           if x > tsg.DAYD(1) && x < tsg.DAYD(end)
%             
%             % loop over 3 subplot and draw vertical lines
%             % -------------------------------------------
%             for iplot = 1:3
%               axes( hPlotAxes(iplot));
%               limy = get(hPlotAxes(iplot), 'YLim');
%               line([x x], limy, 'color', 'k', 'EraseMode', 'xor',...
%                 'tag', 'VERTICAL_TAG_LINE');
%             end
%             
%           end
%           
%       end % end of switch
%       
%     end
%     
%   end