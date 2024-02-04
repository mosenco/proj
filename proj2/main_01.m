clear all;
clc;
%%
% data of the problem
n=4; %num of station
a=[4 5 3 2 ; 2 10 1 4]; % time taken at each station
t=[0 7 4 5 ; 0 9 2 8]; % time taken to switch lines

e1=10; % time taken to enter first line
e2=12; % time taken to enter second line
x1=18; % time taken to exit first line
x2=7; % time taken to exit second line

x = BruteMode(a,t,0,1,x1,x2,n)+e1+a(1,1);
y = BruteMode(a,t,1,1,x1,x2,n)+e2+a(2,1);

resultBrute=min(x,y);

e = [10 12];
x = [18 7];

resultDP = DpMode(a,t,e,x);
resultDPOPT = DpModeOPT(a,t,e,x);

% new configuration
% more assembly line
% change line only by adiacent one
aa=[4 5 3 2 ; 
    2 10 1 4;
    1 2 3 4;
     4 3 2 1]; % time taken at each station
tt=[0 7 4 5 ; 
    0 9 2 8;
    0 1 2 3;
    0 3 2 1]; % time taken to switch lines

ee = [10 12 1 4];
xx = [18 7 1 30];
[resultDPALL,pathDPALL,idxLine] = DPAllType(aa,tt,ee,xx);
%%
function cost = BruteMode(a,t,cl,cs,x1,x2,n)
    % if we are at the end, compute the exit time cost
    if cs == n
        if cl == 0
            cost = x1;
            return;
        else
            cost = x2;
            return;
        end
    end
    
    % it computes the cost of the current station + the next one

    % continue on same line
    same = BruteMode(a,t,cl,cs+1,x1,x2,n)+a(cl+1,cs+1);

    %continue on different  line
    diff = BruteMode(a,t,~cl,cs+1,x1,x2,n)+a(~cl+1,cs+1)+t(cl+1,cs+1);
    
    cost = min(same,diff);
    return;
end

%%
function cost = DpMode(a,t,e,x)
    num_station=length(a(1,:));
    T1=zeros(1,num_station);
    T2=zeros(1,num_station);

    % cost at beginning
    % entry cost and first station cost
    T1(1) = e(1)+a(1,1);
    T2(1) = e(2)+a(2,1);

    for i=2:num_station
        T1(i) = min(T1(i-1)+a(1,i) , T2(i-1)+t(2,i)+a(1,i));
        T2(i) = min(T2(i-1)+a(2,i) , T1(i-1)+t(1,i)+a(2,i));
        
    end

    cost = min(T1(num_station)+x(1),T2(num_station)+x(2));
    return;
end

%%
function cost = DpModeOPT(a,t,e,x)
    n = length(a(1,:));
    
    first = e(1)+a(1,1);
    second = e(2)+a(2,1);
    path1=["a"];
    path2=["b"];
  
    for i=2:n
        %utilizza up e down xk le variabili first e second servono per la
        %seconda riga pure
        [up,idx1] = min([first+a(1,i) second+t(2,i)+a(1,i)]);
        [down,idx2] = min([second+a(2,i) first+t(1,i)+a(2,i)]);
        if idx1==1
            newpath1=[path1 "a"]
        else
            newpath1=[path2 "a"]
        end

        if idx2==1
            
            newpath2=[path2 "b"]
        else
            newpath2=[path1 "b"]
        end
        
        path1 = newpath1
        path2 = newpath2
       
        first = up;
        second = down;
     
    end

    first=first+x(1);
    second=second+x(2);
 
    cost = min(first,second);

    return;
end

%%
function [cost,paths,line] = DPAllType(a,t,e,x)

    n = length(a(1,:));
    
    %definisco l'array che tiene conto delle variabili dei costi
    cost=[];

    %inizializzo costo entrata e costo di primo station
    %aggiungo pure costo finale.. tanto viene aggiunto alla fine ed e'
    %uguale

    %inizializzo il path dove ogni path corrisponde col suo indice
    paths=zeros(1,length(e));
    for i=1:length(e)
        cost=[cost e(i)+a(i,1)];
        paths(i)=[i];
    end
    
    
    %definisco i costi dei nodi intermedi
    for i=2:n
        currCost=zeros(1,length(cost));
        currPath=zeros(length(paths(:,1))+1,length(cost));
        for j=1:length(cost)
            if j==1
                [currCost(j),idx1] = min([cost(j)+a(j,i) cost(j+1)+t(j+1,i)+a(j,i)]);
                 if idx1==1
                    currPath(:,j) = [paths(:,j) ; j];
                else
                    currPath(:,j) = [paths(:,j+1) ; j];
                end
            elseif j==length(cost)
                [currCost(j),idx2] = min([cost(j)+a(j,i) cost(j-1)+t(j-1,i)+a(j,i)]);
                if idx2==1
                    currPath(:,j) = [paths(:,j) ; j];
                else
                    currPath(:,j) = [paths(:,j-1) ; j];
                end
            else
                [currCost(j),idx3] = min([cost(j)+a(j,i) cost(j+1)+t(j+1,i)+a(j,i) cost(j-1)+t(j-1,i)+a(j,i)]);
                if idx3==1
                    currPath(:,j) = [paths(:,j) ; j];
                elseif idx3==2
                    currPath(:,j) = [paths(:,j+1) ; j];
                else
                    currPath(:,j) = [paths(:,j-1) ; j];
                end
            end
            
           

        
        end
        paths = currPath;
        cost=currCost;
     
    end


    for i=1:length(e)
        cost(i)=cost(i)+x(i);
    end
   
    [cost,line] = min(cost);
    return;
end

