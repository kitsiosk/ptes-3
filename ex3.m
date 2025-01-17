%%% Advanced Signal Proccessing Techniques - Exercise 3 - 2020
%%% Author: Kitsios Konstantinos 9182
%%% Validation of Giannakis' formula

N = 2048;
q = 5;
b = [1 0.93 0.85 0.72 0.59 -0.1];
rng(0)
v = exprnd(1, [1 N]);
x = zeros(1, N);

for i=1:N
    for j=1:q+1
        if i-j >= 1
            x(i) = x(i) + b(j)*v(i-j);
        end
    end
end

muX = mean(x);
stdX = std(x);
muV = mean(v);
stdV = std(v);

%% 1. Estimage skewness
gamma3V = sum((v-muV).^3)/((N-1)*stdV^3);
fprintf("Skewness value is: %f which is different than zero so we deduce that V[k] is not Gaussian\n", gamma3V);

%% 2. 3rd order cumulant
L3 = 20;    % number of lags

% window=0 uses the parzen window
figure(1)
[~, ~, cum, lag] = bisp3cum(x, 1, L3, 'none');

%% 3. Gianakis' formula for h[k]
% Compute h_hat for 10 elements. Only the q(=6) first will be nonzerosub
% It could be any other size >=6 with the same results below
h_hat = zeros(10, 1);
for k=1:q+1
    h_hat(k) = cum(L3 + 1 + q, L3 + k)/cum(L3 + 1 + q, L3 + 1);
end

%% 4. Sub-estimation & Sup-estimation
q_sub = q-2;
h_sub = zeros(10, 1);
for k=1:q_sub
    h_sub(k) = cum(L3 + 1 + q_sub, L3 + k)/cum(L3 + 1 + q_sub, L3 + 1);
end

q_sup = q+3;
h_sup = zeros(10, 1);
for k=1:q_sup
    h_sup(k) = cum(L3 + 1 + q_sup, L3 + k)/cum(L3 + 1 +q_sup, L3 + 1);
end

%% 5. Comparison between estimation and original
x_est = conv(h_hat, v);
x_est = x_est(1:N);
figure(2);
plot(x_est, 'r');
hold on;
plot(x, 'b')
title('Real vs Estimated')
xlabel('k')
ylabel('x[k]')
legend('estimated', 'real')
rmse = sqrt( sum( (x_est - x).^2 )/N );
nrmse = rmse/(max(x) - min(x));
fprintf("NRMSE: %f\n", nrmse);

%% 6. Comparison with sub-estimation and sup-estimation
x_est_sub = conv(h_sub, v);
x_est_sub = x_est_sub(1:N);
figure(3);
plot(x_est_sub, 'r');
hold on;
plot(x, 'b');
title('Real vs Estimated with qsub=q-2')
xlabel('k')
ylabel('x[k]')
legend('estimated', 'real')
rmse = sqrt( sum( (x_est_sub - x).^2 )/N );
nrmse = rmse/(max(x) - min(x));
fprintf("NRMSE for sub-estimation with qsub=q-2: %f\n", nrmse);

x_est_sup = conv(h_sup, v);
x_est_sup = x_est_sup(1:N);
figure(4);
plot(x_est_sup, 'r');
hold on;
plot(x, 'b');
title('Real vs Estimated with qsup=q+3')
xlabel('k')
ylabel('x[k]')
legend('estimated', 'real')
rmse = sqrt( sum( (x_est_sup - x).^2 )/N );
nrmse = rmse/(max(x) - min(x));
fprintf("NRMSE for sup-estimation with qsup=q+3: %f\n", nrmse);

%% 7. SNR variations
NN = 8;  % Number of SNR values to try
nrmseV = zeros(NN, 1);   % Vector to hold NRMSE for each SNR value
snrV = 30:-5:-5;         % Victor of SNR values

for i=1:NN
    y = awgn(x, snrV(i), 'measured');
    % 7.2. 3rd order cumulant
    L3 = 20;    % number of lags
    % window=0 uses the parzen window
    [~, ~, cumSNR, lagSNR] = bisp3cum(y, 1, L3, 'none');
    % 7.3. Gianakis' formula for h[k]
    % Compute h_hat for 10 elements. Only the q(=6) first will be nonzerosub
    % It could be any other size >=6 with the same results below
    h_hat_snr = zeros(10, 1);
    for k=1:q+1
        h_hat_snr(k) = cumSNR(L3 + 1 + q, L3 + k)/cumSNR(L3 + 1 + q, L3 + 1);
    end
    x_est_snr = conv(h_hat_snr, v);
    x_est_snr = x_est_snr(1:N);
    rmse = sqrt( sum( (x_est_snr - x).^2 )/N );
    nrmse = rmse/(max(x) - min(x));
    nrmseV(i) = nrmse;
end

figure(5)
plot(snrV, nrmseV)
xlabel('SNR (dB)')
ylabel('NRMSE')