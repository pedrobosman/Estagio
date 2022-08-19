clear; clc;
AmplitudeInicialAq = 20;
AmplitudeInicialRe = 30;
StepOptAq = stepDataOptions('StepAmplitude',10);
StepOptRe = stepDataOptions('StepAmplitude',-10);
DeltaT = 2;
%% Carregar Dados
Dados = load('Malha1.mat');
Malha1PV1 = Dados.pv1;
Malha1PV2 = Dados.pv2;
Malha1MV1 = Dados.mv1;
Malha1MV2 = Dados.mv2;

Dados = load('Malha2.mat');
Malha2PV1 = Dados.pv1;
Malha2PV2 = Dados.pv2;
Malha2MV1 = Dados.mv1;
Malha2MV2 = Dados.mv2;


%% Recuperar Instantes - Malha 1

%Malha 1 - Observar MV1
InicioDegrauAquecimento   = 471;%415;
FimDegrauAquecimento = 853;%703;

InicioDegrauResfriamento  = 854;%704;
FimDegrauResfriamento = 1205;%983;

MVAquecimento = Malha1MV1(InicioDegrauAquecimento:FimDegrauAquecimento)-AmplitudeInicialAq;
MVResfriamento = Malha1MV1(InicioDegrauResfriamento:FimDegrauResfriamento)-AmplitudeInicialRe;

PV1Aquecimento = Malha1PV1(InicioDegrauAquecimento:FimDegrauAquecimento);
PV1Aquecimento = PV1Aquecimento - PV1Aquecimento(1,1);

PV2Aquecimento = Malha1PV2(InicioDegrauAquecimento:FimDegrauAquecimento);
PV2Aquecimento = PV2Aquecimento - PV2Aquecimento(1,1);

PV1Resfriamento = Malha1PV1(InicioDegrauResfriamento:FimDegrauResfriamento);
PV1Resfriamento = PV1Resfriamento - PV1Resfriamento(1,1);

PV2Resfriamento = Malha1PV2(InicioDegrauResfriamento:FimDegrauResfriamento);
PV2Resfriamento = PV2Resfriamento - PV2Resfriamento(1,1);
%% Encontrar Plantas - Malha 1

%%Aquecimento da Malha - G(PV,MV)/ sub(Aquecimento)/desc(Resfriamento)
%G11 - Aquecimento
[G0, T1, L] = parametrosFOPTD(MVAquecimento,PV1Aquecimento,DeltaT);

G11sub = tf(G0,[T1 1]);
G11sub.outputd = L;
grafico(DeltaT,G11sub,MVAquecimento,PV1Aquecimento,'Modelo de Aquecimento - M1 (G11sub)',1);


G11parametros = [G0, T1, L];

%G11 - Resfriamento
[G0, T1, L] = parametrosFOPTD(MVResfriamento,PV1Resfriamento,DeltaT);

G11desc = tf(G0,[T1 1]);
G11desc.outputd = L;
grafico(DeltaT,G11desc,MVResfriamento,PV1Resfriamento,'Modelo de Resfriamento - M1(G11desc)',2);


G11parametros = (G11parametros + [G0, T1, L])/2;

%Planta Média G11
G11 = tf(G11parametros(1),[G11parametros(2) 1]);
G11.outputd = G11parametros(3);


%G21 - Aquecimento
[G0, T1, L] = parametrosFOPTD(MVAquecimento,PV2Aquecimento,DeltaT);

G21sub = tf(G0,[T1 1]);
G21sub.outputd = L;
grafico(DeltaT,G21sub,MVAquecimento,PV2Aquecimento,'Modelo de Aquecimento - M1(G21desc)',3);

G21parametros = [G0, T1, L];

%G21 - Resfriamento
[G0, T1, L] = parametrosFOPTD(MVResfriamento,PV2Resfriamento,DeltaT);

G21desc = tf(G0,[T1 1]);
G21desc.outputd = L;

grafico(DeltaT,G21desc,MVResfriamento,PV2Resfriamento,'Modelo de Aquecimento - M1(G21desc)',4);

%Planta Média G21
G21parametros = (G21parametros + [G0, T1, L])/2;
G21 = tf(G21parametros(1),[G21parametros(2) 1]);
G21.outputd = G21parametros(3);

%% %% Recuperar Instantes - Malha 2

%Malha 2 - Observar MV2
InicioDegrauAquecimento   = 423;
FimDegrauAquecimento = 785;

InicioDegrauResfriamento  = 786;
FimDegrauResfriamento = 1208;

MVAquecimento = Malha2MV2(InicioDegrauAquecimento:FimDegrauAquecimento)-AmplitudeInicialAq;
MVResfriamento = Malha2MV1(InicioDegrauResfriamento:FimDegrauResfriamento)-AmplitudeInicialRe;

PV1Aquecimento = Malha2PV1(InicioDegrauAquecimento:FimDegrauAquecimento);
PV1Aquecimento = PV1Aquecimento - PV1Aquecimento(1,1);

PV2Aquecimento = Malha2PV2(InicioDegrauAquecimento:FimDegrauAquecimento);
PV2Aquecimento = PV2Aquecimento - PV2Aquecimento(1,1);

PV1Resfriamento = Malha2PV1(InicioDegrauResfriamento:FimDegrauResfriamento);
PV1Resfriamento = PV1Resfriamento - PV1Resfriamento(1,1);

PV2Resfriamento = Malha2PV2(InicioDegrauResfriamento:FimDegrauResfriamento);
PV2Resfriamento = PV2Resfriamento - PV2Resfriamento(1,1);

%%  Encontrar Plantas - Malha 2 

%%Aquecimento da Malha - G(PV,MV)/ sub(Aquecimento)/desc(Resfriamento)
%G12 - Aquecimento
[G0, T1, L] = parametrosFOPTD(MVAquecimento,PV1Aquecimento,DeltaT);

G12sub = tf(G0,[T1 1]);
G12sub.outputd = L;
grafico(DeltaT,G12sub,MVAquecimento,PV1Aquecimento,'Modelo de Aquecimento - M1 (G12sub)',5);


G12parametros = [G0, T1, L];

%G12 - Resfriamento
[G0, T1, L] = parametrosFOPTD(MVResfriamento,PV1Resfriamento,DeltaT);

G12desc = tf(G0,[T1 1]);
G12desc.outputd = L;
grafico(DeltaT,G12desc,MVResfriamento,PV1Resfriamento,'Modelo de Resfriamento - M1(G12desc)',6);

%Planta Média G12
G12parametros = (G12parametros + [G0, T1, L])/2;
G12 = tf(G12parametros(1),[G12parametros(2) 1]);
G12.outputd = G12parametros(3);


%G22 - Aquecimento
[G0, T1, L] = parametrosFOPTD(MVAquecimento,PV2Aquecimento,DeltaT);

G22sub = tf(G0,[T1 1]);
G22sub.outputd = L;
grafico(DeltaT,G22sub,MVAquecimento,PV2Aquecimento,'Modelo de Aquecimento - M1(G22sub)',7);

G22parametros = [G0, T1, L];


%G22 - Resfriamento
[G0, T1, L] = parametrosFOPTD(MVResfriamento,PV2Resfriamento,DeltaT);

G22desc = tf(G0,[T1 1]);
G22desc.outputd = L;
grafico(DeltaT,G22desc,MVResfriamento,PV2Resfriamento,'Modelo de Resfriamento - M1(G22desc)',8);

%Planta Média G22
G22parametros = (G22parametros + [G0, T1, L])/2;
G22 = tf(G22parametros(1),[G22parametros(2) 1]);
G22.outputd = G22parametros(3);
%% Modelos Médios

G = [G11, G12;G21,G22] %#ok<NOPTS> 