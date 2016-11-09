%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
%   Interface Cérebro Máquina Baseada em Imaginação do Movimento         %
%                                                                        %
%   Maria Bolina Kersanach, RA 156571                                    %
%   Engenharia de Computação FEEC UNICAMP                                %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clear all

close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                               TREINAMENTO                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% PRE-PROCESSAMENTO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Aquisicao e aplicacao do CAR - mao esquerda

load motorImagery_lefthand_training_subject_MariaIM_session_14             % para cada sessao de 8s:
sessao_esq = storageDataAcquirement';                                      % 2048 amostras para cada um dos 16 eletrodos (16x2048)

num_eletr_orig = size(sessao_esq, 1);                                      % numero original de eletrodos disponiveis (padrao = 16)

ref_CAR_esq = mean(sessao_esq);                                            % vetor com as medias de cada coluna (1x2048)
matriz_ref_CAR_esq = ones(num_eletr_orig, 1) * ref_CAR_esq;                % matriz referencia para CAR (16x2048)

dados_esq = sessao_esq - matriz_ref_CAR_esq;                               % matriz resultante da aplicação do CAR em todos eletrodos = dados - media (16x2048)


for pp = 1:size(dados_esq, 1)                                              % normalizacao dos dados
    
    %dados_esq(pp,:) = dados_esq(pp,:) - mean(dados_esq(pp,:));
    %dados_esq(pp,:) = dados_esq(pp,:)/std(dados_esq(pp,:));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Aquisicao e aplicacao do CAR - mao direita
                                                                           
load motorImagery_righthand_training_subject_MariaIM_session_14             % analogo a mao esquerda
sessao_dir = storageDataAcquirement';

ref_CAR_dir = mean(sessao_dir);
matriz_ref_CAR_dir = ones(num_eletr_orig, 1) * ref_CAR_dir;

dados_dir = sessao_dir - matriz_ref_CAR_dir;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Escolha de eletrodos a serem utilizados

eletr_uteis = [2 5 6 9];                                                    % vetor com a ID dos eletrodos uteis (no caso C3 e C4 escolhidos empiricamente)

eletr_esq = dados_esq(eletr_uteis, :);                                      % matriz com todas as amostras somente dos eletrodos escolhidos
eletr_dir = dados_dir(eletr_uteis, :);



%%%%% Definição de parametros %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Famost = 256;                                                              % frequencia de amostragem do sinal

Tjanela = 3;                                                               % duracao de cada janela (s)
TDesloc = 0.5;                                                             % tempo de deslocamento entre as janelas (s)

Njanelas = ((8 - Tjanela)/TDesloc) + 1;                                    % numero de janelas para 1 sessao (ex. padrao = 11)



%%%%% EXTRACAO DE CARACTERISTICAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Criacao da matriz de dados para treinamento do classificador
                                                                           % Cria-se uma matriz para cada uma das maos e depois concatena-se verticalmente as duas

% Cada linha da matriz possui o conjunto de atributos janela atual
% Cada elemento da linha é um atributo e cada conjunto de 3 elementos relaciona-se com um eletrodo

% para a mao esquerda
for j = 1:Njanelas                                                         % da primeira ate a ultima janela
    
    atributos = [];                                                        % cria um vetor de atributos para cada janela
    
    for e = 1:length(eletr_uteis)                                          % para cada um dos eletrodos, cria-se um elemento do vetor de atributos da janela atual
        
        inicio = 1 + (j - 1) * Famost * TDesloc;                           % indice da primeira amostra da janela
        fim = inicio + Famost * Tjanela-1;                                 % indice da ultima amostra da janela
        
        janela = eletr_esq(e,inicio:fim);                                  % vetor com as amostras selecionadas formando a janela com (Famost * Tjanela) elementos
        
        [Pxx,F] = pwelch(janela, [], [], [1:20], 256);                     % aplicacao do metodo de P Welch na janela atual
        atributos_welch = [sum(Pxx(8:12)), sum(Pxx(13:16)), sum(Pxx(17:20))]; % cada atributo eh a soma das potencias de cada uma das bandas escolhidas
                                                                              % no caso usamos as bandas de 8 a 12 Hz, de 13 a 16 Hz e de 17 a 20 Hz
        
        atributos = [atributos, atributos_welch];                          % concatenacao dos atributos do PWelch do eletrodo atual com os dos outros eletrodos da janela atual
    end
    
     Hesq(j,:) = [atributos, 1];                                           % acrescenta-se um vetor coluna de valor '1' na ultima coluna da matriz                              
end

% para a mao direita
for j = 1:Njanelas                                                         % analogo ao da mao esquerda
    
    atributos = [];                                                       
    
    for e = 1:length(eletr_uteis)                                          
        
        inicio = 1 + (j - 1) * Famost * TDesloc;                       
        fim = inicio + Famost * Tjanela-1;                            
        
        janela = eletr_dir(e,inicio:fim);   
        
        [Pxx,F] = pwelch(janela, [], [], [1:20], 256);              
        atributos_welch = [sum(Pxx(8:12)), sum(Pxx(13:16)), sum(Pxx(17:20))]; 
        
        atributos = [atributos, atributos_welch];                        
    end
    
     Hdir(j,:) = [atributos, 1];                                                                                                             
end


H = vertcat(Hesq, Hdir);                                                   % funcao matlab para concatenar verticalmente matrizes


%%% Criacao do vetor coluna de rotulos (resposta esperada do o classificador)
% por convencao, +1: mao direita e -1: mao esquerda

numlinhas = Njanelas * 2;
vrotulos = ones(numlinhas, 1);

for k = 1:Njanelas
    
    vrotulos(k, 1) = vrotulos(k, 1) * -1;                                  % define como referentes a mao esquerda (valor -1) a primeira metade dos rotulos
end

%%% Calculo da matriz W usada na solucao otima
W = pinv(H) * vrotulos;                                                    % A matriz W é a resultante da multiplicacao entre a pseudo-inversa de H e o vetor de rotulos

%%% Calculo da saida do classificador
y = H * W;                                                                 % y matriz de saida (22 x 1)

EQM_trein = mean((y-vrotulos).^2)

Taxa_erro_trein = (0.5*sum(abs(sign(y)-vrotulos)))/22




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                                 TESTE                                   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%% PRE-PROCESSAMENTO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Aquisicao e aplicacao do CAR - mao esquerda

load motorImagery_lefthand_training_subject_MariaIM_session_20        
sessao_esq = storageDataAcquirement';                          

num_eletr_orig = size(sessao_esq, 1);                       

ref_CAR_esq = mean(sessao_esq);                                         
matriz_ref_CAR_esq = ones(num_eletr_orig, 1) * ref_CAR_esq;

dados_esq = sessao_esq - matriz_ref_CAR_esq;


for pp = 1:size(dados_esq, 1)                                              
    
    %dados_esq(pp,:) = dados_esq(pp,:) - mean(dados_esq(pp,:));
    %dados_esq(pp,:) = dados_esq(pp,:)/std(dados_esq(pp,:));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Aquisicao e aplicacao do CAR - mao direita
                                                                           
load motorImagery_righthand_training_subject_MariaIM_session_20          
sessao_dir = storageDataAcquirement';

ref_CAR_dir = mean(sessao_dir);
matriz_ref_CAR_dir = ones(num_eletr_orig, 1) * ref_CAR_dir;

dados_dir = sessao_dir - matriz_ref_CAR_dir;

for pp = 1:size(dados_dir, 1)
    
    %dados_dir(pp,:) = dados_dir(pp,:) - mean(dados_dir(pp,:));
    %dados_dir(pp,:) = dados_dir(pp,:)/std(dados_dir(pp,:));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Escolha de eletrodos a serem utilizados

eletr_esq = dados_esq(eletr_uteis, :);                              
eletr_dir = dados_dir(eletr_uteis, :);


%%%%% EXTRACAO DE CARACTERISTICAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Criacao da matriz de dados para treinamento do classificador
                                                                          
% para a mao esquerda
for j = 1:Njanelas                                                       
    
    atributos = [];                                                      
    
    for e = 1:length(eletr_uteis)                                          
        
        inicio = 1 + (j - 1) * Famost * TDesloc;                          
        fim = inicio + Famost * Tjanela-1;                                
        
        janela = eletr_esq(e,inicio:fim);                                    
        
        [Pxx,F] = pwelch(janela, [], [], [1:20], 256);                    
        atributos_welch = [sum(Pxx(8:12)), sum(Pxx(13:16)), sum(Pxx(17:20))]; 
        
        atributos = [atributos, atributos_welch];                          
    end
    
     Hesq_teste(j,:) = [atributos, 1];                                                            
end

% para a mao direita
for j = 1:Njanelas                                                        
    
    atributos = [];                                                       
    
    for e = 1:length(eletr_uteis)                                          
        
        inicio = 1 + (j - 1) * Famost * TDesloc;                       
        fim = inicio + Famost * Tjanela-1;                            
        
        janela = eletr_dir(e,inicio:fim);         
        
        [Pxx,F] = pwelch(janela, [], [], [1:20], 256);              
        atributos_welch = [sum(Pxx(8:12)), sum(Pxx(13:16)), sum(Pxx(17:20))]; 
        
        atributos = [atributos, atributos_welch];                        
    end
    
     Hdir_teste(j,:) = [atributos, 1];                                                                                                             
end


H_teste = vertcat(Hesq_teste, Hdir_teste);                                 % funcao matlab para concatenar verticalmente matrizes

y_teste = H_teste * W


EQM_trein_teste = mean((y_teste - vrotulos).^2)

Taxa_erro_trein_teste = (0.5 * sum(abs(sign(y_teste)-vrotulos)))/22
        
