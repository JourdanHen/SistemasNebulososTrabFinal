% Ler dados dos clientes a partir do arquivo CSV
dadosClientes = readmatrix('clientes.csv');

% Algoritmo Fuzzy C-Means
function [PAs, cliente_PA, capacidadePA] = fuzzyCMeansClientes(dadosClientes, maxNumPAs, maxDistancia, maxCapacidadePA, gridResolution)
    % Dados dos clientes
    xClientes = dadosClientes(:, 1);
    yClientes = dadosClientes(:, 2);
    bandaClientes = dadosClientes(:, 3);
    
    melhorFitness = inf;
    melhorPAs = [];
    melhorCliente_PA = [];
    melhorCapacidadePA = [];
    
    % Iterar sobre o número de PAs possíveis
    for k = 1:maxNumPAs
        [centros, U] = fcm([xClientes, yClientes], k);
        centrosQuantizados = round(centros / gridResolution) * gridResolution;
        
        cliente_PA = zeros(length(xClientes), 1);
        capacidadePA = zeros(k, 1);
        distanciaPA = zeros(k, 1);
        
        % Atribuição de clientes aos PAs
        for i = 1:length(xClientes)
            % Calcular distâncias de todos os PAs
            distancias = sqrt((centrosQuantizados(:, 1) - xClientes(i)).^2 + (centrosQuantizados(:, 2) - yClientes(i)).^2);
            % Ordenar PAs por distância
            [distanciasOrdenadas, PAIndices] = sort(distancias);
            
            % Tentar atribuir cliente ao PA mais próximo possível
            for j = 1:length(PAIndices)
                PAIndex = PAIndices(j);
                if distanciasOrdenadas(j) <= maxDistancia && capacidadePA(PAIndex) + bandaClientes(i) <= maxCapacidadePA
                    cliente_PA(i) = PAIndex;
                    capacidadePA(PAIndex) = capacidadePA(PAIndex) + bandaClientes(i);
                    distanciaPA(PAIndex) = distanciasOrdenadas(j);
                    break;
                end
            end
        end
        
        % Avaliação da solução
        if sum(cliente_PA > 0) == length(xClientes)
            fitness = sum(capacidadePA) + sum(distanciaPA) + sum(bandaClientes);
            if fitness < melhorFitness
                melhorFitness = fitness;
                melhorPAs = centrosQuantizados;
                melhorCliente_PA = cliente_PA;
                melhorCapacidadePA = capacidadePA;
            end
        end
    end
    
    PAs = melhorPAs;
    cliente_PA = melhorCliente_PA;
    capacidadePA = melhorCapacidadePA;
end

% Parâmetros
maxNumPAs = 30;
maxDistancia = 85;
maxCapacidadePA = 54;
gridResolution = 5;

% Chamar a função fuzzyCMeansClientes com dados dos clientes e parâmetros
[PAs, cliente_PA, capacidadePA] = fuzzyCMeansClientes(dadosClientes, maxNumPAs, maxDistancia, maxCapacidadePA, gridResolution);

% Visualizar a distribuição dos clientes 
figure;
scatter(dadosClientes(:, 1), dadosClientes(:, 2), 'bo');
hold on;
title('Distribuição dos Clientes');
xlabel('Posição X');
ylabel('Posição Y');
legend('Clientes');
grid on;
axis([0 400 0 400]);
xticks(0:400:400);
yticks(0:400:400);
grid minor;

% Visualizar a distribuição dos clientes e pontos de acesso
figure;
scatter(dadosClientes(:, 1), dadosClientes(:, 2), 'bo');
hold on;
scatter(PAs(:,1), PAs(:,2), 'rx', 'LineWidth', 2);
title('Distribuição dos Clientes e Pontos de Acesso');
xlabel('Posição X');
ylabel('Posição Y');
legend('Clientes', 'Pontos de Acesso');
grid on;
axis([0 400 0 400]);
xticks(0:gridResolution:400);
yticks(0:gridResolution:400);
grid minor;

% Visualizar os grupos e seus pontos de acesso
figure;
hold on;
colors = lines(maxNumPAs);
for i = 1:maxNumPAs
    if any(cliente_PA == i)
        scatter(dadosClientes(cliente_PA == i, 1), dadosClientes(cliente_PA == i, 2), 36, colors(i,:), 'filled');
        scatter(PAs(i, 1), PAs(i, 2), 100, colors(i,:), 'x', 'LineWidth', 2);
    end
end
title('Grupos de Clientes e Pontos de Acesso');
xlabel('Posição X');
ylabel('Posição Y');
legend('Clientes', 'Pontos de Acesso');
grid on;
axis([0 400 0 400]);
xticks(0:400:400);
yticks(0:400:400);
grid minor;

% Visualizar os grupos e seus pontos de acesso com círculos de raio 85 metros
figure;
hold on;
colors = lines(maxNumPAs);
for i = 1:maxNumPAs
    if any(cliente_PA == i)
        scatter(dadosClientes(cliente_PA == i, 1), dadosClientes(cliente_PA == i, 2), 36, colors(i,:), 'filled');
        scatter(PAs(i, 1), PAs(i, 2), 100, colors(i,:), 'x', 'LineWidth', 2);
        % Adicionar círculos de raio 85 metros
        rectangle('Position', [PAs(i, 1)-85, PAs(i, 2)-85, 170, 170], ...
                  'Curvature', [1, 1], 'EdgeColor', colors(i,:), 'LineStyle', '--');
    end
end
title('Grupos de Clientes e Pontos de Acesso');
xlabel('Posição X');
ylabel('Posição Y');
legend('Clientes', 'Pontos de Acesso');
grid on;
axis([0 400 0 400]);
xticks(0:400:400);
yticks(0:400:400);
grid minor;

% Salvar as coordenadas dos pontos de acesso encontrados
fileID = fopen('MelhorSolucao.txt', 'w');
for i = 1:size(PAs, 1)
    porcentagemUso = (capacidadePA(i) / maxCapacidadePA) * 100;
    fprintf(fileID, '%d,%d,%.1f%%\n', PAs(i, 1), PAs(i, 2), porcentagemUso);
end
fclose(fileID);

disp('Arquivo MelhorSolucao.txt gerado com sucesso!');
