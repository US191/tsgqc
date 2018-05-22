function saveConfig(obj, ~)
% Must be a string scalar or character vector
tsgqcPrefs = obj.preference; %#ok<NASGU>
save(obj.configFile, 'tsgqcPrefs');
end % end of saveConfig