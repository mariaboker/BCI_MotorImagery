%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                                 TESTE                                   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% obs tipo_erro deve ser EQM para obter quadratico medio, e qualquer outra coisa para o numero de sessoes
function [ErroSess, EQM] = TESTE(eletrodos, W)
    global nsess_trein;
    global nsess_total;
    global valor_string;
    global sujeito;
    global Njanelas;
    
    H_teste = [];
    vrotulos_teste = [];

    % Testar com as sessoes que nao foram usadas no treinamento
    for ss = (nsess_trein + 1):nsess_total

        %%%%% PRE-PROCESSAMENTO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        indice_sess = num2str(valor_string(ss));
        dados_esq = CAR('left', sujeito, indice_sess);
        dados_dir = CAR('right', sujeito, indice_sess);

        eletr_esq = dados_esq(eletrodos, :);
        eletr_dir = dados_dir(eletrodos, :);


        %%%%% EXTRACAO DE CARACTERISTICAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Cria-se uma matriz de caracteristicas para cada uma das maos 
        Hesq_teste = CARACT_MAO(eletr_esq, eletrodos);
        Hdir_teste = CARACT_MAO(eletr_dir, eletrodos);

        % Concatena-se as duas matrizes da sessao
        Hsessao_teste = vertcat(Hesq_teste, Hdir_teste);
        
        % Cria-se um vetor de rotulos de acordo com a mao que a linha representa
        % Convencao: -1 para esquerda e +1 para direita
        vrotulos_sessao_teste = ones(Njanelas * 2, 1);

        for k = 1:Njanelas
            vrotulos_sessao_teste(k, 1) = vrotulos_sessao_teste(k, 1) * -1;
        end
        
        % concatena-se Hsessao da sessao atual com a H final
        H_teste = vertcat(H_teste, Hsessao_teste);
        
        %concatena-se vrotulos_sessao da sessao atual com vrotulos final
        vrotulos_teste = vertcat(vrotulos_teste, vrotulos_sessao_teste);

    end

    y_teste = H_teste * W;


    EQM = mean((y_teste - vrotulos_teste).^2);
    %disp('EQM Teste = %d\n', Erro);

    ErroSess = (0.5 * sum(abs(sign(y_teste) - vrotulos_teste))) / length(y_teste)
    %disp('Num de Sessoes Teste = %d\n', Erro);

end
