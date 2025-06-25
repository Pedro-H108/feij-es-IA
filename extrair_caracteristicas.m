function T = extrair_caracteristicas(nome_arquivo_imagem)
    % Esta função extrai características de forma e cor dos feijões em uma imagem.

    % --- PRÉ-PROCESSAMENTO ---
    % 1. Leitura e conversão para escala de cinza
    img_rgb = imread(nome_arquivo_imagem);
    img_gray = rgb2gray(img_rgb);

    % 2. Binarização com método de Otsu
    limiar = graythresh(img_gray);
    img_bw = imbinarize(img_gray, limiar);

    % 3. Inversão e limpeza
    img_bw = ~img_bw; % Inverte a imagem (feijões = 1, fundo = 0)
    img_bw = bwareaopen(img_bw, 50); % Remove objetos com menos de 50 pixels (ruído)

    % --- EXTRAÇÃO DE CARACTERÍSTICAS DE FORMA ---
    % 4. Identificar objetos e medir propriedades de forma
    stats_forma = regionprops('table', img_bw, ...
        'Area', 'Perimeter', 'Solidity', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity');

    % Calcular características adicionais
    % Proporção (Aspect Ratio)
    stats_forma.AspectRatio = stats_forma.MajorAxisLength ./ stats_forma.MinorAxisLength;

    % Circularidade (calculada a partir da fórmula)
    stats_forma.Circularity = (4 * pi * stats_forma.Area) ./ (stats_forma.Perimeter.^2);

    % --- EXTRAÇÃO DE CARACTERÍSTICAS DE COR ---
    % 5. Medir propriedades de cor para cada feijão
    [labeledImage, numObjects] = bwlabel(img_bw); % Rotula cada feijão com um número
    
    % Inicializa vetores para as características de cor
    media_r = zeros(numObjects, 1);
    media_g = zeros(numObjects, 1);
    media_b = zeros(numObjects, 1);
    std_r = zeros(numObjects, 1);
    std_g = zeros(numObjects, 1);
    std_b = zeros(numObjects, 1);

    % Separa os canais de cor da imagem original
    R = img_rgb(:,:,1);
    G = img_rgb(:,:,2);
    B = img_rgb(:,:,3);

    for i = 1 : numObjects
        mascara_feijao = (labeledImage == i); % Cria uma máscara para o feijão atual
        
        % Extrai os pixels de cor para o feijão atual
        pixels_r = R(mascara_feijao);
        pixels_g = G(mascara_feijao);
        pixels_b = B(mascara_feijao);
        
        % Calcula a média e o desvio padrão
        media_r(i) = mean(pixels_r);
        media_g(i) = mean(pixels_g);
        media_b(i) = mean(pixels_b);
        std_r(i) = std(double(pixels_r));
        std_g(i) = std(double(pixels_g));
        std_b(i) = std(double(pixels_b));
    end

    % Junta as características de cor na tabela principal
    stats_forma.MeanR = media_r;
    stats_forma.MeanG = media_g;
    stats_forma.MeanB = media_b;
    stats_forma.StdR = std_r;
    stats_forma.StdG = std_g;
    stats_forma.StdB = std_b;

    T = stats_forma;
    
    % Visualização (opcional, para verificar se a segmentação funcionou)
    figure;
    imshow(img_rgb);
    hold on;
    contornos = bwboundaries(img_bw);
    for k = 1:length(contornos)
        boundary = contornos{k};
        plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
     end
     hold off;
end

