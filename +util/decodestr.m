function [token, nToken] = DecodeStr( string, DELIMITER )
%
% Retourne les �l�ments d'une chaine de caract�res s�par�s par
% un delimiteur (virgule, point-virgule, etc.)
%
% [Token, nToken] = DecodeStr( String, Delimiter )
%
% Input:			
%    string ...... Chaine de caract�res � d�cimer
%    DELIMITEUR ... Caract�re s�parant les diff�rents �l�ments
%                  de la chaine de caract�res
%                               
% Output:
%    nToken ...... Nombre d'�l�ments distincts, s�par�s par 'Delimiter'
%                  dans la chaine de caract�res 'String'
%    token ....... Cellule de dimension (nToken, 1) contenant les
%                  diff�rents �ll�ments de la chaine de caract�re
%
% 5 janvier 2007
%
% Modifications
% ----------------------------------------------------------------------

% Initialisation de la Cellule
% ----------------------------
token = cell(1,1);

% Decode le 1er �l�ment de la chaine de caract�re
% Celui-ci est renvoye dans la chaine de caracteres 'Str'
% tandis que le reste de la chaine est renvoye dans 'Remain'
% ----------------------------------------------------------
[str, remain] = strtok( string, DELIMITER);
    
% Boucle sur l'ensemble de la chaine jusqu'a ce que Str soit vide
% ---------------------------------------------------------------
nToken = 0;
while strcmp( str, '' ) ~= 1
      
  % Incremente le compteur d'elements lus
  % -------------------------------------
  nToken = nToken + 1;
  
  % Stocke les elements lus dans une Cellule
  % ----------------------------------------
  token(1, nToken) = cellstr(str);
  
  % Decode chaque element de la chaine de caractere
  % -----------------------------------------------
  [str, remain] = strtok( remain, DELIMITER);

end
    
% Enleve les caracteres blanc de debut et de fin de chaque element
% ----------------------------------------------------------------
token = strtrim(token);