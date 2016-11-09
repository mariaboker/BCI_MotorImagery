%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                MATRIZ PARCIAL DE TREINAMENTO (pwelch)                   %
%      Criacao da matriz de dados para treinamento do classificador       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function H_mao = CARACT_MAO(dados_mao, eletrodos)
    global Njanelas;
    global Famostr;
    global Tjanela;
    global TDesloc;

    for j = 1:Njanelas
        
        atributos = [];

        for e = 1:length(eletrodos)
            
            inicio = 1 + (j - 1) * Famostr * TDesloc;
            fim = inicio + Famostr * Tjanela - 1;
            
            janela = dados_mao(e, inicio:fim);
            
            [Pxx,F] = pwelch(janela, [], [], [1:20], 256);
            atributos_welch = [sum(Pxx(8:12)), sum(Pxx(13:16)), sum(Pxx(17:20))];
            
            atributos = [atributos, atributos_welch];
        end

        H_mao(j, :) = [atributos, 1];
    end
end
