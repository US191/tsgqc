function [choix, ColNo, paraName, DELIMITER] = choixparametres( fid )
% 
% Cette fonction permet a l'utilisateur de choisir les parametres presents
% dans le fichier et qui seront utilises par le programme.
% Le choix se fait sur les parametres suivants :
%              date, heure, lat, lon
% La fonction retournera systematiquement les parametres suivants
%                cond, hcond, sog, cog
%
% [ColNo, nPara] = choixparametres( fid, DELIMITER );
%
% Input
%   fid ........... Numero logique du fichier a decoder
%   DELIMITER ..... caractere separant chaque parametre a decoder sur
%                   une ligne
%
% output
%   choix ......... String 'ok' ou 'cancel' qui indique si le programme
%                   doit s'arreter
%   ColNo ......... Structure donnant pour chaque parametre le numero de
%                   la colonne a lire
%   paraName ...... Intitule des parametres de la ligne d'entete 
%   nPara ......... Nombre de parametre total present dans le fichier
%
% Fontion mere :        readTsgDataLabview
% Fonctions appelees :  decodestr, lbvParameterChoice
% ------------------------------------------------------------------------

% Initialisation des indices de colonne que l'on conserve systematiquement
% -------------------------------------------------------------------------
dateNo = 0; timeNo = 0; tempNo = 0; salNo = 0; salStdNo = 0; condNo = 0; 
rawNo = 0; latNo = 0; lonNo = 0; sogNo = 0; cogNo = 0;

% Lecture de la 1ere ligne
%
% ATTENTION : Je considere que cette ligne est la ligne d'entete
% IL FAUDRAIT FAIRE UN TEST POUR VERIFIER QUE C'EST BIEN  UNE LIGNE
% D'ENTETE
% --------------------------------------------------------------
firstLine = fgets( fid );
    
% Decode la ligne d'entete et place l'intitule de chaque colonne
% dans une variable de type 'cell' : paraName, 
% don't use strsplit introduced in R2013a
% use regexp introduced before R2006 instead
% -------------------------------------------------------------------
% [paraName, delimiters] = strsplit( firstLine, {',',';'} );
% DELIMITER = delimiters{1};
[paraName, delimiters] = regexp(firstLine, ',|;', 'split');
DELIMITER = firstLine(delimiters(1));

% Convertit les intitules de chaque colonne en caracteres minuscules
% ------------------------------------------------------------------
paraName = lower(paraName);
  
% Affichage d'une 'boite a liste' pour le choix des parametres
% ------------------------------------------------------------
%   [colParaNo, okCol] = listdlg('PromptString', 'Choix des paramètres',...
%     'ListString', paraName, 'InitialValue', defAnsB);

[colParaNo, okCol] = lbvParameterChoice( paraName );

if okCol == 1

  % Everything's ok
  % ---------------
  choix = 'ok';

  % Initialisation de la structure indiquant le numero de colonnes des parametres
  % presents dans le fichier intial et qui seront utilises dans TSG-QC
  % --------------------------------------------------------------
  ColNo = struct( 'Date', 0, 'Time', 0, 'Lat', 0, 'Lon', 0, 'Temp', 0,...
    'Sal', 0, 'SalStd', 0, 'Cond', 0, 'Raw', 0, 'Sog', 0, 'Cog', 0, 'AD1', 0);

  % Boucle sur les numeros de colonnes des parametres qui seront conserves
  % ----------------------------------------------------------------------
  if ~isempty(okCol)
    for icol = 1 : length(colParaNo)

      % Convertion en caracteres
      % ------------------------
      header = char( paraName(1, colParaNo(icol)) );

      % Place les numeros des colonnes dans la structure
      % ------------------------------------------------
      if strfind( header, 'date') ~= 0
        ColNo.Date = colParaNo(icol);
      elseif strfind( header, 'time') ~= 0
        ColNo.Time = colParaNo(icol);
      elseif strfind( header, 'lat') ~= 0
        ColNo.Lat = colParaNo(icol);
      elseif strfind( header, 'lon') ~= 0
        ColNo.Lon = colParaNo(icol);
      elseif strfind( header, 'temp') ~= 0
        ColNo.Temp = colParaNo(icol);
      elseif strfind( header, 'sal') ~= 0
        ColNo.Sal = colParaNo(icol);
      elseif strfind( header, 'stddev') ~= 0
        ColNo.SalStd = colParaNo(icol);
      elseif strfind( header, 'cond') ~= 0
        ColNo.Cond = colParaNo(icol);
      elseif strfind( header, 'raw') ~= 0
        ColNo.Raw = colParaNo(icol);
      elseif strfind( header, 'sog') ~= 0
        ColNo.Sog = colParaNo(icol);
      elseif strfind( header, 'cog') ~= 0
        ColNo.Cog = colParaNo(icol);
      elseif strfind( header, 'ad1') ~= 0
        ColNo.AD1 = colParaNo(icol);
      end
    end
  end

else

  % On annulle le choix des parametres. Le programme se termine
  % -----------------------------------------------------------
  ColNo = [];
  choix = 'cancel';

end     % fin de test if okCol == 1


% Revient en debut de fichier
% ---------------------------
frewind(fid);