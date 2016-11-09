%%%%%% DEFINICAO DE FUNCOES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                               TREINAMENTO                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function W = TREINAMENTO(eletrodos)
    global nsess_trein;
    global valor_string;
    global sujeito;
    global Njanelas;
    
    H = [];
    vrotulos = [];

    % Treinar com 70% das sessoes definidas aleatoriamente
    for ss = 1:nsess_trein
 
        %%%%% PRE-PROCESSAMENTO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        indice_sess = num2str(valor_string(ss));
        dados_esq = CAR('left', sujeito, indice_sess);
        dados_dir = CAR('right', sujeito, indice_sess);

        eletr_esq = dados_esq(eletrodos, :);
        eletr_dir = dados_dir(eletrodos, :);


        %%%%% EXTRACAO DE CARACTERISTICAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Cria-se uma matriz de caracteristicas para cada uma das maos 
        Hesq = CARACT_MAO(eletr_esq, eletrodos);
        Hdir = CARACT_MAO(eletr_dir, eletrodos);

        % Concatena-se as duas matrizes da sessao
        Hsessao = vertcat(Hesq, Hdir);

        % Cria-se um vetor de rotulos de acordo com a mao que a linha representa
        % Conven磯: -1 para esquerda e +1 para direita
        vrotulos_sessao = ones(Njanelas * 2, 1);

        for k = 1:Njanelas
            vrotulos_sessao(k, 1) = vrotulos_sessao(k, 1) * -1;
        end

        
        % concatena-se Hsessao da sessao atual com a H final
        H = vertcat(H, Hsessao);                                               
        
        %concatena-se vrotulos_sessao da sessao atual com vrotulos final
        vrotulos = vertcat(vrotulos, vrotulos_sessao);

    end


    %%%%% CLASSIFICACAO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Calculo da matriz W usada na solucao otima
    W = pinv(H) * vrotulos 

    % Calculo da saida do Classificador
    y = H * W;


    EQM = mean((y - vrotulos).^2);
    Erro = (0.5 * sum(abs(sign(y) - vrotulos))) / length(y);

    % printf('EQM Trein = %d e NumSessoes Trein = %d\n', EQM, Erro);

end
