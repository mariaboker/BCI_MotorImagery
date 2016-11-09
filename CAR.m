%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                                 CAR                                     %
%  Funcao aplica o filtro CAR e retorna a matriz 'dados' normalizada      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dados = CAR(lado, suj, IDsessao)
    global num_eletr_orig;
    
    %%%%% Abertura do arquivo com os dados coletados %%%%%%%%%%%%%%%%%%%%%%%%

    arquivo = ['motorImagery_', lado, 'hand_training_subject_', suj, 'IM_session_', IDsessao];
    load (arquivo)

    sessao = storageDataAcquirement';
    %sessao = rawData';

    %global num_eletr_orig;
    %num_eletr_orig = size(sessao, 1)

    ref_CAR = mean(sessao);
    matriz_ref_CAR = ones(num_eletr_orig, 1) * ref_CAR;
    
    dados = sessao - matriz_ref_CAR;
    
    % normaliza磯
    %for k = 1:size(dados, 1)
    %    dados (k, :) = dados(k, :) - mean(dados(k, :));
    %   dados(k, :) = dados(k, :) / std(dados(k, :));
    %end
    
end
