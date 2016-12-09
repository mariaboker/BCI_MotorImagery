%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
%   CLONALG aplicado a Imaginacao do Movimento BCI                       %
%                                                                        %
%   Maria B Kersanach, RA 156571                                         %
%   Romis R F Attux DCA FEEC UNICAMP                                     %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clear all;

close all;


%% parametros da interface
numAtrib = 20;   % 20 atributos a serem selecionados = 16 eletrodos + 4 bandas
tamPop = 20;     % tamanho da populacao
numCopias = 10;  % numero de copias que sofrerao mutacao para disputar o local na populacao

probMut = 0.6;   % prob de acontecer a mutação

numIt = 100; % numero de vezes que acontecera o refinamento dos individuos por mutacao
numSubst = 0,3 * tamPop; % numero de individuos a serem substituidos por novos aleatorios
numItTotal = 300; % numero de iteracoes gerais


% garantir que tamPop é par
if mod(tamPop,2) > 0
    tamPop = tamPop + 1;
end

% Gera populacao inicial de pais (vetores binarios aleatorios)
populacao = randi([0 1], tamPop, numAtrib); % matriz populacao com atributos 0s e 1s 


for itTotal = 1:numItTotal
	for it = 1:numIt

		fitness = []; % inicializa o vetor de fitness da populacao zerado

		for atual = 1:tamPop

			for k = 1:numCopias % cria uma matriz com copias do individuo
				amostragem(k, :) = populacao(atual, :);
			end

			%% MUTACAO
			mascMut = rand(numCopias-1, numAtrib); 	% cria matriz aleatoria com probabilidades de cada atributo sofrer mutacao

			% percorre a matriz procurando posicoes onde ocorrera mutacao
			for k = 1:(numCopias-1) % mantem o ultimo como o original
				for kk = 1:numAtrib
					if mascMut(k, kk) <= probMut 	% ocorre mutacao
						amostragem(k, kk) = 1 - amostragem(k, kk); % realiza a MUTACAO
					end
				end
		    end

			% retorna o maior fitness e o indice onde ele se encontra no vetor gerado pela funcao fit nos individuos da amostragem
			[maior_fit, indice_maior] = max(fit(amostragem), [], 2);

			populacao(atual,:) = amostragem(indice_maior); % substitui o individuo original pelo que teve maior fitness
			fitness = [fitness, maior_fit]; % guarda os melhores fitness de cada iteração

		end

		maiores_fit = max(fitness); % guarda o melhor fitness de cada iteração na populacao inteira
	end

	[fitness,indices] = sortrows(fitness); 	% ordena os fitness da populacao
	populacao = populacao(indices,:);       % reordena a matriz populacao em ordem crescente de fitness

	% substitui os "numSubst" individuos com menores fitness por novos aleatorios
	populacao(1,:) = randi([0 1], numSubst, numAtrib); % matriz populacao com atributos 0s e 1s   VERIFICAR SE É ASSIM !!!!!!!!!!!!
end
