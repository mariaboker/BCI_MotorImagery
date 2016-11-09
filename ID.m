%%%%%% DEFINIǃO DE FUNǕES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                      CONVENǃO DE NOMES ELETRODOS                       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cria um vetor com o nome dos eletrodos seguindo a ordenacao e convencao de indices
function eletr_ID = ID(eletr_indice)
	
	eletr_ID = [];		% vetor que guardarᠯs nomes (ID) dos eletrodos

	for k = 1:length(eletr_indice)

		switch eletr_indice(k)
			case 1
				eletr_ID = [eletr_ID, {'FC3'}];
			case 2
				eletr_ID = [eletr_ID, {'FC4'}];
			case 3
				eletr_ID = [eletr_ID, {'Fz'}];
			case 4
				eletr_ID = [eletr_ID, {'POz'}];
			case 5
				eletr_ID = [eletr_ID, {'Pz'}];
			case 6
				eletr_ID = [eletr_ID, {'C4'}];
			case 7
				eletr_ID = [eletr_ID, {'C3'}];
			case 8
				eletr_ID = [eletr_ID, {'CP4'}];
			case 9
				eletr_ID = [eletr_ID, {'CP3'}];
			case 10
				eletr_ID = [eletr_ID, {'C6'}];
			case 11
				eletr_ID = [eletr_ID, {'C5'}];
			case 12
				eletr_ID = [eletr_ID, {'Cz'}];
			case 13
				eletr_ID = [eletr_ID, {'C1'}];
			case 14
				eletr_ID = [eletr_ID, {'C2'}];
			case 15
				eletr_ID = [eletr_ID, {'CPz'}];
			case 16
				eletr_ID = [eletr_ID, {'FCz'}];
			otherwise
				eletr_ID = [eletr_ID, {'Nao identificado'}];
		end

end
