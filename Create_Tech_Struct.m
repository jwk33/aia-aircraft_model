clear all; %clear functions;

time=[2023,2030,2035,2040,2050,2060];         % time frames into consideration
grad=[1.145 1.380 1.850];            % gradients of the 3 buckets: conventional, evolutionary and revolutionary respectively %A gradient of 1%/y yields an emissions reduction of 1.1%/year
split=[0.5 0.3 0.2];           % efficiency improvement from engine, aero and weight respectively
split_eta = [0.4 0.6];         % overall efficiency improvement from thermal and propulsive respectively

for i=1:length(time)
A(i,:)=(1-grad/100).^(time(i)-time(1));
end

EpRPK=1.161; %Long Haul
%EpRPK=0.828;   %Medium Haul
f = {};

EpRPK_t=EpRPK*A;
f.eta_ov=A.^split(1);
f.LoD=A.^split(2);
f.MZF=A.^split(3);

disp(A(1))
hold on
plot(time, A(:,1))
plot(time, A(:,2))
plot(time, A(:,3))
ylim([0.5,1])
xlim([2023,2060])
legend({'Best Case (1.25%)', 'Average Case (1.0%)','Worst Case (0.75%)'})

%%
tech_factor = {};
tech_factor.E = dictionary(); % energy trajectory
tech_factor.LoD = dictionary();
tech_factor.MZF = dictionary();
tech_factor.eta_ov = dictionary();
tech_factor.eta_th = dictionary();
tech_factor.eta_prop = dictionary();


optimism = ["BAU","Intermediate","Advanced"];
for i=1:height(A) % row number
    for j =1:width(A) %col number
        year_iter = time(i);
        optimism_iter = optimism(j);
        key = string(year_iter) + "-" + optimism_iter;
        tech_factor.E(key) = A(i,j);
        tech_factor.LoD(key) = f.LoD(i,j);
        tech_factor.MZF(key) = f.MZF(i,j);
        tech_factor.eta_ov(key) = f.eta_ov(i,j);
        tech_factor.eta_th(key) = f.eta_ov(i,j).^split_eta(1);
        tech_factor.eta_prop(key) = f.eta_ov(i,j).^split_eta(2);
    end
end

%% save
save ("Factor.mat", "f")
save("Trajectory.mat","A")
save("Tech_Factor.mat","tech_factor")


%% error check - ensure the product of all factors equal to the target change

 A_new = f.eta_ov .* f.LoD .* f.MZF;
 err = A_new - A;





