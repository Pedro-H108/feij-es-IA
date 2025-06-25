% --- ETAPA C: GERAR CONJUNTO DE PADRÕES ---
clc; clear; close all;

% Extrai características dos feijões BONS (classe 1)
tabela_bons = extrair_caracteristicas('C:\Users\Administrador\Downloads\feijaobom.jpg'); % Use o nome da sua imagem de feijões bons
tabela_bons.Classe = ones(height(tabela_bons), 1); % Adiciona a coluna da classe (1 = bom)

% Extrai características dos feijões RUINS (classe 0)
% Nota: Tudo na imagem 'feijaoruim.jpg' será considerado "não-bom" (ruim, quebrado, etc.)
tabela_ruins = extrair_caracteristicas('C:\Users\Administrador\Downloads\feijaoruim.jpg');
tabela_ruins.Classe = zeros(height(tabela_ruins), 1); % Adiciona a coluna da classe (0 = ruim)

% Combina as duas tabelas em um único conjunto de dados
T_final = [tabela_bons; tabela_ruins];

% Salva o conjunto de padrões em um arquivo de texto/csv
writetable(T_final, 'padrões_feijao.csv');

disp('Conjunto de padrões "padrões_feijao.csv" foi gerado com sucesso.');
disp(['Total de feijões bons extraídos: ', num2str(height(tabela_bons))]);
disp(['Total de feijões ruins extraídos: ', num2str(height(tabela_ruins))]);

