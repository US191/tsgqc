function loadConfig(obj, ~)

import tsgqc.preference

% test if configuration .mat file exist
if exist(obj.configFile, 'file') == 2
  
  try
    % try to load class instance in local workspace
    load(obj.configFile, 'tsqgcPrefs');
    % affect local workspace tsgqcPrefs to preference instance
    obj.preference = tsqgcPrefs;
  catch
    % on error, load default preference class
    obj.preference = preference(obj.VERSION, obj.DATE);
  end
  
  % for a new version, reload default preference class
  if isa(tsqgcPrefs, 'preference') && ~strcmp(obj.preference.version, obj.VERSION)
    obj.preference = preference(obj.VERSION, obj.DATE);
  elseif ~isa(tsqgcPrefs, 'preference')
    obj.preference = preference(obj.VERSION, obj.DATE);
  end
else
  obj.preference = preference(obj.VERSION, obj.DATE);
end 