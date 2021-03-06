
% VERY IMPORTANT : MAKE ALL THESE USER INPUT
% Input two files (state files) and location
% Output : DTW_sim , DTW Similarity between them
% make sure to keep file func_DTW.m in the working direcetory
% DIRECTORY = 'C:\MWDB\P2_1B\';
% FILE_NAME_F1 = '1.csv';
% FILE_NAME_F2 = '2.csv';
% 
% prompt = ('Enter File path: ');
% 
% DIRECTORY = input(prompt);
% prompt = ('Enter first File : ');
% FILE_NAME_F1 = input(prompt);
% prompt = ('Enter second File : ');
% FILE_NAME_F2 = input(prompt);
% 
% F1_PATH          = strcat(DIRECTORY,FILE_NAME_F1);
% F2_PATH          = strcat(DIRECTORY,FILE_NAME_F2);
function DTW_sim = Phase2_1b(F1,F2)
no_of_col = numel(F1(1,:)) ;

sim = zeros();
for i= 1:no_of_col
V1 = F1(:,i);
V2 = F2(:,i);
sim(i) = func_DTW(V1,V2);
end;

avg = mean(sim(3:end));
DTW_sim = 1/(1+avg);

display(['similarity: ' num2str(DTW_sim)]);
end

