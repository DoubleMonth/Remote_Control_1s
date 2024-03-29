function f_dataProcess( r_filename,r_excelNumber )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

i = find('.'==r_filename);
imname = r_filename(1:i-1); %% imname为不带后缀文件名称 
disp(strcat('正在处理',imname));
disp('请稍候......');
%% word设置
string = strcat(imname,'数据分析报告'); %%组成带excle文件名的podu文件名
doc_f='.doc';
spwd=[pwd '\'];
file_name =[spwd string doc_f];
try
    Word=actxGetRunningServer('Word.Application');
catch
    Word = actxserver('Word.Application');
    
end;

set(Word, 'Visible', 0);
documents = Word.Documents;
if exist(file_name,'file')
    document = invoke(documents,'Open',file_name);% 以Excel文件名保存分析报告。
else
    document = invoke(documents, 'Add');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
content = document.Content;
duplicate = content.Duplicate;
inlineshapes = content.InlineShapes;
selection= Word.Selection;
paragraphformat = selection.ParagraphFormat;
shape=document.Shapes;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 页面设置
document.PageSetup.TopMargin = 60;
document.PageSetup.BottomMargin = 50;
document.PageSetup.LeftMargin = 60;
document.PageSetup.RightMargin = 60;
set(content, 'Start',0);
set(content, 'Text',string);
set(paragraphformat, 'Alignment','wdAlignParagraphCenter');
% selection.Font.Size=50;
rr=document.Range(0,length(string));%选择文本
rr.Font.Size=20;%设置文本字体
%rr.Font.Bold=4;%设置文本字体 加粗 
end_of_doc = get(content,'end');
set(selection,'Start',end_of_doc);
selection.MoveDown;
selection.TypeParagraph;

%% 数据计算
[excelData,str] = xlsread(r_filename,1);               %读取原始数据表中的数据：str为数据表中的字符，data为数据表中的数据
[excelRow,excelColumn] = size(excelData);        %%获取数据表中的行列个数
value =  zeros(excelRow,4);                      %建立一个相应行数，1列的矩阵用于存储计算后的数据
runTime = excelData(excelRow,2)-excelData(1,2); %采集时间
runDistance = (excelData(excelRow,8)-excelData(1,8))/1000; % 行驶距离
maxVelocity = max(excelData(:,7));                  %最高车速
averageVelocity = mean(excelData(:,7)); % 平均车速
maxPitch =max(excelData(:,3));     %最大坡度
averagePitch = mean(excelData(:,3));    %平均坡度
% fangcha = var(excelData(:,2)); %% 坡度方差
% biaozhuncha = std(excelData(:,2));%% 坡度标准差
% junfanggen = rms(excelData(:,2));%%坡度均方根
% jueduizhidepingjunzhi = mean(abs(tand(excelData(:,2))*100));%%绝对值的平均值
% boxingyinzi = junfanggen/jueduizhidepingjunzhi;%%波形因子

%% 求车速占比
[sortVelocity,index] = sort(excelData(:,7));
speed_num =  zeros(9,1);  % 车速占比个数
for i=1:excelRow
    if sortVelocity(i,1)<10
        speed_num(1,1) = speed_num(1,1)+1;
    elseif sortVelocity(i,1)<20
        speed_num(2,1) = speed_num(2,1)+1;
    elseif sortVelocity(i,1)<30
        speed_num(3,1) = speed_num(3,1)+1;
    elseif sortVelocity(i,1)<40
        speed_num(4,1) = speed_num(4,1)+1;
    elseif sortVelocity(i,1)<50
        speed_num(5,1) = speed_num(5,1)+1;
    elseif sortVelocity(i,1)<60
        speed_num(6,1) = speed_num(6,1)+1;
    elseif sortVelocity(i,1)<70
        speed_num(7,1) = speed_num(7,1)+1;
    elseif sortVelocity(i,1)<80
        speed_num(8,1) = speed_num(8,1)+1;
    elseif sortVelocity(i,1)<90
        speed_num(9,1) = speed_num(9,1)+1;
    end
end
%% 求坡度占比
[sortPitch,index] = sort(excelData(:,3));
% sortPitch2(:,1)= tand(sortPitch(:,1))*100;
pitch_num =  zeros(6,1);  % 车速占比个数
for i=1:excelRow
    if sortPitch(i,1)<2
        pitch_num(1,1) = pitch_num(1,1)+1;
    elseif sortPitch(i,1)<4
        pitch_num(2,1) = pitch_num(2,1)+1;
    elseif sortPitch(i,1)<6
        pitch_num(3,1) = pitch_num(3,1)+1;
    elseif sortPitch(i,1)<8
        pitch_num(4,1) = pitch_num(4,1)+1;
    elseif sortPitch(i,1)<10
        pitch_num(5,1) = pitch_num(5,1)+1;
    else
        pitch_num(6,1) = pitch_num(6,1)+1;
    end
end
%% 表格 说明
selection.MoveDown;
selection.TypeParagraph;
set(paragraphformat, 'Alignment','wdAlignParagraphJustify');
set(selection, 'Text','1. 根据收集的数据做出数据统计表格如下所示：');
selection.Font.Size=10;
selection.MoveDown;
selection.TypeParagraph;

selection.MoveDown;
set(paragraphformat, 'Alignment','wdAlignParagraphCenter');
% selection.TypeParagraph;
set(selection, 'Text','表1： 采集数据分析');
selection.Font.Size=8;
selection.MoveDown;
Tables=document.Tables.Add(selection.Range,22,3);
DTI=document.Tables.Item(1);
DTI.Borders.OutsideLineStyle='wdLineStyleSingle';
DTI.Borders.OutsideLineWidth='wdLineWidth150pt';
DTI.Borders.InsideLineStyle='wdLineStyleSingle';
DTI.Borders.InsideLineWidth='wdLineWidth150pt';
DTI.Rows.Alignment='wdAlignRowCenter';
column_width=[80.575,70.7736,60.7736];
row_height=[20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849,20.5849];
for i=1:3
DTI.Columns.Item(i).Width=column_width(i);
end
for i=1:22
DTI.Rows.Item(i).Height =row_height(i);
end
for i=1:22
for j=1:3
      DTI.Cell(i,j).VerticalAlignment='wdCellAlignVerticalCenter';
end
end
end_of_doc = get(content,'end');
set(selection,'Start',end_of_doc);
selection.TypeParagraph;
DTI.Cell(1,1).Range.Text = '项次';%不需要更改
DTI.Cell(2,1).Range.Text = '采集时间(s)';
DTI.Cell(3,1).Range.Text = '行驶距离(km)';
DTI.Cell(4,1).Range.Text = '最高车速(km/h)';
DTI.Cell(5,1).Range.Text = '平均车速(km/h)';
DTI.Cell(6,1).Range.Text = '车速占比';
DTI.Cell(6,2).Range.Text = '0-10(km/h)';
DTI.Cell(7,2).Range.Text = '10-20(km/h)';
DTI.Cell(8,2).Range.Text = '20-30(km/h)';
DTI.Cell(9,2).Range.Text = '30-40(km/h)';
DTI.Cell(10,2).Range.Text = '40-50(km/h)';
DTI.Cell(11,2).Range.Text = '50-60(km/h)';
DTI.Cell(12,2).Range.Text = '60-70(km/h)';
DTI.Cell(13,2).Range.Text = '70-80(km/h)';
DTI.Cell(14,2).Range.Text = '80-90(km/h)';
DTI.Cell(15,1).Range.Text = '最大坡度(%)';
DTI.Cell(16,1).Range.Text = '平均坡度(%)';
DTI.Cell(17,1).Range.Text = '坡度占比';
DTI.Cell(17,2).Range.Text = '0-2(%)';
DTI.Cell(18,2).Range.Text = '2-4(%)';
DTI.Cell(19,2).Range.Text = '4-6(%)';
DTI.Cell(20,2).Range.Text = '6-8(%)';
DTI.Cell(21,2).Range.Text = '8-10(%)';
DTI.Cell(22,2).Range.Text = '大于10(%)';

% DTI.Cell(23,1).Range.Text = '坡度方差';
% DTI.Cell(24,1).Range.Text = '坡度标准差';
% DTI.Cell(25,1).Range.Text = '坡度均方根';  
% DTI.Cell(26,1).Range.Text = '绝对值的平均值';
% DTI.Cell(27,1).Range.Text = '波形因子';

DTI.Cell(1,3).Range.Text = '数值';%不需要更改
DTI.Cell(2,3).Range.Text = num2str(runTime);%采集时间
DTI.Cell(3,3).Range.Text = num2str(runDistance);%行驶距离
DTI.Cell(4,3).Range.Text = num2str(maxVelocity);%最高车速
DTI.Cell(5,3).Range.Text = num2str(averageVelocity);%平均车速
DTI.Cell(15,3).Range.Text = num2str(maxPitch);%最大坡度
DTI.Cell(16,3).Range.Text = num2str(averagePitch);%平均坡度
DTI.Cell(6,3).Range.Text = num2str(sprintf('%2.2f%%', (speed_num(1,1)/excelRow)*100));%车速占比  
DTI.Cell(7,3).Range.Text = num2str(sprintf('%2.2f%%', (speed_num(2,1)/excelRow)*100));%车速占比
DTI.Cell(8,3).Range.Text = num2str(sprintf('%2.2f%%', (speed_num(3,1)/excelRow)*100));%车速占比
DTI.Cell(9,3).Range.Text = num2str(sprintf('%2.2f%%', (speed_num(4,1)/excelRow)*100));%车速占比
DTI.Cell(10,3).Range.Text = num2str(sprintf('%2.2f%%', (speed_num(5,1)/excelRow)*100));%车速占比
DTI.Cell(11,3).Range.Text = num2str(sprintf('%2.2f%%', (speed_num(6,1)/excelRow)*100));%车速占比
DTI.Cell(12,3).Range.Text = num2str(sprintf('%2.2f%%', (speed_num(7,1)/excelRow)*100));%车速占比
DTI.Cell(13,3).Range.Text = num2str(sprintf('%2.2f%%', (speed_num(8,1)/excelRow)*100));%车速占比
DTI.Cell(14,3).Range.Text = num2str(sprintf('%2.2f%%', (speed_num(9,1)/excelRow)*100));%车速占比
DTI.Cell(17,3).Range.Text = num2str(sprintf('%2.2f%%', (pitch_num(1,1)/excelRow)*100));%坡度占比 
DTI.Cell(18,3).Range.Text = num2str(sprintf('%2.2f%%', (pitch_num(2,1)/excelRow)*100));%坡度占比
DTI.Cell(19,3).Range.Text = num2str(sprintf('%2.2f%%', (pitch_num(3,1)/excelRow)*100));%坡度占比
DTI.Cell(20,3).Range.Text = num2str(sprintf('%2.2f%%', (pitch_num(4,1)/excelRow)*100));%坡度占比
DTI.Cell(21,3).Range.Text = num2str(sprintf('%2.2f%%', (pitch_num(5,1)/excelRow)*100));%坡度占比
DTI.Cell(22,3).Range.Text = num2str(sprintf('%2.2f%%', (pitch_num(6,1)/excelRow)*100));%坡度占比

% DTI.Cell(23,3).Range.Text = num2str(fangcha);%采集时间
% DTI.Cell(24,3).Range.Text = num2str(biaozhuncha);%采集时间
% DTI.Cell(25,3).Range.Text = num2str(junfanggen);%采集时间
% DTI.Cell(26,3).Range.Text = num2str(jueduizhidepingjunzhi);%采集时间
% DTI.Cell(27,3).Range.Text = num2str(boxingyinzi);%采集时间

%% 合并单元格
DTI.Cell(1, 1).Merge(DTI.Cell(1, 2));
DTI.Cell(2, 1).Merge(DTI.Cell(2, 2));
DTI.Cell(3, 1).Merge(DTI.Cell(3, 2));
DTI.Cell(4, 1).Merge(DTI.Cell(4, 2));
DTI.Cell(5, 1).Merge(DTI.Cell(5, 2));
DTI.Cell(6, 1).Merge(DTI.Cell(14, 1));
DTI.Cell(15, 1).Merge(DTI.Cell(15, 2));
DTI.Cell(16, 1).Merge(DTI.Cell(16, 2));
DTI.Cell(17, 1).Merge(DTI.Cell(22, 1));
% DTI.Cell(23, 1).Merge(DTI.Cell(23, 2));
% DTI.Cell(24, 1).Merge(DTI.Cell(24, 2));
% DTI.Cell(25, 1).Merge(DTI.Cell(25, 2));
% DTI.Cell(26, 1).Merge(DTI.Cell(26, 2));
% DTI.Cell(27, 1).Merge(DTI.Cell(27, 2));
%% 图片 说明
selection.MoveDown;
set(paragraphformat, 'Alignment','wdAlignParagraphJustify');
selection.TypeParagraph;
set(selection, 'Text','2. 根据收集的数据现做出曲线如下所示：');
selection.Font.Size=10;
selection.MoveDown;
selection.TypeParagraph;
%% 车速时间曲线
fh=figure;
set(fh,'visible','off'); %%关闭图形显示
plot(excelData(:,1),excelData(:,7),'r-');
% grid on;%%显示网格线
legend('车速时间曲线');
title('车速时间曲线');
xlabel('时间');
ylabel('车速');
%% 保存生成的折线图  
% pngFile = strcat(imname,'车速时间.png'); %%组成带excle文件名的podu文件名
% figFile = strcat(imname,'车速时间.fig'); %%组成带excle文件名的podu文件名
% saveas(gcf,pngFile);
% saveas(gcf,figFile);
%% 将图形粘贴到当前文档里
print -dbitmap
selection.Range.Paste;
end_of_doc = get(content,'end');
set(selection,'Start',end_of_doc);
%% 图1 说明
selection.MoveDown;
set(paragraphformat, 'Alignment','wdAlignParagraphCenter');
selection.TypeParagraph;
set(selection, 'Text','图1： 车速时间曲线');
selection.Font.Size=8;
selection.MoveDown;
selection.TypeParagraph;
%% 坡度时间曲线
plot(excelData(:,1),excelData(:,3),'r-');
grid on;%%显示网格线
legend('坡度时间曲线');
title('坡度时间曲线');
xlabel('时间');
ylabel('坡度');
%% 保存生成的折线图  
% pngFile = strcat(imname,'坡度时间.png'); %%组成带excle文件名的podu文件名
% figFile = strcat(imname,'坡度时间.fig'); %%组成带excle文件名的podu文件名
% saveas(gcf,pngFile);
% saveas(gcf,figFile);
%% 将图形粘贴到当前文档里
print -dbitmap
selection.Range.Paste;
end_of_doc = get(content,'end');
set(selection,'Start',end_of_doc);
%% 图2 说明
selection.MoveDown;
set(paragraphformat, 'Alignment','wdAlignParagraphCenter');
selection.TypeParagraph;
set(selection, 'Text','图2： 坡度时间曲线');
selection.Font.Size=8;
selection.MoveDown;
selection.TypeParagraph;
%% 车速行驶距离曲线
distanceData = zeros(excelRow,1);
distanceData(:,1) = excelData(:,8)/1000;
plot(distanceData(:,1),excelData(:,7),'r-');
grid on;%%显示网格线
legend('车速行驶距离曲线');
title('车速行驶距离曲线');
xlabel('行驶距离');
ylabel('车速');
%% 保存生成的折线图  
% pngFile = strcat(imname,'车速行驶距离.png'); %%组成带excle文件名的podu文件名
% figFile = strcat(imname,'车速行驶距离.fig'); %%组成带excle文件名的podu文件名
% saveas(gcf,pngFile);
% saveas(gcf,figFile);
%% 将图形粘贴到当前文档里
print -dbitmap
selection.Range.Paste;
end_of_doc = get(content,'end');
set(selection,'Start',end_of_doc);
%% 图3 说明
selection.MoveDown;
set(paragraphformat, 'Alignment','wdAlignParagraphCenter');
selection.TypeParagraph;
set(selection, 'Text','图3： 车速行驶距离曲线');
selection.Font.Size=8;
selection.MoveDown;
selection.TypeParagraph;
%% 坡度行驶距离曲线
Pitch2(:,1)= tand(excelData(:,3))*100;
h = plot(distanceData(:,1),Pitch2(:,1),'r-');
grid on;%%显示网格线
legend('坡度行驶距离曲线');
title('坡度行驶距离曲线');
xlabel('行驶距离');
ylabel('坡度');
%% 保存生成的折线图  
% pngFile = strcat(imname,'坡度行驶距离.png'); %%组成带excle文件名的podu文件名
% figFile = strcat(imname,'坡度行驶距离.fig'); %%组成带excle文件名的podu文件名
% saveas(gcf,pngFile);
% saveas(gcf,figFile);
print -dbitmap
%将图形粘贴到当前文档里
selection.Range.Paste;
end_of_doc = get(content,'end');
set(selection,'Start',end_of_doc);
selection.MoveDown;
%% 图4 说明
selection.MoveDown;
set(paragraphformat, 'Alignment','wdAlignParagraphCenter');
selection.TypeParagraph;
set(selection, 'Text','图4： 坡度行驶距离');
selection.Font.Size=8;
selection.MoveDown;
selection.TypeParagraph;
close;                  % 关闭Figure

% figure;
% plot(excelData(:,2),'r-');

%% 保存文档
Document.ActiveWindow.ActivePane.View.Type = 'wdPrintView';
document = invoke(document,'SaveAs',file_name); % 保存文档
Word.Quit; % 关闭文档
disp(strcat(imname,'文档处理完毕！请在当前文件夹中查看！'));%% 提示信息xxxx文档处理完毕
end

