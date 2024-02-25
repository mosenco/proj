clear all;
clc;

%% init

solver = optimproblem('ObjectiveSense','min');
%% sets

% 6 PV and 1 deposit
nodes = 7; 

days = 30;

%% parameters

%in term of kl
capacity_truck = 39; 

%in term of kl
capacity_PV = 50;

%starting capacity PV
capacity_PV0 = 50;

%demand for each PV range 3~7
%i,j i=day j=PV
demandHistory=[
5	3	5	4	6	6
6	7	7	7	4	7
7	4	7	4	3	4
6	6	6	4	7	4
7	7	6	7	6	4
3	5	7	5	7	7
4	7	5	4	7	6
5	3	3	3	5	7
3	3	4	3	7	6
4	7	5	4	5	6
3	3	5	7	7	5
6	6	7	6	3	5
4	7	3	6	3	7
6	3	4	7	6	7
5	5	3	5	4	4
4	4	4	6	4	3
6	6	6	5	6	5
3	4	4	7	3	5
5	7	4	5	4	3
7	3	3	7	3	7
4	7	4	3	6	7
5	7	7	7	5	5
7	3	4	4	3	4
4	3	6	3	5	6
7	5	7	3	5	6
3	3	5	5	6	5
7	7	6	7	4	3
4	7	7	4	3	6
7	6	4	6	5	7
7	4	6	3	6	3    
];

%length between two adjacent nodes
l1 = 100; %km
l2 = 200;
l3 = 300;
%adjacency matrix
adj_matrix = [
0 l1 l1 l1 l1 l1 l1
l1 0 l1 l2 l3 l2 l1
l1 l1 0 l1 l2 l3 l2
l1 l2 l1 0 l1 l2 l3
l1 l3 l2 l1 0 l1 l2
l1 l2 l3 l2 l1 0 l1
l1 l1 l2 l3 l2 l1 0
];


%% variables

% x_ijd use link i,j the day d 
x = optimvar('x',[nodes,nodes,days],...
              'Type','integer',...
              'LowerBound',0,'UpperBound',1);

%y_id I'm supplying PV i the day d 
y = optimvar('y',[nodes,days],...
              'Type','integer',...
              'LowerBound',0,'UpperBound',1);

%s_id inventory of PV i at day d (kl)
s = optimvar('s',[nodes,days],...
              'LowerBound',0);

%d_id quantity to deliver for PV i at day d (kl)
d = optimvar('d',[nodes,days],...
            'LowerBound',0);
%% objective

%voglio minimizzare l'utilizzo totale del costo di trasporto
solver.Objective = sum(sum(adj_matrix.*sum(x,3)));

%% constraints

%la somma di archi uscenti da source e' uguale alla somma di archi entranti
%a source, e deve essere uguale a 1. la parte che la somma e' uguale e'
%definita dal seocndo constraint. qui definisco solo che la somma e' uguale
%a 1
sourceNodeRule = optimconstr();
count=1;
for i = 1:days
    sourceNodeRule(count) = sum(x(1,:,i))==1;
    count=count+1;
    sourceNodeRule(count) = sum(x(:,1,i))==1;
    count=count+1;
end
solver.Constraints.cons1 = sourceNodeRule;

%la somma di archi entranti e' uguale a somma di archi uscenti per tutti i
%nodi
PVNodeRule = optimconstr();
count=1;
for i = 1:days
    for j = 1:nodes
        PVNodeRule(count) = sum(x(j,:,i))==sum(x(:,j,i));
        count=count+1;
    end
end
solver.Constraints.cons2 = PVNodeRule;

%non esiste un uso di link con i=j.
NoSameNodeRule = optimconstr();
count=1;
for i = 1:days
    for j = 1:nodes
        NoSameNodeRule(count) = sum(x(j,j,i))==0;
        count=count+1;
    end
end
solver.Constraints.cons3 = NoSameNodeRule;

%inizializzo inventario level
InventoryStart = optimconstr();
count=1;
for j = 2:nodes
    InventoryStart(count) = s(j,1)==capacity_PV0;
    count=count+1;
end
solver.Constraints.cons4 = InventoryStart;

%livello inventario aggiornato giornalmente da consegna o consumo, deve
%essere maggiore o uguale a zero. mai negativo. non per forza bisogna
%consegnare ogni giorno
InventoryNoNegative = optimconstr();
count=1;
for i = 1:days
    for j = 1:nodes
        InventoryNoNegative(count) = s(j,i)>=0.1;
        count=count+1;
    end
end
solver.Constraints.cons5 = InventoryNoNegative;
%COMMENTATO PERCHE GIA DEFINITO DA VARIABILE SOPRA

%inventario cambia giornalmente
InventoryDaily = optimconstr();
count=1;
for i = 2:days
    for j = 2:nodes
        InventoryDaily(count) = s(j,i)==s(j,i-1)-demandHistory(i-1,j-1)+d(j,i-1);
        count=count+1;
    end
end
solver.Constraints.cons6 = InventoryDaily;

%inventario max capacity
InventoryMax = optimconstr();
count=1;
for i = 1:days
    for j = 2:nodes
        InventoryMax(count) = s(j,i)<=capacity_PV;
        count=count+1;
    end
end
solver.Constraints.cons7 = InventoryMax;

%la somma della quantita' da delivery e' uguale o minore a capacity truck
DeliveryRule = optimconstr();
count=1;
for i = 1:days
    DeliveryRule(count) = sum(d(:,i)) <= capacity_truck;
    count=count+1;
end
solver.Constraints.cons8 = DeliveryRule;
    
%bisogna collegare d e y. se supply un PV allora devo consegnare qualcosa
DeliverySupplyLink = optimconstr();
count=1;
M=10000;
for i = 1:days
    for j = 1:nodes
        DeliverySupplyLink(count) = d(j,i) <= M*y(j,i);
        count=count+1;
    end
end
solver.Constraints.cons9 = DeliverySupplyLink;

%bisogna collegare x e y. uso un link solo se devo consegnare qualcosa
VerticesSupplyLink = optimconstr();
count=1;
M=10000;
for i = 1:days
    for start = 1:nodes
        for target = 1:nodes
            VerticesSupplyLink(count) = x(start,target,i) <= M*y(target,i);
            count=count+1;
        end
    end
end
solver.Constraints.cons10 = VerticesSupplyLink;


%% solve

options = optimoptions('intlinprog', 'IntegerTolerance', 1e-6,'MaxTime', 60*5);
[sol, cost]=solve(solver, 'options', options);

PVmp = [50 50 50 50 50 50];

for i = 1:30
    currentPV=zeros(1,6);
    for j=1:length(PVmp(1,:))
        currentPV(j) = PVmp(length(PVmp(:,1)),j)-demandHistory(i,j)+sol.d(j+1,i);
    end
    PVmp = [PVmp ; currentPV];
end

figure
%plot the results
[num_righe, num_colonne] = size(PVmp);

% Genera un grafico per ogni colonna
for colonna = 1:num_colonne
    plot(1:num_righe, PVmp(:, colonna));  % Esegui il plot della colonna corrente
    hold on;  % Mantieni il grafico attuale per sovrapporre il prossimo
end

title("Andamento livello inventario in 30 giorni");
xlabel('Giorni');
ylabel('Livello Inventario');
legend('PV 1', 'PV 2', 'PV 3', 'PV 4', 'PV 5', 'PV6');  % Personalizza le etichette delle colonne
hold off;  % Rilascia il "hold on" per evitare sovrapposizioni involontarie in futuro