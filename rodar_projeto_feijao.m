% --- ETAPA C: GERAR CONJUNTO DE PADRÕES ---
clc; clear; close all;

% Extrai características dos feijões BONS (classe 1)
tabela_bons = extrair_caracteristicas('C:\Users\pedro\Documents\codes\projetoIA\feijaobom.jpg'); % Use o nome da sua imagem de feijões bons
tabela_bons.Classe = ones(height(tabela_bons), 1); % Adiciona a coluna da classe (1 = bom)

% Extrai características dos feijões RUINS (classe 0)
% Nota: Tudo na imagem 'feijaoruim.jpg' será considerado "não-bom" (ruim, quebrado, etc.)
tabela_ruins = extrair_caracteristicas('C:\Users\pedro\Documents\codes\projetoIA\feijaoruim.jpg');
tabela_ruins.Classe = zeros(height(tabela_ruins), 1); % Adiciona a coluna da classe (0 = ruim)

% Combina as duas tabelas em um único conjunto de dados
T_final = [tabela_bons; tabela_ruins];

% Salva o conjunto de padrões em um arquivo de texto/csv
writetable(T_final, 'padrões_feijao.csv');

disp('Conjunto de padrões "padrões_feijao.csv" foi gerado com sucesso.');
disp(['Total de feijões bons extraídos: ', num2str(height(tabela_bons))]);
disp(['Total de feijões ruins extraídos: ', num2str(height(tabela_ruins))]);

% --- ETAPA D: TREINAMENTO DO MODELO ---

% Prepara os dados para o treinamento
preditores = T_final(:, 1:end-1); % Todas as colunas, exceto a última
resposta = T_final.Classe;       % A última coluna (Classe)

% Treina o modelo classificador (Random Forest)
% 'Bag' é o método para Random Forest
disp('Treinando o modelo Random Forest...');
modelo_rf = fitcensemble(preditores, resposta, 'Method', 'Bag');
disp('Modelo treinado.');


% --- ETAPA E: AVALIAÇÃO DO MODELO ---

% Realiza a validação cruzada (10-fold cross-validation)
disp('Realizando validação cruzada...');
modelo_cv = crossval(modelo_rf, 'KFold', 10);

% Calcula a acurácia
acuracia = 1 - kfoldLoss(modelo_cv, 'LossFun', 'ClassifError');
fprintf('Acurácia do modelo (validação cruzada): %.2f%%\n', acuracia * 100);

% Para obter uma Matriz de Confusão, precisamos de predições
% Vamos prever as classes para os dados de validação cruzada
predicoes = kfoldPredict(modelo_cv);

% Gera e exibe a Matriz de Confusão
disp('Matriz de Confusão:');
figure;
C = confusionmat(T_final.Classe, predicoes);
confusionchart(T_final.Classe, predicoes, ...
    'Title', 'Matriz de Confusão para Seleção de Feijões', ...
    'RowSummary', 'row-normalized', ...
    'ColumnSummary', 'column-normalized');

% Calculando Precisão e Revocação para a classe "BOM" (classe 1)
% VP = C(2,2), FP = C(1,2), FN = C(2,1)
precisao = C(2,2) / (C(2,2) + C(1,2));
revocacao = C(2,2) / (C(2,2) + C(2,1));
f1_score = 2 * (precisao * revocacao) / (precisao + revocacao);

fprintf('Precisão (para feijões bons): %.2f%%\n', precisao * 100);
fprintf('Revocação (para feijões bons): %.2f%%\n', revocacao * 100);
fprintf('F1-Score: %.4f\n', f1_score);
