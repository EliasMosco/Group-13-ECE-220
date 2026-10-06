%% SANDOVAL COUNTY INTERNET ANALYSIS  (ACS 2024 1-year: S2801, S2802, S1603)
% Requires MATLAB R2020a or newer (tiledlayout, XEndPoints, exportgraphics).
%
% PART 0  Load + clean all CSVs (also writes cleaned CSVs)
% PART A  Bernalillo vs Sandoval            (S2801 only)
% PART B  Sandoval vs the other 9 counties   (S2801 only, incl. histograms)
% PART C  Sandoval internet access by AGE / RACE / EDUCATION / EMPLOYMENT (S2802)
% PART D  Sandoval language at home by AGE / NATIVITY / POVERTY / EDUCATION (S1603)
% PART E  Cross-references: education and economy vs. internet + language
%
% Put this script in the same folder as the CSVs, then press Run.
% The Sandoval-only S2801 file (...203540) is NOT loaded: it is identical to
% the Sandoval columns inside the 10-county S2801 file.
%
% NOTE on error bars: ACS margins of error are 90% confidence intervals.
% If two bars' error bars overlap, treat the difference as inconclusive.

clear; close all; clc;

%% ===== SETTINGS =====
dataDir = pwd;
files.multi = "ACSST1Y2024.S2801-2026-09-10T202444.csv";   % 10 NM counties
files.s2802 = "ACSST1Y2024.S2802-2026-09-10T203626.csv";   % Sandoval
files.s1603 = "ACSST1Y2024.S1603-2026-09-10T202725.csv";   % Sandoval
focus   = "Sandoval";
compare = "Bernalillo";
saveFigs = true;                                % save every figure as PNG
outDir   = fullfile(dataDir, "output");
if ~exist(outDir, "dir"), mkdir(outDir); end
if ~saveFigs, figDir = ""; else, figDir = outDir; end
pal = palette();

%% ===== PART 0: LOAD + CLEAN =====
Rm  = loadCensus(fullfile(dataDir, files.multi));
M   = splitCounties(Rm);                         % per-county matrices
R28 = loadCensus(fullfile(dataDir, files.s2802));
R16 = loadCensus(fullfile(dataDir, files.s1603));

iS = find(M.Counties == focus);
iB = find(M.Counties == compare);
assert(~isempty(iS) && ~isempty(iB), "Focus/compare county not found in S2801 file.");
nC = numel(M.Counties);
fprintf("Counties in S2801: %s\n", strjoin(M.Counties, ", "));

% cleaned exports
writetable(toCleanTable(R28), fullfile(outDir, "clean_S2802_Sandoval.csv"));
writetable(toCleanTable(R16), fullfile(outDir, "clean_S1603_Sandoval.csv"));
writetable(toTidyCounties(M), fullfile(outDir, "clean_S2801_10counties_tidy.csv"));

%% ===== PART A: BERNALILLO vs SANDOVAL (S2801) =====
pair = [iB iS];  pairNames = M.Counties(pair);
pairCols = [pal.bern; pal.sand];

% --- A1: TYPES OF COMPUTER -------------------------------------------------
compRows  = ["Desktop or laptop","Smartphone","Tablet or other portable wireless computer","Other computer","No computer"];
compShort = ["Desktop/laptop","Smartphone","Tablet","Other","No computer"];
[V,E] = deal(zeros(numel(compRows),2));
for r = 1:numel(compRows)
    [p,e] = cp(M,"TYPES OF COMPUTER",compRows(r));  V(r,:) = p(pair);  E(r,:) = e(pair);
end
fig = newFig("A1_computer_types");
tl = tiledlayout(fig,2,2,"TileSpacing","compact");
title(tl, "TYPES OF COMPUTER: " + compare + " vs " + focus + " (S2801)");
ax = nexttile(tl,[1 2]);
groupedBarErr(ax,compShort,V,E,pairNames,pairCols);
ylabel(ax,"% of households"); title(ax,"Device types (overlapping categories, so bar chart not pie)");
for c = pair
    has = M.Est(findRow(M,"TYPES OF COMPUTER","Has one or more types of computing devices"),c);
    no  = M.Est(findRow(M,"TYPES OF COMPUTER","No computer"),c);
    pieChart(nexttile(tl),[has no],["Has computing device","No computer"],M.Counties(c) + " households");
end
finish(fig,"A1_computer_types",figDir);

% --- A2: TYPE OF INTERNET SUBSCRIPTIONS -------------------------------------
netRows  = ["Broadband of any type","Broadband such as cable, fiber optic or DSL","Cellular data plan", ...
            "Cellular data plan with no other type of Internet subscription","Satellite Internet service", ...
            "Without an Internet subscription"];
netShort = ["Any broadband","Cable/fiber/DSL","Cellular plan","Cellular ONLY","Satellite","No subscription"];
[V,E] = deal(zeros(numel(netRows),2));
for r = 1:numel(netRows)
    [p,e] = cp(M,"TYPE OF INTERNET",netRows(r));  V(r,:) = p(pair);  E(r,:) = e(pair);
end
fig = newFig("A2_internet_types");
tl = tiledlayout(fig,2,2,"TileSpacing","compact");
title(tl, "TYPE OF INTERNET SUBSCRIPTIONS: " + compare + " vs " + focus + " (S2801)");
ax = nexttile(tl,[1 2]);
groupedBarErr(ax,netShort,V,E,pairNames,pairCols);
ylabel(ax,"% of households"); title(ax,"Subscription types (overlapping, so bar chart not pie)");
for c = pair
    w  = M.Est(findRow(M,"TYPE OF INTERNET","With an Internet subscription"),c);
    wo = M.Est(findRow(M,"TYPE OF INTERNET","Without an Internet subscription"),c);
    pieChart(nexttile(tl),[w wo],["With subscription","Without subscription"],M.Counties(c) + " households");
end
finish(fig,"A2_internet_types",figDir);

% --- A3: HOUSEHOLD INCOME ---------------------------------------------------
brk      = ["Less than $20,000","$20,000 to $74,999","$75,000 or more"];
brkShort = ["< $20k","$20k - $74.9k","$75k +"];
fig = newFig("A3_income");
tl = tiledlayout(fig,2,2,"TileSpacing","compact");
title(tl, "HOUSEHOLD INCOME: " + compare + " vs " + focus + " (S2801)");
for c = pair
    cnt = arrayfun(@(b) M.Est(findRow(M,"HOUSEHOLD INCOME",b),c), brk);
    pieChart(nexttile(tl),cnt,brkShort,M.Counties(c) + ": households by income");
end
[V,E] = deal(zeros(3,2));
for r = 1:3
    [p,e] = cp(M,"HOUSEHOLD INCOME","Without an Internet subscription",brk(r));
    V(r,:) = p(pair);  E(r,:) = e(pair);
end
ax = nexttile(tl,[1 2]);
groupedBarErr(ax,brkShort,V,E,pairNames,pairCols);
ylabel(ax,"% without an Internet subscription"); title(ax,"No-subscription rate by household income");
finish(fig,"A3_income",figDir);

%% ===== PART B: SANDOVAL vs ALL 10 COUNTIES (S2801) =====
% Bars sorted high-to-low; Sandoval = blue, Bernalillo = orange, others = grey.

% --- B1: computers ----------------------------------------------------------
m = ["Desktop or laptop","Smartphone","Tablet or other portable wireless computer", ...
     "Smartphone with no other type of computing device", ...
     "Desktop or laptop with no other type of computing device","No computer"];
t = ["Desktop/laptop","Smartphone","Tablet","Smartphone ONLY","Desktop/laptop ONLY","No computer"];
fig = newFig("B1_computers_10counties");
tl = tiledlayout(fig,2,3,"TileSpacing","compact");
title(tl,"TYPES OF COMPUTER: % of households, all 10 counties (S2801)");
for k = 1:numel(m)
    [p,e] = cp(M,"TYPES OF COMPUTER",m(k));
    rankBar(nexttile(tl),M.Counties,p,e,t(k),iS,iB,pal);
end
finish(fig,"B1_computers_10counties",figDir);

% --- B2: internet -----------------------------------------------------------
m = ["Without an Internet subscription","Broadband of any type","Broadband such as cable, fiber optic or DSL", ...
     "Cellular data plan with no other type of Internet subscription","Satellite Internet service","Cellular data plan"];
t = ["No subscription","Any broadband","Cable/fiber/DSL","Cellular ONLY","Satellite","Cellular plan"];
fig = newFig("B2_internet_10counties");
tl = tiledlayout(fig,2,3,"TileSpacing","compact");
title(tl,"TYPE OF INTERNET SUBSCRIPTIONS: % of households, all 10 counties (S2801)");
for k = 1:numel(m)
    [p,e] = cp(M,"TYPE OF INTERNET",m(k));
    rankBar(nexttile(tl),M.Counties,p,e,t(k),iS,iB,pal);
end
finish(fig,"B2_internet_10counties",figDir);

% --- B3: income -------------------------------------------------------------
[V,E] = deal(zeros(nC,3));
for r = 1:3
    [p,e] = cp(M,"HOUSEHOLD INCOME","Without an Internet subscription",brk(r));
    V(:,r) = p';  E(:,r) = e';
end
iTot = findRow(M,"(TOP)","Total households");
fig = newFig("B3_income_10counties");
tl = tiledlayout(fig,2,2,"TileSpacing","compact");
title(tl,"HOUSEHOLD INCOME vs. NO SUBSCRIPTION, all 10 counties (S2801)");
ax = nexttile(tl,[1 2]);
groupedBarErr(ax,boldTicks(M.Counties,[iS iB]),V,E,brkShort,pal.three);
ax.TickLabelInterpreter = "tex";
ylabel(ax,"% without an Internet subscription"); title(ax,"No-subscription rate within each income bracket");
for r = [1 3]       % economy context: income mix of each county
    iR = findRow(M,"HOUSEHOLD INCOME",brk(r));
    p = M.Est(iR,:)./M.Est(iTot,:)*100;
    e = propMOE(M.Est(iR,:),M.MOE(iR,:),M.Est(iTot,:),M.MOE(iTot,:));
    rankBar(nexttile(tl),M.Counties,p,e,"% of households: " + brkShort(r),iS,iB,pal);
end
finish(fig,"B3_income_10counties",figDir);

% --- B4: HISTOGRAMS of county rates (10 counties = 10 observations) ----------
hm = {["TYPE OF INTERNET","Without an Internet subscription"],["TYPE OF INTERNET","Broadband of any type"], ...
      ["TYPE OF INTERNET","Broadband such as cable, fiber optic or DSL"], ...
      ["TYPE OF INTERNET","Satellite Internet service"], ...
      ["TYPE OF INTERNET","Cellular data plan with no other type of Internet subscription"], ...
      ["TYPES OF COMPUTER","No computer"]};
ht = ["% no subscription","% any broadband","% cable/fiber/DSL","% satellite","% cellular ONLY","% no computer"];
fig = newFig("B4_histograms");
tl = tiledlayout(fig,2,3,"TileSpacing","compact");
title(tl,"Distribution of county rates (each count = 1 county). Lines mark " + focus + " and " + compare);
for k = 1:numel(hm)
    p = cp(M,hm{k}(1),hm{k}(2));
    ax = nexttile(tl);
    histogram(ax,p,5,"FaceColor",pal.other,"EdgeColor","w");  hold(ax,"on");
    xline(ax,p(iS),"-",focus,"Color",pal.sand,"LineWidth",2,"LabelVerticalAlignment","top");
    xline(ax,p(iB),"-",compare,"Color",pal.bern,"LineWidth",2,"LabelVerticalAlignment","bottom");
    hold(ax,"off");  xlabel(ax,ht(k));  ylabel(ax,"# of counties");  grid(ax,"on");
end
finish(fig,"B4_histograms",figDir);

% --- B5: rank summary in the Command Window ---------------------------------
rows = ["Without an Internet subscription","Broadband of any type","Broadband such as cable, fiber optic or DSL", ...
        "Satellite Internet service","Cellular data plan with no other type of Internet subscription"];
Summary = table('Size',[numel(rows) 5],'VariableTypes',["string","double","double","double","double"], ...
    'VariableNames',["Metric","Sandoval_pct","Bernalillo_pct","TenCounty_median","Sandoval_rank_of_10_highest_is_1"]);
for k = 1:numel(rows)
    p = cp(M,"TYPE OF INTERNET",rows(k));
    [~,o] = sort(p,"descend");
    Summary(k,:) = {rows(k),p(iS),p(iB),median(p),find(o==iS)};
end
disp(Summary); writetable(Summary,fullfile(outDir,"summary_sandoval_rank.csv"));

%% ===== PART C: SANDOVAL INTERNET ACCESS by GROUP (S2802) =====
% Pie only where categories are mutually exclusive. Race/Hispanic origin overlap,
% and Black/Asian/Pacific Islander are suppressed ("N") in the source, so no pie.
plotS2802(R28,"AGE",["Under 18 years","18 to 64 years","65 years and over"], ...
    ["Under 18","18-64","65+"],["Under 18 years","18 to 64 years","65 years and over"],"AGE",pal,figDir);
plotS2802(R28,"RACE AND HISPANIC",["White alone","American Indian and Alaska Native alone","Some other race alone", ...
    "Two or more races","Hispanic or Latino origin (of any race)","White alone, not Hispanic or Latino"], ...
    ["White","AI/AN","Other race","2+ races","Hispanic","White non-Hisp."],strings(0),"RACE AND HISPANIC OR LATINO ORIGIN",pal,figDir);
edu28 = ["Less than high school graduate or equivalency", ...
         "High school graduate (includes equivalency), some college or associate's degree","Bachelor's degree or higher"];
plotS2802(R28,"EDUCATIONAL",edu28,["< High school","HS / some college","Bachelor's +"],edu28,"EDUCATIONAL ATTAINMENT",pal,figDir);
plotS2802(R28,"EMPLOYMENT",["In labor force","Employed","Unemployed","Not in labor force"], ...
    ["In labor force","Employed","Unemployed","Not in labor force"],["Employed","Unemployed","Not in labor force"],"EMPLOYMENT STATUS",pal,figDir);

%% ===== PART D: SANDOVAL LANGUAGE AT HOME by GROUP (S1603) =====
plotS1603(R16,"AGE",["5 to 17 years","18 to 64 years","65 years and over"], ...
    ["5-17","18-64","65+"],["5 to 17 years","18 to 64 years","65 years and over"],"AGE",pal,figDir);
plotS1603(R16,"NATIVITY",["Native","Foreign born","Naturalized U.S. citizen","Not a U.S. citizen"], ...
    ["Native","Foreign born","Naturalized","Not a citizen"],["Native","Foreign born"],"NATIVITY AND CITIZENSHIP STATUS",pal,figDir);
plotS1603(R16,"POVERTY",["Below poverty level","At or above poverty level"], ...
    ["Below poverty","At/above poverty"],["Below poverty level","At or above poverty level"],"POVERTY STATUS",pal,figDir);
edu16 = ["Less than high school graduate","High school graduate (includes equivalency)", ...
         "Some college or associate's degree","Bachelor's degree or higher"];
plotS1603(R16,"EDUCATIONAL",edu16,["< High school","HS grad","Some college","Bachelor's +"],edu16,"EDUCATIONAL ATTAINMENT",pal,figDir);

%% ===== PART E: CROSS-REFERENCES (Sandoval) =====
% --- E1: EDUCATION x internet (S2802) x language (S1603) --------------------
% S2802 merges "HS grad" + "some college"; S1603 splits them, so we merge S1603 to match.
i28 = arrayfun(@(l) findRow(R28,"EDUCATIONAL",l), edu28);
iLH = findRow(R16,"EDUCATIONAL",edu16(1));
iHS = findRow(R16,"EDUCATIONAL",edu16(2));
iSC = findRow(R16,"EDUCATIONAL",edu16(3));
iBA = findRow(R16,"EDUCATIONAL",edu16(4));
grp = {iLH, [iHS iSC], iBA};
[tot,totE,oth,othE,spa,spaE] = deal(zeros(3,1));
for g = 1:3
    r = grp{g};
    tot(g) = sum(R16.X(r,1));  totE(g) = sqrt(sum(R16.X(r,2).^2));
    oth(g) = sum(R16.X(r,7));  othE(g) = sqrt(sum(R16.X(r,8).^2));
    spa(g) = sum(R16.X(r,11)); spaE(g) = sqrt(sum(R16.X(r,12).^2));
end
bb = R28.X(i28,5);  bbE = R28.X(i28,6);
ns = R28.X(i28,9);  nsE = R28.X(i28,10);
nc = R28.X(i28,13); ncE = R28.X(i28,14);
V = [bb, oth./tot*100, spa./tot*100];
E = [bbE, propMOE(oth,othE,tot,totE), propMOE(spa,spaE,tot,totE)];
eduShort = ["< High school","HS / some college","Bachelor's +"];
fig = newFig("E1_education_cross");
tl = tiledlayout(fig,1,2,"TileSpacing","compact");
title(tl,"EDUCATION x INTERNET (S2802) x LANGUAGE (S1603), Sandoval");
ax = nexttile(tl);
groupedBarErr(ax,eduShort,V,E,["Broadband subscription","Speak non-English at home","Speak Spanish at home"],pal.three);
ylabel(ax,"% of group"); title(ax,"Same education groups, two different measures");
ax = nexttile(tl);
groupedBarErr(ax,eduShort,[ns nc],[nsE ncE],["Computer, no subscription","No computer"],pal.three(1:2,:));
ylabel(ax,"% of group"); title(ax,"Lack of access by education");
finish(fig,"E1_education_cross",figDir);
disp(table(eduShort',bb,V(:,2),'VariableNames',["Education","Broadband_pct","NonEnglish_pct"]));

% --- E2: ECONOMY x internet / language ---------------------------------------
fig = newFig("E2_economy_cross");
tl = tiledlayout(fig,2,2,"TileSpacing","compact");
title(tl,"ECONOMY measures vs. internet and language, Sandoval");
% (a) income -> no subscription (S2801)
[p,e] = deal(zeros(1,3));
for r = 1:3
    [pp,ee] = cp(M,"HOUSEHOLD INCOME","Without an Internet subscription",brk(r));  p(r) = pp(iS);  e(r) = ee(iS);
end
singleBarErr(nexttile(tl),brkShort,p,e,pal.sand,"% without subscription","(a) Household income (S2801)");
% (b) employment -> broadband (S2802)
emp = ["Employed","Unemployed","Not in labor force"];
ie = arrayfun(@(l) findRow(R28,"EMPLOYMENT",l), emp);
singleBarErr(nexttile(tl),emp,R28.X(ie,5)',R28.X(ie,6)',pal.sand,"% with broadband","(b) Employment status (S2802)");
% (c) poverty -> speaks non-English (S1603)
pv = ["Below poverty level","At or above poverty level"];
ip = arrayfun(@(l) findRow(R16,"POVERTY",l), pv);
singleBarErr(nexttile(tl),["Below poverty","At/above poverty"],R16.X(ip,7)'./R16.X(ip,1)'*100, ...
    propMOE(R16.X(ip,7)',R16.X(ip,8)',R16.X(ip,1)',R16.X(ip,2)'),pal.sand,"% speak non-English at home","(c) Poverty status (S1603)");
% (d) language -> poverty rate (S1603 column percents, row 'Below poverty level')
ib = findRow(R16,"POVERTY","Below poverty level");
singleBarErr(nexttile(tl),["English only","Other language","Spanish"],R16.X(ib,[5 9 13]),R16.X(ib,[6 10 14]), ...
    pal.sand,"% below poverty level","(d) Poverty rate by language spoken (S1603)");
finish(fig,"E2_economy_cross",figDir);

fprintf("\nDone. Figures and cleaned CSVs are in: %s\n", outDir);


%% ======================= LOCAL FUNCTIONS =======================

function pal = palette()
pal.sand  = [0.00 0.45 0.74];
pal.bern  = [0.85 0.33 0.10];
pal.other = [0.72 0.72 0.72];
pal.three = [0.85 0.33 0.10; 0.93 0.69 0.13; 0.47 0.67 0.19];
end

function R = loadCensus(file)
% Reads a data.census.gov CSV and returns a clean struct:
%   Label, Cat (nearest ALL-CAPS header above), Parent (for indented sub-rows),
%   X (numeric matrix of every data column), VarNames (original headers)
opts = detectImportOptions(file,"Encoding","UTF-8","VariableNamingRule","preserve");
opts = setvartype(opts,"string");
T = readtable(file,opts);
raw  = T{:,1};
Xraw = T{:,2:end};
nb   = string(char(160));                                   % non-breaking space

lead  = strlength(raw) - strlength(regexprep(raw,"^[\s" + nb + "]+",""));
depth = lead/4;                                             % 4 nbsp per indent level
lab   = regexprep(strip(replace(raw,nb," ")),"\s+"," ");

E = ismissing(Xraw) | strlength(Xraw)==0;
isHdr = all(E,2);                                           % ALL-CAPS category rows are empty rows

S = erase(Xraw,[",",string(char(177)),"%","+"]);            % commas, +/- sign, %, top-code "+"
X = str2double(strip(S));                                   % "(X)" and "N" become NaN

n = numel(lab);
cat = strings(n,1);  par = strings(n,1);
cur = "(TOP)";  pl = "";  pd = 0;
for i = 1:n
    if isHdr(i), cur = lab(i); pl = ""; pd = 0; end
    cat(i) = cur;
    if ~isHdr(i)
        if endsWith(lab(i),":")
            pl = erase(lab(i),":");  pd = depth(i);
        elseif pl ~= "" && depth(i) > pd
            par(i) = pl;
        else
            pl = "";
        end
    end
end
keep = ~isHdr;
R.Label    = erase(lab(keep),":");
R.Cat      = cat(keep);
R.Parent   = par(keep);
R.Depth    = depth(keep);
R.X        = X(keep,:);
R.VarNames = string(T.Properties.VariableNames(2:end));
end

function M = splitCounties(R)
% Turns the wide multi-county table into row x county matrices.
nm  = R.VarNames;
cty = extractBefore(nm,", New Mexico");
M.Counties = reshape(unique(cty,"stable"),1,[]);
n = numel(M.Counties);  r = size(R.X,1);
[M.Est,M.MOE,M.Pct,M.PctMOE] = deal(nan(r,n));
for k = 1:n
    sel = cty == M.Counties(k);
    sfx = extractAfter(nm(sel),", New Mexico!!");
    Xk  = R.X(:,sel);
    M.Est(:,k)    = Xk(:,sfx=="Total!!Estimate");
    M.MOE(:,k)    = Xk(:,sfx=="Total!!Margin of Error");
    M.Pct(:,k)    = Xk(:,sfx=="Percent!!Estimate");
    M.PctMOE(:,k) = Xk(:,sfx=="Percent!!Margin of Error");
end
M.Counties = erase(M.Counties," County");
M.Label = R.Label;  M.Cat = R.Cat;  M.Parent = R.Parent;
end

function i = findRow(R,cat,label,parent)
if nargin < 4, parent = ""; end
m = startsWith(R.Cat,cat,"IgnoreCase",true) & R.Label == label;
if parent ~= "", m = m & R.Parent == parent; end
i = find(m,1);
assert(~isempty(i),"Row not found: [%s] '%s' (parent '%s')",cat,label,parent);
end

function [p,e] = cp(M,cat,label,parent)
% percent and percent-MOE across all counties for one row
if nargin < 4, parent = ""; end
i = findRow(M,cat,label,parent);
p = M.Pct(i,:);  e = M.PctMOE(i,:);
end

function e = propMOE(Y,eY,X,eX)
% Census handbook MOE for a proportion Y/X where Y is a subset of X (result in %)
p = Y./X;
rad = eY.^2 - p.^2.*eX.^2;
bad = rad < 0;
rad(bad) = eY(bad).^2 + p(bad).^2.*eX(bad).^2;
e = sqrt(rad)./X*100;
end

function T = toCleanTable(R)
vn = matlab.lang.makeValidName(replace(R.VarNames,"!!","_"));
vn = matlab.lang.makeUniqueStrings(extractBefore(vn + "      ",min(60,strlength(vn)+1)),{},namelengthmax);
T = [table(R.Cat,R.Parent,R.Label,'VariableNames',["Category","Parent","Label"]), ...
     array2table(R.X,"VariableNames",vn)];
end

function T = toTidyCounties(M)
nC = numel(M.Counties);  n = numel(M.Label);
T = table();
for k = 1:nC
    t = table(M.Cat,M.Parent,M.Label,repmat(M.Counties(k),n,1),M.Est(:,k),M.MOE(:,k),M.Pct(:,k),M.PctMOE(:,k), ...
        'VariableNames',["Category","Parent","Label","County","Estimate","MOE","Percent","PercentMOE"]);
    T = [T; t]; %#ok<AGROW>
end
end

function fig = newFig(name)
fig = figure("Name",name,"Color","k","Position",[80 60 1250 700]);
end

function finish(fig,name,outDir)
drawnow;
if strlength(outDir) > 0
    exportgraphics(fig,fullfile(outDir,name + ".png"),"Resolution",170);
end
end

function pieChart(ax,vals,labels,ttl)
ok = vals > 0 & ~isnan(vals);
pie(ax,vals(ok));
legend(ax,labels(ok),"Location","southoutside","Box","off");
title(ax,ttl);
end

function groupedBarErr(ax,cats,V,E,names,colors)
b = bar(ax,V,"grouped");
hold(ax,"on");
for k = 1:numel(b)
    b(k).FaceColor = colors(k,:);
    errorbar(ax,b(k).XEndPoints,V(:,k),E(:,k),"k","LineStyle","none","CapSize",4);
end
hold(ax,"off");
xticks(ax,1:numel(cats));  xticklabels(ax,cats);  xtickangle(ax,30);
legend(ax,b,names,"Location","best","Box","off");
grid(ax,"on");
end

function singleBarErr(ax,cats,v,e,col,ylab,ttl)
bar(ax,v,"FaceColor",col);  hold(ax,"on");
errorbar(ax,1:numel(v),v,e,"k","LineStyle","none","CapSize",5);  hold(ax,"off");
xticks(ax,1:numel(cats));  xticklabels(ax,cats);
ylabel(ax,ylab);  title(ax,ttl);  grid(ax,"on");
end

function rankBar(ax,names,v,e,ttl,iS,iB,pal)
n = numel(v);
[vs,ord] = sort(v,"descend");
b = bar(ax,1:n,vs,"FaceColor","flat");
C = repmat(pal.other,n,1);
C(ord==iS,:) = pal.sand;  C(ord==iB,:) = pal.bern;
b.CData = C;
hold(ax,"on");
errorbar(ax,1:n,vs,e(ord),"k","LineStyle","none","CapSize",3);
hold(ax,"off");
xticks(ax,1:n);  xticklabels(ax,names(ord));  xtickangle(ax,50);
ylabel(ax,"%");  grid(ax,"on");
title(ax,sprintf("%s  (Sandoval: #%d of %d)",ttl,find(ord==iS),n),"FontSize",9);
end

function lbl = boldTicks(names,idx)
lbl = names;
lbl(idx) = "\bf" + names(idx);
end

function plotS2802(R,catName,rowsL,short,pieRows,ttl,pal,figDir)
% Internet access within each group (S2802). Columns: 1 total, 3 broadband n, 5 broadband %,
% 6 its MOE, 9 no-subscription %, 10 MOE, 13 no-computer %, 14 MOE.
idx = arrayfun(@(l) findRow(R,catName,l),rowsL);
overall = R.X(findRow(R,"(TOP)","Total population in households"),5);
hasPie = ~isempty(pieRows);
fig = newFig("C_" + catName);
tl = tiledlayout(fig,1,2 + hasPie,"TileSpacing","compact");
title(tl,"S2802  " + ttl + ", Sandoval County");
if hasPie
    ip = arrayfun(@(l) findRow(R,catName,l),pieRows);
    pieChart(nexttile(tl),R.X(ip,1)',pieRows,"Population share");
end
ax = nexttile(tl);
Y = [R.X(idx,5) R.X(idx,9) R.X(idx,13)];
bar(ax,Y,"stacked");
xticks(ax,1:numel(short));  xticklabels(ax,short);  xtickangle(ax,30);
ylim(ax,[0 100]);  ylabel(ax,"% of group");
legend(ax,["Broadband","Has computer, no subscription","No computer"],"Location","southoutside","Box","off");
title(ax,"Internet access mix (suppressed groups left blank)");
ax = nexttile(tl);
singleBarErr(ax,short,R.X(idx,5)',R.X(idx,6)',pal.sand,"% with broadband","Broadband rate (90% MOE)");
yline(ax,overall,"--","County overall","LabelHorizontalAlignment","left");
xtickangle(ax,30);  ylim(ax,[0 105]);
finish(fig,"C_" + regexprep(ttl,"\W+","_"),figDir);
end

function plotS1603(R,catName,rowsL,short,pieRows,ttl,pal,figDir)
% Language within each group (S1603). Columns: 1 total, 2 MOE, 7 non-English n, 8 MOE,
% 11 Spanish n, 12 MOE. Rates are derived as n/total (the file's own % columns are
% the distribution WITHIN each language group, a different question).
idx = arrayfun(@(l) findRow(R,catName,l),rowsL);
ip  = arrayfun(@(l) findRow(R,catName,l),pieRows);
iT  = findRow(R,"(TOP)","Total population 5 years and over");
overall = R.X(iT,7)/R.X(iT,1)*100;
fig = newFig("D_" + catName);
tl = tiledlayout(fig,1,2,"TileSpacing","compact");
title(tl,"S1603  " + ttl + ", Sandoval County");
pieChart(nexttile(tl),R.X(ip,1)',pieRows,"Population share");
ax = nexttile(tl);
Y = [R.X(idx,7)./R.X(idx,1)*100, R.X(idx,11)./R.X(idx,1)*100];
E = [propMOE(R.X(idx,7),R.X(idx,8),R.X(idx,1),R.X(idx,2)), ...
     propMOE(R.X(idx,11),R.X(idx,12),R.X(idx,1),R.X(idx,2))];
groupedBarErr(ax,short,Y,E,["Speak non-English at home","Speak Spanish at home"],pal.three(1:2,:));
yline(ax,overall,"--","County overall (non-English)","LabelHorizontalAlignment","left");
ylabel(ax,"% of group");  title(ax,"Language spoken at home (90% MOE)");
finish(fig,"D_" + regexprep(ttl,"\W+","_"),figDir);
end
