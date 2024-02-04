clear all;
clc;
% visito i punti vendita giornalmente
% autobotte capacity=39. 39/6 = 6,5 a punto vendita
% lato esagono 100 => al giorno costo 700
% punti vendita inventory iniziale = capacity
PV = [50 50 50 50 50 50];
consumption=7; % worst case
orders6=6.5; % 39/6. perform 6 visit each day
for i=1:30
    currentPV=zeros(1,6);
    for j=1:length(PV(1,:))

        currentPV(j)=PV(length(PV(:,1)),j)-consumption+orders6;

    end
    PV=[PV ;currentPV];

end



% visito i punti vendita divisi in 2 gruppi => 3 PV al giorno
% autobotte capacity=39. 39/3 = 13 a punto vendita
% lato esagono 100 => al giorno costo 400
% punti vendita inventory iniziale = capacity
PV3 = [50 50 50 50 50 50];
orders3=13; % 39/3. perform 3 visit each day
for i=1:30
    currentPV=zeros(1,6);
    for j=1:length(PV3(1,:))
        
        if rem(i,2) == 0 & rem(j,2) == 0
            currentPV(j)=PV3(length(PV3(:,1)),j)-consumption+orders3;
        elseif rem(i,2) ~= 0 & rem(j,2) ~= 0
            currentPV(j)=PV3(length(PV3(:,1)),j)-consumption+orders3;
        else
            currentPV(j)=PV3(length(PV3(:,1)),j)-consumption;
        end

    end
    PV3=[PV3 ;currentPV];

end


% visito i punti vendita divisi in 3 gruppi => 2 PV al giorno
% autobotte capacity=39. 39/2 = 19,5 a punto vendita
% lato esagono 100 => al giorno costo 300
% punti vendita inventory iniziale = capacity
PV2 = [50 50 50 50 50 50];
orders2=19.5; % 39/2. perform 2 visit each day
idxPV2=1;
for i=1:30
    currentPV=zeros(1,6);
    
    for j=1:length(PV2(1,:))
        
        if j==idxPV2 || j==idxPV2+1
            currentPV(idxPV2)=PV2(length(PV2(:,1)),idxPV2)-consumption+orders2;
            currentPV(idxPV2+1)=PV2(length(PV2(:,1)),idxPV2+1)-consumption+orders2;
            newidxPV=rem(idxPV2+1,6)+1
        else
            currentPV(j)=PV2(length(PV2(:,1)),j)-consumption;
        end


    end
      
    idxPV2=newidxPV;
    PV2=[PV2 ;currentPV];

end



% visito i punti vendita divisi in 6 gruppi => 1 PV al giorno
% autobotte capacity=39. 39/1 = 39 a punto vendita
% lato esagono 100 => al giorno costo 200
% punti vendita inventory iniziale = capacity
PV1 = [50 50 50 50 50 50];
orders1=39; % 39/1. perform 1 visit each day
idxPV1=1;
for i=1:30
    currentPV=zeros(1,6);
    
    for j=1:length(PV1(1,:))
        
        if j==idxPV1
            currentPV(idxPV1)=PV1(length(PV1(:,1)),idxPV1)-consumption+orders1;
            newidxPV=rem(idxPV1,6)+1
        else
            currentPV(j)=PV1(length(PV1(:,1)),j)-consumption;
        end
    end
    idxPV1=newidxPV;
    PV1=[PV1 ;currentPV];

end

name=getname(PV);
PlotDisplay(PV,name);
name=getname(PV1);
PlotDisplay(PV1,name);
name=getname(PV2);
PlotDisplay(PV2,name);
name=getname(PV3);
PlotDisplay(PV3,name);

allPV = PV;
allPV(:,:,2)=PV1;
allPV(:,:,3)=PV2;
allPV(:,:,4)=PV3;
PlotDisplayTogether(allPV);

%%
clear all;
clc;
% heuristic route first cluster second
% we already have a route if we suppose all nodes are connected to the
% nearest
% this heuristic cluster the nodes after the sum of the demand is equal or
% lower than the capacity of the vehicle
PV = [50 50 50 50 50 50];
consumption=7; % worst case

%the cluster is made by PVs where the sum of demand, in our case 7, is
%equal or lower than the capacity of the truck in our case 7*5 =35 < 39. So
%we generate two cluster one by 5 and the rest by 1. Later we can try to
%generate daily a cluster of new 5, so because we have 6 PV, the new
%cluster will have always 4 old and 1 new

ordercl1 = 7.8; %39/5
ordercl2 = 39;

for i=1:30
    currentPV=zeros(1,6);
    
    for j=1:length(PV(1,:))
        %{
        if rem(i,2) == 0 && j==6
            currentPV(6)=PV(length(PV(:,1)),6)-consumption+ordercl2;
            
        elseif rem(i,2) == 0 && j~=6
            currentPV(j)=PV(length(PV(:,1)),j)-consumption;
            
        elseif rem(i,2) == 1 && j==6
            currentPV(6)=PV(length(PV(:,1)),6)-consumption;
        elseif rem(i,2) == 1 && j~=6
            currentPV(j)=PV(length(PV(:,1)),j)-consumption+ordercl1;
        else
            disp("error");
        end
        %}

        if 50-PV(length(PV(:,1)),6) >= 39 
           
            if j==6
                currentPV(6)=PV(length(PV(:,1)),6)-consumption+ordercl2;
         
            else
                currentPV(j)=PV(length(PV(:,1)),j)-consumption;
            end
            
        else
            if j~=6
                currentPV(j)=PV(length(PV(:,1)),j)-consumption+ordercl1;
            else
                currentPV(6)=PV(length(PV(:,1)),6)-consumption;
            end
        end

    end
  
    PV=[PV ;currentPV];
  
end

%lets try to cluster daily. so we will always have daily a cluster of 5
%made by 4 old and 1 new
PVcl = [50 50 50 50 50 50];
ordercl=7.8;
idxcl=1; %indice del PV che in quel giorno non ricevera il rifornimento 
for i=1:30
    currentPV=zeros(1,6);
    
    for j=1:length(PVcl(1,:))
        
        if j ~= idxcl
            currentPV(j)=PVcl(length(PVcl(:,1)),j)-consumption+ordercl;
        else

            currentPV(j)=PVcl(length(PVcl(:,1)),j)-consumption;

        end
    end
    idxcl=rem(idxcl,6)+1;
    PVcl=[PVcl ;currentPV];

end

PlotDisplay(PV,"fixed");
PlotDisplay(PVcl,"rotating");
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