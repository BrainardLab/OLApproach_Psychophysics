function lum = SPDToLum(SPD,S)
% TODO: documentation (header)
% TODO: relocate
% TODO: arguments to specify luminosity function
load('T_xyz1931.mat','*_xyz1931');
T_xyz = SplineCmf(S_xyz1931,T_xyz1931,S);
T_xyz = 683*T_xyz;
lum = T_xyz(2,:) * SPD;
end