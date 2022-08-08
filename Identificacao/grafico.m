function [] = grafico(DeltaT,G,MV,PV,string_modelo,n_figure)

t = (0:length(MV)-1)*DeltaT;

y_sim = lsim(G,MV,t);
figure(n_figure)
plot(t,PV), hold on
plot(t,y_sim), grid
title({'Resposta ao Degrau',string_modelo})
legend('Dados','Modelo','Location','SouthEast')
xlabel('Tempo (s)')
ylabel('Variação de Temperatura (ºC)')

end

