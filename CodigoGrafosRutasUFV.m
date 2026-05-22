clear; clc; close all;

%% =========================================================
%% MODELO UFV FINAL (INTERACTIVO + BIDIRECCIONAL)
%% =========================================================

wT = 0.4;
wI = 0.6;

%% =========================================================
%% BARRIOS (ENCUESTA)
%% =========================================================

barrios = {...
'Chamartin','LasRozas','Montecarmelo','Torrelodones',...
'Paracuellos','LasTablas','Salamanca','Alcorcon',...
'Leganes','Moncloa','Barajas','Pozuelo','Goya','Majadahonda','Alcobendas'};

n = length(barrios);

%% =========================================================
%% CONEXIONES BASE (SIN DUPLICADOS)
%% =========================================================

bb = {
'Salamanca','Goya',10,1
'Goya','Chamartin',15,2
'Chamartin','Moncloa',15,5
'LasRozas','Majadahonda',15,2
'Majadahonda','Pozuelo',15,2
'Alcorcon','Leganes',15,2
'LasTablas','Montecarmelo',10,1
'Montecarmelo','Chamartin',15,2
'Barajas','AvenidaAmerica',25,3
'Paracuellos','Barajas',15,2
'Torrelodones','LasRozas',15,2
};

%% =========================================================
%% GRAFO IDA
%% =========================================================

edges_ida = {

'Salamanca','Moncloa',20,3
'Salamanca','PlazaCastilla',15,2
'Chamartin','PlazaCastilla',10,2
'LasRozas','Moncloa',25,3
'Majadahonda','Moncloa',20,3
'Alcorcon','AvenidaAmerica',30,4
'Leganes','AvenidaAmerica',35,5
'Alcobendas','PlazaCastilla',25,4

% directos
'Pozuelo','UFV',20,2
'Majadahonda','UFV',20,2

% intercambiadores
'Moncloa','UFV',20,9
'PlazaCastilla','UFV',30,1
'AvenidaAmerica','UFV',35,5
};

E1 = [bb; edges_ida];

% HACER BIDIRECCIONAL
E1 = [E1; E1(:,[2 1 3 4])];

% Convertir a tabla para eliminar duplicados correctamente
E1_table = cell2table(E1, 'VariableNames', {'Origen','Destino','T','I'});
E1_table = unique(E1_table);
E1 = table2cell(E1_table);

[s,t,w] = deal({},{},[]);
for i=1:size(E1,1)
    s{i}=E1{i,1};
    t{i}=E1{i,2};
    T=E1{i,3};
    I=E1{i,4};
    w(i)=wT*T + wI*I;
end

G_ida = digraph(s,t,w);

%% =========================================================
%% GRAFO VUELTA
%% =========================================================

edges_vuelta = {

'UFV','Moncloa',30,7
'UFV','PlazaCastilla',35,6
'UFV','AvenidaAmerica',40,6

'UFV','Pozuelo',20,3
'UFV','Majadahonda',20,3

'Moncloa','Salamanca',20,3
'Moncloa','LasRozas',25,4
'PlazaCastilla','Chamartin',15,2
'PlazaCastilla','Alcobendas',25,4
'AvenidaAmerica','Alcorcon',30,4
'AvenidaAmerica','Leganes',35,5
};

E2 = [edges_vuelta; bb];

% BIDIRECCIONAL
E2 = [E2; E2(:,[2 1 3 4])];

% eliminar duplicados

E2_table = cell2table(E2, 'VariableNames', {'Origen','Destino','T','I'});
E2_table = unique(E2_table);
E2 = table2cell(E2_table);

[s,t,w] = deal({},{},[]);
for i=1:size(E2,1)
    s{i}=E2{i,1};
    t{i}=E2{i,2};
    T=E2{i,3};
    I=E2{i,4};
    w(i)=wT*T + wI*I;
end

G_vuelta = digraph(s,t,w);

%% =========================================================
%% MENÚ INTERACTIVO
%% =========================================================

disp('============================');
disp('SELECCIONA UN BARRIO');
disp('============================');

for i = 1:n
    fprintf('%d - %s\n', i, barrios{i});
end

opcion = input('Introduce el número: ');


%% =========================================================
%% CONTROL DE ERRORES
%% =========================================================

if ~isnumeric(opcion) || isempty(opcion) || opcion < 1 || opcion > n
    error('Error: número de barrio fuera de rango.');
end

barrio = barrios{opcion};

%% =========================================================
%% RUTAS ÓPTIMAS
%% =========================================================

[path_ida, cost_ida] = shortestpath(G_ida, barrio, 'UFV');
[path_vuelta, cost_vuelta] = shortestpath(G_vuelta, 'UFV', barrio);

%% =========================================================
%% COMPROBACIÓN
%% =========================================================

if isempty(path_ida)
    warning('No hay ruta de ida disponible.');
end

if isempty(path_vuelta)
    warning('No hay ruta de vuelta disponible.');
end

%% =========================================================
%% RESULTADOS
%% =========================================================

fprintf('\n============================\n');
fprintf('BARRIO SELECCIONADO: %s\n', barrio);

fprintf('\n IDA (casa -> UFV):\n');
disp(path_ida)
fprintf('Coste: %.2f\n', cost_ida);

fprintf('\n VUELTA (UFV -> casa):\n');
disp(path_vuelta)
fprintf('Coste: %.2f\n', cost_vuelta);

%% =========================================================
%% VISUALIZACIÓN
%% =========================================================

figure
p1 = plot(G_ida,'Layout','layered','EdgeLabel',round(G_ida.Edges.Weight,2));
title(['IDA desde ', barrio])
highlight(p1,path_ida,'EdgeColor','r','LineWidth',3)

figure
p2 = plot(G_vuelta,'Layout','layered','EdgeLabel',round(G_vuelta.Edges.Weight,2));
title(['VUELTA hacia ', barrio])
highlight(p2,path_vuelta,'EdgeColor','g','LineWidth',3)

fprintf('\nInterpretación:\n');
if cost_ida < cost_vuelta
    fprintf('El trayecto de ida es más eficiente que el de vuelta.\n');
else
    fprintf('El trayecto de vuelta presenta mayor eficiencia relativa.\n');
end
