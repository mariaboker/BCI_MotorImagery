%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                                 WRAPPER                                 %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [eletrselec, erros] = WRAPPERS(a)
    global num_eletr_orig;
    global Famostr;
    global Tjanela;
    global TDesloc;
    global Njanelas;
    
	eletr_analisar = [1:num_eletr_orig]; 	% Conjunto de eletrodos a serem ordenados pelo Wrapper

	Wrapper.eletr = []; 					% Vetor com eletrodos ordenados de acordo com a selecao do Wrapper
	Wrapper.erro = []; 						% Vetor ordenado com valores dos erros obtidos com a combinacao dos eletrodos Wrapper

	% Parametros de cada iteracao
	eletr_atuais = [];


	while size(eletr_analisar) > 0
    
      melhor.erro = 4200; 					% menor erro da partida
	    melhor.eletr = 0; 						% atual melhor eletrodo (menor erro de teste)
      melhor.EQM = 4200;            % guarda o melhor erro EQM

        
		for k = 1:length(eletr_analisar)
       		disp('Eletrodos restantes:')
       		eletr_analisar
       
		      eletr_atuais = [Wrapper.eletr, eletr_analisar(k)] 		% subconjunto dos eletr ja selecionados & o atual
			
			% roda treinamento e teste com os eletrodos estudados
			W_atual = TREINAMENTO(eletr_atuais); 
		    [erro_atual, EQM_atual] = TESTE(eletr_atuais, W_atual);

		    if erro_atual < melhor.erro
		    	melhor.eletr = eletr_analisar(k);
		    	melhor.erro = erro_atual;
		    	melhor.EQM = EQM_atual;

		    elseif erro_atual == melhor.erro				% desempata pelo EQM caso tenham o mesmo numero de acerto nas sessoes
              disp('erros de sessao iguais, compara EQM');
		    	if EQM_atual < melhor.EQM
		    		melhor.eletr = eletr_analisar(k);
		    		melhor.erro = erro_atual;
		    		melhor.EQM = EQM_atual;
				end
			end

			eletr_atuais = [Wrapper.eletr];				% volta ao conjunto da partida
		end

		% tendo passado por todos e escolhido o melhor
		indice_exc = find(eletr_analisar == melhor.eletr)
        
        eletr_analisar(indice_exc) = [];								% da certo para todos os valores de indice

		Wrapper.eletr = [Wrapper.eletr, melhor.eletr] 				% adiciona ele na lista ordenada
		Wrapper.erro = [Wrapper.erro, melhor.erro]						% adiciona o erro relativo a ele na lista ordenada de erros
		eletrselec = Wrapper.eletr;		
		erros = Wrapper.erro;			

		disp('Eletrodo Escolhido pelo Wrapper:');
        escolhido = ID(melhor.eletr)

    end
   
    
    figure(3)
    plot(erros,'o')
    xlabel('Iteracao')
    ylabel('Taxa de Erro')
    grid
end
