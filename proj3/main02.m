clc;
clear all;

days = 30; 
numPV = 6;
capacityPV = 50;
capacityTruck = 39;
demandMin = 3;
demandMax = 7;

%demandHistory = randi([demandMin, demandMax], days, numPV);
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


]
% maximum level policy

% As tested, i serve 1 PV per day, delivering all 39 i can, till the max is
% reached or all my 39 in the truck. 

% the cost is 200 per day

PV1 = [50 50 50 50 50 50];
deliveries1=[];
orders1=39; % 
idxPV1=1; %indice per dire di aggiungere inventario solo un PV alla volta
for i=1:30
    currentPV=zeros(1,6);
    
    for j=1:length(PV1(1,:))
        
        if j==idxPV1
            currentPV(idxPV1)=PV1(length(PV1(:,1)),idxPV1)-demandHistory(i,j)+orders1;
            deliv = orders1;
            if currentPV(idxPV1) > 50
                deliv = orders1-(currentPV(idxPV1)-50);
                currentPV(idxPV1) = 50;
            end
            deliveries1=[deliveries1 deliv];
            newidxPV=rem(idxPV1,6)+1;
        else
            currentPV(j)=PV1(length(PV1(:,1)),j)-demandHistory(i,j);
        end
    end
    idxPV1=newidxPV;
    PV1=[PV1 ;currentPV];

end


PlotDisplay(PV1,"manual");


% valutiamo il routing first andando a vedere

% la colonna indica quante PV sto sommando. se 2, sto facendo la somma
% della domanda di 2 PV.

% la singola riga indica quanti giorni son passati, tale per cui, facendo
% somma giorno per giorno, si e' arrivati a 39 = truck capacity
countdemand = zeros(length(demandHistory(:,1)),length(demandHistory(1,:)));

for i = 1:length(demandHistory(1,:)) % colonna
    idxCol=1;
    for j = 1:length(demandHistory(:,1)) % riga
        sumRow = 0;
        for k=1:i
            sumRow = sumRow + demandHistory(j,k);
        end
       
        countdemand(idxCol,i)=countdemand(idxCol,i)+sumRow;
        if countdemand(idxCol,i) >= 39
            % siccome voglio fare consegne e max ho 39 nel truck, questo
            % check fa in modo che se supero 39, tolgo l'ultima somma e la
            % metto nel ordine successivo
            countdemand(idxCol,i)=countdemand(idxCol,i)-sumRow;
         
            idxCol=idxCol+1;
            countdemand(idxCol,i)=countdemand(idxCol,i)+sumRow;
           

        end
    end
    
end
%cluster giornaliero? allora siccome spesa meno di 39 allora ho un unico
%cluster. voglio diminuire le spese? allora dovrei fare mmeno viaggi
%possibili. allora arrivo a fare un cluster da 1 come rpima lol

%sum of all demand is 868/39 = 22.2564. I need 23 deliveries in total.
%but in reality i start with already 50 units in each PV so in reality
%50*6=300 units are already satisfied so 868-300=568/39=14.5641
%so i just need 15 deliveries in total to satisfy the demand in 30 days.
%each PV needs in mean 568/6=94,6. So 94,6/39=2,427 trips for one PV.

%ci sono 0,427 di materiale sprecato. faccio cluster da 2 cosi
%94.6*2=189.2/39=4.8513, devo fare 5 trips dove 1-0.8513=0.1487 non
%consegnato a viaggio. 

%pero nel caso che devo consegnare tutto a un PV alla volta, siccome ogni
%PV ha una spesa di 94.6, devo fare 3 viaggi per un singolo PV. Percio
%3*6=18 viaggi in totale dove ognuno costa 200 percio 18*200 = 3600

%se invece li raggruppo in cluster di 2, devo soddisfare la domanda di
%189.2 e con lautobotte ho bisogno di 5 viaggi. 5*3=15 viaggi in totale. Un
%singolo viaggio costa 300. percio 15*300=4500

%alla fine e' sempre piu economico consegnare in cluster da 1. ma questo
%solo se consegno 39 alla volta. Ma se la loro capacity e' 50, dovrei
%aspettare che l'inventario scende a 20 unita', ma siccome tutti hanno
%domanda uguale, l'ultimo PV dovra aspettare 5 giorni prima che riceva il
%suo ordine e in media i PV hanno consumo di 5*5giorni=25 unita' consumate
%e andra' in stockout.

%percio meglio cluster da 2 cosi si aspetta quando l'inventario consuma 20
%unita e avranno 30 unita ancora in magazzino. e l'ultimo cluster deve
%aspettare solo 2 giorni.

PV_h = [50 50 50 50 50 50];
deliveries_h=[];
deliver_times=0; %stop when i reach 15
clusters=[1 2 ; 3 4 ; 5 6]; %sono gli indici dei PV
idx_c = 1; %indice che tiene conto di quale clusters deve prendere
listener_c=false; %listener che fa triggerare la sequenza di rifornimenti
orders_h=19.5; %39/2  
limit_deliver_times=ceil((sum([sum(demandHistory)])-300)/39);
threshold=30;
for i=1:30
    currentPV=zeros(1,6);
    
    for j=1:length(PV_h(1,:))
        % consumo giornaliero in base a demandhistory
        currentPV(j)=PV_h(length(PV_h(:,1)),j)-demandHistory(i,j);
    end

    % se la differenza supera una soglia allora in sequenza di giorni
    % consegna il primo giorno un cluster, il secondo giorno il secondo
    % cluster etc. 
    if 50-currentPV(1) >=threshold || 50-currentPV(2) >=threshold 
        
        currentPV(clusters(1,1))=currentPV(clusters(1,1))+orders_h;
        currentPV(clusters(1,2))=currentPV(clusters(1,2))+orders_h;
        
        deliv_1=orders_h;
        deliv_2=orders_h;
        
        if currentPV(clusters(1,1)) > 50
            deliv_1 = orders_h - (currentPV(clusters(1,1)) - 50);
            currentPV(clusters(1,1))=50;
        end

        if currentPV(clusters(1,2)) > 50
            deliv_2 = orders_h - (currentPV(clusters(1,2)) - 50);
            currentPV(clusters(1,2))=50;
        end
        deliv=deliv_1+deliv_2;
        deliveries_h=[deliveries_h deliv];
        deliver_times=deliver_times+1;
    

    elseif 50-currentPV(3) >=threshold || 50-currentPV(4) >=threshold 
        
        currentPV(clusters(2,1))=currentPV(clusters(2,1))+orders_h;
        currentPV(clusters(2,2))=currentPV(clusters(2,2))+orders_h;
        
        deliv_1=orders_h;
        deliv_2=orders_h;
        
        if currentPV(clusters(2,1)) > 50
            deliv_1 = orders_h - (currentPV(clusters(2,1)) - 50);
            currentPV(clusters(2,1))=50;
        end

        if currentPV(clusters(2,2)) > 50
            deliv_2 = orders_h - (currentPV(clusters(2,2)) - 50);
            currentPV(clusters(2,2))=50;
        end
        deliv=deliv_1+deliv_2;
        deliveries_h=[deliveries_h deliv];
        deliver_times=deliver_times+1;
    

    elseif 50-currentPV(5) >=threshold || 50-currentPV(6) >=threshold 
        
        currentPV(clusters(3,1))=currentPV(clusters(3,1))+orders_h;
        currentPV(clusters(3,2))=currentPV(clusters(3,2))+orders_h;
        
        deliv_1=orders_h;
        deliv_2=orders_h;
        
        if currentPV(clusters(3,1)) > 50
            deliv_1 = orders_h - (currentPV(clusters(3,1)) - 50);
            currentPV(clusters(3,1))=50;
        end

        if currentPV(clusters(3,2)) > 50
            deliv_2 = orders_h - (currentPV(clusters(3,2)) - 50);
            currentPV(clusters(3,2))=50;
        end
        deliv=deliv_1+deliv_2;
        deliveries_h=[deliveries_h deliv];
        deliver_times=deliver_times+1;
    end


   
    
    PV_h=[PV_h ;currentPV];

end

PlotDisplay(PV_h,"cluster");
%%

function [] = PlotDisplay(PV,name)
    figure
    %plot the results
    [num_righe, num_colonne] = size(PV);
    
    % Genera un grafico per ogni colonna
    for colonna = 1:num_colonne
        plot(1:num_righe, PV(:, colonna));  % Esegui il plot della colonna corrente
        hold on;  % Mantieni il grafico attuale per sovrapporre il prossimo
    end

    title("Andamento livello inventario in 30 giorni "+name);
    xlabel('Giorni');
    ylabel('Livello Inventario');
    legend('PV 1', 'PV 2', 'PV 3', 'PV 4', 'PV 5', 'PV6');  % Personalizza le etichette delle colonne
    hold off;  % Rilascia il "hold on" per evitare sovrapposizioni involontarie in futuro

end


function [] = PlotDisplayTogether(PV)
    figure
    %plot the results
    [num_righe, num_colonne, num_dim] = size(PV);
    
    % Genera un grafico per ogni colonna
    for idx = 1:num_dim
        plot(1:num_righe, PV(:, 1, idx));  % Esegui il plot della colonna corrente
        hold on;  % Mantieni il grafico attuale per sovrapporre il prossimo
    end

    title("Andamento livello inventario in 30 giorni solo 1PV");
    xlabel('Giorni');
    ylabel('Livello Inventario');
    legend('dataset1','dataset2','dataset3','dataset4');  % Personalizza le etichette delle colonne
    hold off;  % Rilascia il "hold on" per evitare sovrapposizioni involontarie in futuro

end
%%
function name = getname(a)
    name = inputname(1);

end
