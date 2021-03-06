% program to return top R semantics from sim-sim matrix
% input 
clearvars;
% Input - 1. Directory containing simulation files 2. Query simulation file 
% Input - 3. type of similarity 4. r 5. k
% Output - top k objects
DIRECTORY_Sim   = uigetdir('','Select directory containing set of simulation files');
[FileName,PathName] = uigetfile('*.csv','Select simulation file of query');
queryFile = strcat(PathName,FileName);

prompt=('Enter the number of top semantics(r): ');
dlg_title = 'Input';
answer = inputdlg(prompt,dlg_title);
r = str2num(answer{1,1});

prompt=('Enter the number of objects to return(k): ');
dlg_title = 'Input';
answer = inputdlg(prompt,dlg_title);
k = str2num(answer{1,1});

debug = 1;
% prepare sim-sim matrix

% extract list of files present in dir
list_file       = dir(strcat(DIRECTORY_Sim,'\*.csv')); 
numOfFiles      = size(list_file,1);
SimSim          = zeros(numOfFiles,numOfFiles); % similarity similarity matrix

sim_type = 1;
switch sim_type
    case 1
        for i = 1:numOfFiles
            for j = i:numOfFiles
                file1name = list_file(i).name;
                file2name = list_file(j).name;
                file1table = csvread(strcat(DIRECTORY_Sim,'\',file1name),1,2);
                file2table = csvread(strcat(DIRECTORY_Sim,'\',file2name),1,2);
                SimSim(i,j) = sim_EUC(file1table, file2table);
                SimSim(j,i) = SimSim(i,j);
            end
        end
    otherwise
        disp('Enexpected Value');
end

[U, S, V] = svd(SimSim);

% Dividing objects into clusters
cluster = zeros(r,numOfFiles+1); % first column of cluster constains number of objects in that cluster
for i = 1:numOfFiles
    [~,I] = max(U(i,1:r)); % cluster number of nth Object = index of maximum of row 
    cluster(I,1) = cluster(I,1) + 1; % pick row ith upto r terms, find index j of max number
    cluster(I,cluster(I,1)+1) = i; % store i in the index j
end

% find similarity of query from each cluster
clusterSim = zeros(1,r);
queryTable = csvread(queryFile,1,2);

% find cluster similarity w.r.t query file using first object in cluster
clusterSim = zeros(r,2);
clusterSim(:,1) = 1:r;
for i = 1:r
    if cluster(i,1) == 0
        clusterSim(i,2) = 0;
    else
        fileIndex = cluster(i,2);
        fileName = list_file(fileIndex).name;
        filetable = csvread(strcat(DIRECTORY_Sim,'\',fileName),1,2);
        clusterSim(i,2) = sim_EUC(filetable,queryTable);
    end
end

% Sort the cluster similarity
[d1,d2] = sort(clusterSim(:,2),'descend');
orderedClusterSim = clusterSim(d2,:);

% prepare list of filtered elements from cluster
filteredObjects = cell(numOfFiles,2);
for i = 1:numOfFiles
    filteredObjects{i,1} = 0;
end
Idx = 1;
new_count = 0;
old_count = 0;
i = 1; % index to orderedClusterSim
while new_count<k
    clusterIdx = orderedClusterSim(i,1);
    new_count = old_count + cluster(clusterIdx,1);
    if cluster(clusterIdx,1) > 0
        l = 2;
        for j = old_count+1:new_count
            fileIndex = cluster(clusterIdx,l);
            fileName = list_file(fileIndex).name;
            filetable = csvread(strcat(DIRECTORY_Sim,'\',fileName),1,2);
            filteredObjects{j,2} = fileName;% save the name of the file
            filteredObjects{j,1} = sim_EUC(filetable,queryTable);% save the similarity w.r.t the file
            l = l + 1;
        end
        old_count = new_count;
    end
    i = i + 1;
end

% writing top k objects to output file
sortedSim = sortrows(filteredObjects,-1);
outputFile = fopen('TopkObjectsSimSim.txt','W');
for j = 1:k
    fprintf(outputFile,'%s, %e\r\n',sortedSim{j,2},sortedSim{j,1});
end
fclose(outputFile);
disp('Top k objects successfully written in TopkObjectsSimSim.txt');
