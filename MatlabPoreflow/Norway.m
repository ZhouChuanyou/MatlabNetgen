% 以Norway Oslo站为例，代码如下：
% 
% 先使用worldmap函数，返回句柄ax
ax = worldmap('World');
% 随即会生成一个粗略的地图框架
% 设置ax的属性，可以通过setm(ax) 来查看所有能设置的功能
% 这里我选择去掉经纬度坐标轴，以(0,0)为中心,这里可以根据自己需要设置
setm(ax,'ParallelLabel','off');
setm(ax,'MeridianLabel','off');
setm(ax, 'Origin', [0 0]);
% 通过shaperead函数导入陆地的的数据，并使用geoshow函数显示出来，属性可以通过查看geoshow函数自己选择，这里我将其设置为白色
land = shaperead('landareas', 'UseGeoCoords', true);
geoshow(ax, land, 'FaceColor', 'w');
% 最后在图中画出所需要的的坐标以及注释
%Norway
plotm(30.5,114.5,'b.','MarkerSize',20)
textm(30.5,114.5,'武汉','FontSize',14,'FontWeight','bold','Color',[0,0,1])
plotm(59.56,10.45,'b.','MarkerSize',20)
textm(59.56,10.45,'Oslo','FontSize',14,'FontWeight','bold','Color',[0,0,1]);
plot([7.90721e+05,1.035460e+07],[6.28521e+06,3.25836e+06],'b--');

