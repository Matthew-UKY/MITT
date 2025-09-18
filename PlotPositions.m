function PlotPositions(SelStruct,outname)

natot = length(SelStruct);
colline = getColline(natot);
load(outname,'GUIControl')

% create mesh for water and bed surfaces
figure()
mesh(GUIControl.twoD.xchannel,GUIControl.twoD.ychannel,GUIControl.twoD.waterElevation, ...
    EdgeColor = 'g',...
    FaceColor = 'b',...
    FaceAlpha = 0.5);
hold on
mesh(GUIControl.twoD.xchannel,GUIControl.twoD.ychannel,GUIControl.twoD.bedElevation, ...
    EdgeColor = 0.7*ones(1,3),...
    FaceColor = 0.3*ones(1,3),...
    FaceAlpha = 0.5);
xlabel('xpos')
ylabel('ypos')
zlabel('zpos')

% add sampling positions
for na = 1:natot
    Config = SelStruct(na).Config;
    line(Config.xpos,Config.ypos,Config.zposGlobal, ...
        LineStyle = 'none',...
        Marker = '*', ...
        Color = colline(na,:));  
end

end