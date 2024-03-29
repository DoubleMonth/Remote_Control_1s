function  f_calculateGradient( r_fileName )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
samplingTime = 1; %%采样时间
path = pwd;
%% 输出提示信息
disp(strcat('正在处理',r_fileName));
disp('请稍候......');
%% 处理Excel表格
[excelData,str] = xlsread(r_fileName,1);               %读取原始数据表中的数据：str为数据表中的字符，data为数据表中的数据
[excelRow,excelColumn] = size(excelData);        %%获取数据表中的行列个数
value =  zeros(excelRow,4);                      %建立一个相应行数，1列的矩阵用于存储计算后的数据
invalidDataNum = zeros(1,4);                     %记录数据表前面无效数据的个数。
[m,n] = size(str);                              %% 数据表中字符的个数
needStr = {'车速','累计里程','GPS车速','GPS里程','GPS海拔'}; %% 计算坡度需要的数据项
needStrStationIn_value = zeros(1,5);                        %% 各数据项在原始数据表中的位置

%% 找出需要的数据项在原始数据表中的位置
for i = 1 :n                        
    for j = 1: 5
        if strcmp(str(1,i),needStr(1,j))>0
            needStrStationIn_value(1,j) = i-1;      %% -1是因为在原数据表中第一列为时间，MATLAB读取后数据矩阵中没有这一列。excelData的行数和列数比原始excel少一行，少一列。
        end
    end
end
format short g                                      %%设置显示格式
%% 仪表车速计算坡度
for row_x = 1: excelRow - 1
    gpsElevationDiffe = excelData(row_x+1,needStrStationIn_value(1,5)) - excelData(row_x,needStrStationIn_value(1,5));
    speedSum =  excelData(row_x+1,needStrStationIn_value(1,1)) + excelData(row_x,needStrStationIn_value(1,1));
    if speedSum == 0                                                        % speedSum=0时，分母为0，无效数据
        if invalidDataNum(1,1) == 0                                         % 还没有记录无效数据个数时无效数据的位置填充0
            value(row_x,1) = 0;
        else
            value(row_x,1) = value(row_x-1,1);                          %记录无效数据个数后用上一个数据进行填充
        end
    else                                                                   %有效数据
        if invalidDataNum(1,1) == 0                                        
            invalidDataNum(1,1) = row_x;                                  %还没有记录无效数据时记录下无效数据的个数
        end     
        mid_value_2 = asind(gpsElevationDiffe/(speedSum/2*samplingTime/3600*1000)); 
        if isreal(mid_value_2)                                              
            podu = tand(mid_value_2) *100;
            value(row_x,1) = abs(podu);                                       %写入矩阵中
        else
%             value(row_x,1) = value(row_x-1,1);                         %%出现复数时认为数据出错，使用上一个数据填充
        end
    end
end
%% 累计里程计算坡度
for row_x = 1: excelRow - 1
    gpsElevationDiffe = excelData(row_x+1,needStrStationIn_value(1,5)) - excelData(row_x,needStrStationIn_value(1,5));
    accumulativeMileageDiffe =  excelData(row_x+1,needStrStationIn_value(1,2)) - excelData(row_x,needStrStationIn_value(1,2));
    if accumulativeMileageDiffe == 0                                        %%累计里程差等于0的情况，此时使用上一行的数据进行填充
        if invalidDataNum(1,2) == 0                                         % 还没有记录无效数据个数时无效数据的位置填充0
            value(row_x,2) = 0;
        else
            value(row_x,2) = value(row_x-1,2);
        end
    else   
        if invalidDataNum(1,2) == 0                                         % 还没有记录无效数据个数时无效数据的位置填充0
            invalidDataNum(1,2) = row_x;
        end
        mid_value_2 = asind(gpsElevationDiffe/accumulativeMileageDiffe/1000); 
            podu =  tand(mid_value_2)*100;
            value(row_x,2) = abs(podu);                                         %写入矩阵中
    end
end
%% GPS车速计算坡度
for row_x = 1: excelRow - 1
    gpsElevationDiffe = excelData(row_x+1,needStrStationIn_value(1,5)) - excelData(row_x,needStrStationIn_value(1,5));
    gpsSpeedSum =  excelData(row_x+1,needStrStationIn_value(1,3)) + excelData(row_x,needStrStationIn_value(1,3));
    if gpsSpeedSum == 0                                                    %%速度会出现0的情况，此时使用上一行的数据进行填充
        if invalidDataNum(1,3) == 0                                         % 还没有记录无效数据个数时无效数据的位置填充0
            value(row_x,3) = 0;
        else
            value(row_x,3) = value(row_x-1,3);
        end
    else   
        if invalidDataNum(1,3) == 0                                         % 还没有记录无效数据个数时无效数据的位置填充0
            invalidDataNum(1,3) = row_x;
        end
        mid_value_2 = asind(gpsElevationDiffe/(gpsSpeedSum/2*samplingTime/3600*1000)); %% 注意修改采样时间
        if isreal(mid_value_2)                                              %%出现复数时认为数据出错，使用上一个数据填充
            podu =  tand(mid_value_2)*100;
            value(row_x,3) = abs(podu);                                        %写入矩阵中
        else
%             value(row_x,3) = value(row_x-1,3);
        end
    end
end
%% GPS里程计算坡度
for row_x = 1: excelRow - 1
    gpsElevationDiffe = excelData(row_x+1,needStrStationIn_value(1,5)) - excelData(row_x,needStrStationIn_value(1,5));
    gpsMileageDiffe =  excelData(row_x+1,needStrStationIn_value(1,4)) - excelData(row_x,needStrStationIn_value(1,4));
    if gpsMileageDiffe == 0                                                %%速度会出现0的情况，此时使用上一行的数据进行填充
        if invalidDataNum(1,4) == 0                                        % 还没有记录无效数据个数时无效数据的位置填充0
            value(row_x,4) = 0;
        else
            value(row_x,4) = value(row_x-1,4);
        end
    else   
        if invalidDataNum(1,4) == 0                                        % 还没有记录无效数据个数时无效数据的位置填充0
            invalidDataNum(1,4) = row_x;
        end
        mid_value_2 = asind(gpsElevationDiffe/gpsMileageDiffe/1000); 
            podu = tand(mid_value_2)*100;
            value(row_x,4) = abs(podu);                                        %写入矩阵中
    end
end
%% 滤波算法--去除>0.2和<-0.2的数据，用上一个数据填充
for i = 1:4
    for j = 2:excelRow
        if value(j,i)>40||value(j,i)<-40
            value(j,i) = value(j-1,i);
        end
    end
end
i = find('.'==r_fileName);
imname = r_fileName(1:i-1); %% imname为不带后缀文件名称 
outFile = strcat(imname,'_output');
if exist(outFile)   %% 如果存在output文件夹，先删除
     rmdir (outFile,'s');
end
mkdir(outFile);%% 创建一个Output文件夹
cd(fullfile(path,outFile));       %%进入output目录
poduFile = strcat(imname,'_caiji.xlsx'); %%组成带excle文件名的podu文件名
value_2 = value(max(invalidDataNum(:)):excelRow,1:4);                               %%取出矩阵中有效数据，丢弃无效数据
colname={'序号','仪表车速计算坡度','累计里程计算坡度','GPS车速计算坡度','GPS里程计算坡度','车速','行驶距离'};    %%增加每一列的数据名称
warning off MATLAB:xlswrite:AddSheet;   %%防止出现warning警告 
xlswrite(poduFile, colname, 'sheet1','A1');
xuhao = linspace(1,m-max(invalidDataNum(:)),m-max(invalidDataNum(:)));
xlswrite(poduFile, xuhao', 'sheet1','A2');                %%序号
% xlswrite(poduFile,str(max(invalidDataNum(:))+1:m,1), 'sheet1','B2');              %%时间
xlswrite(poduFile,abs(value_2), 'sheet1','B2');                    %%计算后的数据取累计里程计算坡度

licheng=zeros(m-max(invalidDataNum(:)),1);
sudu=zeros(m-max(invalidDataNum(:)),1);
for i = 1:m-max(invalidDataNum(:))-1
    sudu(i,1)= excelData(max(invalidDataNum(:))+i,needStrStationIn_value(1,1));
    licheng(i,1) = (excelData(max(invalidDataNum(:))+i,needStrStationIn_value(1,2))-excelData(max(invalidDataNum(:))+1,needStrStationIn_value(1,2)))*1000;
end
sudu(m-max(invalidDataNum(:)),1)= sudu(m-max(invalidDataNum(:))-1,1);
licheng(m-max(invalidDataNum(:)),1) = licheng(m-max(invalidDataNum(:))-1,1);
xlswrite(poduFile,sudu, 'sheet1','F2'); %% 速度
xlswrite(poduFile,licheng, 'sheet1','G2'); %% 行驶里程

% delete(fh);
%% 数据处理完毕，输出提示信息
disp('数据处理完毕，请查看当前文件夹下的');
disp(poduFile);
cd ..       %%退出output目录

end

