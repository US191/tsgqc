% callback function run when key is released
function keyReleaseFcnCallback(obj, src, evnt)

% check if key is pressed
if ~isempty(evnt.Key)
  
  % test key, shift or alt/control
  switch evnt.Key
    
    case 'shift'
      
      % restore cursor to normal arrow
      set(src, 'pointer', 'arrow');
      
    case {'alt','control'}
      
      % delete existing vertical line(s) first
      delete(findobj('tag', 'VERTICAL_TAG_LINE'));
      
      
  end
end

% re-activate callback
set(src, 'KeyPressFcn', {@obj.keyPressFcnCallback});