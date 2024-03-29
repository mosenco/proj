clc;
clear all;

table=readtable("erogato slovenia 1.xls");
%eliminazione valori negativi
%eliminazione valori nulli per MAPD che non funziona con zeri
table=table(table.erogato>0,:);

%deseasonalisation time series 
%table.erogato=trenddecomp(table.erogato);

table_1 = table(table.codice_pv==1,:);
table_2 = table(table.codice_pv==2,:);
table_3 = table(table.codice_pv==3,:);
table_4 = table(table.codice_pv==4,:);
table_5 = table(table.codice_pv==5,:);
table_6 = table(table.codice_pv==6,:);
table_7 = table(table.codice_pv==7,:);
table_8 = table(table.codice_pv==8,:);
table_9 = table(table.codice_pv==9,:);
table_10 = table(table.codice_pv==10,:);
table_11 = table(table.codice_pv==11,:);
table_12 = table(table.codice_pv==12,:);
table_6_10 = table(table.codice_pv==6 | table.codice_pv==7 | table.codice_pv==8 | table.codice_pv==9 | table.codice_pv==10,:);


%%
% media e varianza giornaliero

date = unique(table_6_10.data);
mean_t=[];
std_t=[];
for i=1:length(date)
    erogato_day = table_6_10(table_6_10.data==date(i) , 'erogato');
    mean_t = [mean_t mean(erogato_day.erogato)];
    std_t = [std_t std(erogato_day.erogato)];

end
%%
% media e varianza per giorni (lunedi martedi..)
% table 6-10 combinati perche senno valori troppo pochi
[daynums,daynames] = weekday(table_6_10.data,'long');
table_wnames = [table_6_10 array2table(daynums)];
mean_t_days=[];
std_t_days=[];
for i=1:7
    erogato_dayN = table_wnames(table_wnames.daynums==i , 'erogato');
    mean_t_days = [mean_t_days mean(erogato_dayN.erogato)];
    std_t_days = [std_t_days std(erogato_dayN.erogato)];

end
%%
% correlazione tra coppie di PV

PV=cell(1,5);
PV{1}=table_6;
PV{2}=table_7;
PV{3}=table_8;
PV{4}=table_9;
PV{5}=table_10;
correlazioneMatrix=[];

%intersezione tra le date, per avere le dati in comune
samedaytime = intersect(unique(PV{1}.data),unique(PV{2}.data));
samedaytime = intersect(samedaytime, unique(PV{3}.data));
samedaytime = intersect(samedaytime, unique(PV{4}.data));
samedaytime = intersect(samedaytime, unique(PV{5}.data));

table_6_fix = table_6(ismember(table_6.data,samedaytime),:);
table_7_fix = table_7(ismember(table_7.data,samedaytime),:);
table_8_fix = table_8(ismember(table_8.data,samedaytime),:);
table_9_fix = table_9(ismember(table_9.data,samedaytime),:);
table_10_fix = table_10(ismember(table_10.data,samedaytime),:);

%pero ho a volte per lo stesso giorno dati duplicati perche ognuno vende
%2 tipi di prodotti e certi per qualche giorno no. sommo il venduto dei
%giorni

table_6_sum = SumSameDateErogato(table_6_fix);
table_7_sum = SumSameDateErogato(table_7_fix);
table_8_sum = SumSameDateErogato(table_8_fix);
table_9_sum = SumSameDateErogato(table_9_fix);
table_10_sum = SumSameDateErogato(table_10_fix);


PV_sum=cell(1,5);
PV_sum{1}=table_6_sum;
PV_sum{2} = table_7_sum;
PV_sum{3} = table_8_sum;
PV_sum{4} = table_9_sum;
PV_sum{5} = table_10_sum;

for i = 1:length(PV_sum)-1
    for j = i:length(PV_sum)
        
        correlazioneMatrix=[correlazioneMatrix corrcoef(PV_sum{i},PV_sum{j})];
    end
end

%%
% linear regression sul venduto
regr=cell(1,6);
regr{1}=table_6;
regr{2}=table_7;
regr{3}=table_8;
regr{4}=table_9;
regr{5}=table_10;
regr{6}=table_6_10;

datanumeric=cell(1,6);
coeffs=cell(1,6);
slope_a=cell(1,6); %pendenza slope
intercept_b=cell(1,6); %ax+b=y
y_predict = cell(1,6);
for i=1:6
    datanumeric{i} = datenum(datestr(regr{i}.data),'dd-mm-yyyy');
    coeffs{i} = polyfit(datanumeric{i},regr{i}.erogato,1);
    slope_a{i} = coeffs{i}(1);
    intercept_b = coeffs{i}(2);
    y_predict{i} = polyval(coeffs{i},datanumeric{i});
    RegressionPlot(datanumeric{i},regr{i}.erogato,y_predict{i},getname(regr{i}));
end

%%
% MSE, MAPD, signal tracking control chart
%tecnica elementare
tables=cell(1,12);
tables{1}=table_1;
tables{2}=table_2;
tables{3}=table_3;
tables{4}=table_4;
tables{5}=table_5;
tables{6}=table_6;
tables{7}=table_7;
tables{8}=table_8;
tables{9}=table_9;
tables{10}=table_10;
tables{11}=table_11;
tables{12}=table_12;

tec_el_mse_raw = cell(1,12);
tec_el_mapd_raw = cell(1,12);
tec_el_mse=[];
tec_el_mapd=[];
for i=1:12
    for j=1:length(tables{i}.erogato)-1
        %mse e mapd tra due elementi alla volta
        tec_el_mse_raw{i} = [tec_el_mse_raw{i} mse(tables{i}.erogato(j),tables{i}.erogato(j+1))];
        tec_el_mapd_raw{i} = [tec_el_mapd_raw{i} mape(tables{i}.erogato(j),tables{i}.erogato(j+1))];

    end
    tec_el_mse = [tec_el_mse sum(tec_el_mse_raw{i})/length(tec_el_mse_raw{i})];
    tec_el_mapd = [ tec_el_mapd sum(tec_el_mapd_raw{i})/length(tec_el_mapd_raw{i})];
end



%%
%media mobile ordine 7
mm7 = cell(1,12);
mm7_mse_raw=cell(1,12);
mm7_mapd_raw=cell(1,12);
mm7_mse=[];
mm7_mapd=[];
for i=1:12
    mm7{i} = movmean(tables{i}.erogato,7);
    for j=1:length(mm7{i})
        mm7_mse_raw{i}=[mm7_mse_raw{i} mse(tables{i}.erogato(j),mm7{i}(j))];
        mm7_mapd_raw{i}=[mm7_mapd_raw{i} mape(tables{i}.erogato(j),mm7{i}(j))];
    end
    mm7_mse=[mm7_mse sum(mm7_mse_raw{i})/length(mm7_mse_raw{i})];
    mm7_mapd=[mm7_mapd sum(mm7_mapd_raw{i})/length(mm7_mapd_raw{i})];
end

%%
%media mobile di 4 lunedi fa per lunedi, e cosi per gli altri
%finestra lunga 22. 1-8-15-22 faccio la media e poi sposto
%il nuovo array e' lungo length(arrayorig)-length(slidingwindow)
%ma lultima settimana non si riesce a confrontare xk arraygenerato e' lungo
%1 settimana in piu
%si fa MSE a partire dal lunghezza sliding window 22 + 7, per andare
%prossima settimana
mm4 = cell(1,12);
mm4_mse_raw = cell(1,12);
mm4_mapd_raw = cell(1,12);
mm4_mse = [];
mm4_mapd = [];
for i=1:12
    %sliding window di lunghezza 22
    for j=1:length(tables{i}.erogato)-22
        mm4{i}=[mm4{i} sum([tables{i}.erogato(j) tables{i}.erogato(j+8) tables{i}.erogato(j+15) tables{i}.erogato(j+22)])/4];
        %primo lunedi calcolato corrisponde a 5 settimane in avanti da
        %array originale
        mm4_mse_raw{i}=[mm4_mse_raw{i} mse(tables{i}.erogato(j+22),mm4{i}(length(mm4{i})))];
        mm4_mapd_raw{i} = [mm4_mapd_raw{i} mape(tables{i}.erogato(j+22),mm4{i}(length(mm4{i})))];
    end
    mm4_mse = [mm4_mse sum(mm4_mse_raw{i})/length(mm4_mse_raw{i})];
    mm4_mapd = [mm4_mapd sum(mm4_mapd_raw{i})/length(mm4_mapd_raw{i})];
end
%%
%media esponenziale
mexp = cell(1,12);
mexp_mse_raw = cell(1,12);
mexp_mapd_raw = cell(1,12);
mexp_mse=[];
mexp_mapd=[];
alpha=[0:0.1:1]; %tutti possibili valori di alpha, faccio grids
alpha_opt=cell(1,12);

for i=1:12

    for a=1:length(alpha)
        
        %check if current alpha good, if yes deploy into mexp
        %primo elemento e'  uguale al originale, perhce non esiste il passo
        %precedente
        temp_mexp=tables{i}.erogato(1);
        temp_mse_raw=[];
        temp_mapd_raw=[];
        for j=2:length(tables{i}.erogato)
            temp_mexp=[temp_mexp temp_mexp(end)+alpha(a)*(tables{i}.erogato(j)-temp_mexp(end))];
            temp_mse_raw=[temp_mse_raw mse(tables{i}.erogato(j),temp_mexp(end-1))];
            temp_mapd_raw=[temp_mapd_raw mape(tables{i}.erogato(j),temp_mexp(end-1))];
            
        end
        temp_mse = sum(temp_mse_raw)/length(temp_mse_raw);
        temp_mapd = sum(temp_mapd_raw)/length(temp_mapd_raw);
        if a==1
            mexp_mse_raw{i} = temp_mse_raw;
            mexp_mse(i) = temp_mse;

            mexp_mapd_raw{i} = temp_mapd_raw;
            mexp_mapd(i) = temp_mapd;
            
            mexp{i}=temp_mexp;
            alpha_opt{i}=alpha(a);

        elseif temp_mse < mexp_mse(i)
            mexp_mse_raw{i} = temp_mse_raw;
            mexp_mse(i) = temp_mse;

            mexp_mapd_raw{i} = temp_mapd_raw;
            mexp_mapd(i) = temp_mapd;
            
            mexp{i}=temp_mexp;
            alpha_opt{i}=alpha(a);
        end
        disp(a+" / "+i);
        disp(temp_mse);
        disp(sum(temp_mse_raw)+" / ");
        disp(length(temp_mse_raw)+" / ");
        disp(length(temp_mexp)+" /" );
    end
    %per aggiungere spazio al array per il ciclo successivo
    if i<12
        mexp_mse=[mexp_mse 100];
        mexp_mapd=[mexp_mapd 100];
    end
end
%%
%regression 7
regr7_mse_raw=cell(1,12);
regr7_mapd_raw=cell(1,12);
regr7_mse=[];
regr7_mapd=[];
seven_y_predict=cell(1,12);
for i=1:12
    %sliding window of length 7
    seven_data = datenum(datestr(tables{i}.data),'dd-mm-yyyy');
    for j=1:length(tables{i}.erogato)-7
        seven_coeffs = polyfit(seven_data(j:j+6),tables{i}.erogato(j:j+6),1);
        seven_y_predict{i} = [seven_y_predict{i} polyval(seven_coeffs, j+7)];
        regr7_mse_raw{i} = [regr7_mse_raw{i} mse(tables{i}.erogato(j+7),seven_y_predict{i}(length(seven_y_predict{i})))];
        regr7_mapd_raw{i} = [regr7_mapd_raw{i} mape(tables{i}.erogato(j+7),seven_y_predict{i}(length(seven_y_predict{i})))];
    end
    regr7_mse = [regr7_mse sum(regr7_mse_raw{i})/length(regr7_mse_raw{i})];
    regr7_mapd = [regr7_mapd sum(regr7_mapd_raw{i})/length(regr7_mapd_raw{i})];
end

%%
% plot all data
for i=1:12
    PlotControlChart(tables{i},mm7{i}',mm4{i}',mexp{i}',seven_y_predict{i}',1,0.5);
    
end
PlotMSEMAPD(tec_el_mse,tec_el_mapd,mm7_mse,mm7_mapd,mm4_mse,mm4_mapd,mexp_mse,mexp_mapd,alpha_opt,regr7_mse,regr7_mapd)

%%
function PlotMSEMAPD(tec_el_mse,tec_el_mapd,mm7_mse,mm7_mapd,mm4_mse,mm4_mapd,mexp_mse,mexp_mapd,alpha_opt,regr7_mse,regr7_mapd)
    figure;

    subplot(5,1,1);
    bar(tec_el_mse);
    title('tecnica elementare MSE');
    
    subplot(5,1,2);
    bar(mm7_mse);
    title("media mobile 7 MSE");

    subplot(5,1,3);
    bar(mm4_mse);
    title("media mobile 4 MSE");

    subplot(5,1,4);
    bar(mexp_mse);
    title("media esponenziale alpha MSE");
    set(gca, 'XTickLabel', alpha_opt);

    subplot(5,1,5);
    bar(regr7_mse);
    title("regressione lineare MSE");

    figure;

    subplot(5,1,1);
    bar(tec_el_mapd);
    title('tecnica elementare MAPD');
    
    subplot(5,1,2);
    bar(mm7_mapd);
    title("media mobile 7 MAPD");

    subplot(5,1,3);
    bar(mm4_mapd);
    title("media mobile 4 MAPD");

    subplot(5,1,4);
    bar(mexp_mapd);
    title("media esponenziale alpha MAPD");
    set(gca, 'XTickLabel', alpha_opt);

    subplot(5,1,5);
    bar(regr7_mapd);
    title("regressione lineare MAPD");
end


function PlotControlChart(table,mm7,mm4,mexp,seven_y_predict,thic,thicc)
    figure;
    %hold on;
    
    %plot original data
    

    %plot tecnica elementare
    subplot(5, 1, 1);
    hold on;
    plot(1:length(table.erogato), table.erogato, 'b-', 'LineWidth', thic);
    plot(2:length(table.erogato), table.erogato(2:end), 'r--', 'LineWidth', thicc);
    hold off;
    title("tecnica elementare");

    %plot media mobile 7
    subplot(5, 1, 2);
    hold on;
    plot(1:length(table.erogato), table.erogato, 'b-', 'LineWidth', thic);
    plot(1:length(table.erogato), mm7, 'g--', 'LineWidth', thicc);
    hold off;
    title("media mobile 7");

    %plot media mobile 4 settimane
    subplot(5, 1, 3);
    hold on;
    plot(1:length(table.erogato), table.erogato, 'b-', 'LineWidth', thic);
    plot(29:length(table.erogato), mm4(1:end-6), 'm--', 'LineWidth', thicc);
    hold off;
    title("media mobile 4 weeks");

    %plot media esponenziale
    subplot(5, 1, 4);
    hold on;
    plot(1:length(table.erogato), table.erogato, 'b-', 'LineWidth', thic);
    plot(1:length(table.erogato), mexp(1:end), 'c--', 'LineWidth', thicc);
    hold off;
    title("media esponenziale");

    %plot linear regression 7
    subplot(5, 1, 5);
    hold on;
    plot(1:length(table.erogato), table.erogato, 'b-', 'LineWidth', thic);
    plot(8:length(table.erogato), seven_y_predict(1:end), 'm--', 'LineWidth', thicc);
    hold off;
    title("linear regression");
end

function result = SumSameDateErogato(table)
    result =[];
    currenterogato=table.erogato(1);
    currentdata=table.data(1);
    for i=2:length(table.erogato)
        
        if table.data(i) == currentdata
            currenterogato=currenterogato+table.erogato(i);
        else
            currentdata = table.data(i);
            result=[result currenterogato];
            currenterogato = table.erogato(i);
        end
    end

end


function name = getname(a)
    name = inputname(1);

end

function RegressionPlot(X,y,y_predict,name)

    figure;
    title(name);
    disp(name);
    scatter(X, y, 'o', 'DisplayName', 'Dati Originali');
    hold on;
    plot(X, y_predict, 'r-', 'DisplayName', 'Retta di Regressione');
    hold off;
    legend('show');
end

function result = mape(y_actual,y_predicted)

    result = mean(abs((y_actual - y_predicted)./y_actual));
end