function saveConfig(obj, ~)
% Must be a string scalar or character vector
tsqgcPrefs = obj.preference;
save(obj.configFile, 'tsqgcPrefs');
end % end of saveConfig