
function CS=CS_builder(Tracks,UseFlagCode)

if nargin==1
    UseFlagCode=0;
end

%UseFlagCode: 0=Ignore Flag 1=UseMitoFlag 2=IgnoreMitoFlag
    counter=0;
    CS=struct('file',[],'cellIndex',[],'csID',[],'tracks',[],'refCenter',[],...
        'boundaries',[],'refboundary',[],'refLocIDs',[],'neighborIDs',[],...
        'EllipseFit',[],'tracksCCids',[],'CSmatrix',[],'CSvec',[],'Deff',[],'segIDs',[],...
        'ChPts',[],'TessIndex',[],'refDeff',[],'neighborDeff',[],'MitoFlag',[],...
        'IDmatrixCSspec',[]);
    
    mkdir CSdata2    

    for i=size(Tracks,2)
        
        filename=(Tracks(i).file);
        filebase=filename(1:end-7);

        if UseFlagCode==0
            load(fullfile(pwd,'CSdata',strcat(filebase,'_CSdata.mat')),'CSdata');
            CSset=1:size(CSdata);
        elseif UseFlagCode==1
            load(fullfile(pwd,'CSdata',strcat(filebase,'_mito_CSdata.mat')),'CSdata');
            FlagIndex=NaN(size(CSdata));
            for j=1:size(CSdata,2)
                FlagIndex(j)=CSdata(j).MitoFlag;
            end
            CSset=find(FlagIndex);
        elseif UseFlagCode==2
            load(fullfile(pwd,'CSdata',strcat(filebase,'_other_CSdata.mat')),'CSdata');
            for j=1:size(CSdata,2)
                FlagIndex(j)=CSdata(j).MitoFlag;
            end
            CSset=find(FlagIndex==0);
        else
            error('I don''t recognize this UseFLagCode.');
        end

        
        
        for j=CSset
            
           counter=counter+1; 
           CSdata(j).cellIndex=i;
           CSdata(j).csIndex=counter;
           
           CS(counter).file=Tracks(i).file;
           CS(counter).cellIndex=i;
           CS(counter).csID=CSdata(j).csID;
           CS(counter).tracks=CSdata(j).Tracks;
           CS(counter).refCenter=CSdata(j).refCenter;
           CS(counter).boundaries=CSdata(j).boundaries;
           CS(counter).refboundary=CSdata(j).refboundary;
           CS(counter).refLocIDs=CSdata(j).refLocIDs;
           CS(counter).neighborIDs=setdiff(CSdata(j).LocIDs,CSdata(j).refLocIDs);
                %these are inside boundaries but outside refboundary
           CS(counter).EllipseFit=CSdata(j).EllipseFit;
           CS(counter).tracksCCids=mean(Tracks(i).CCindex(:,CSdata(j).Tracks),1,'omitnan');
                %same size as "tracks", but zero if not fit, ChrisC ID # if
                %fit
           CS(counter).CSmatrix=cat(3,Tracks(i).matrix(:,CSdata(j).Tracks,1),...
               Tracks(i).matrix(:,CSdata(j).Tracks,2)-CSdata(j).refCenter(1),...
               Tracks(i).matrix(:,CSdata(j).Tracks,3)-CSdata(j).refCenter(2));
                %same layout as usual matrix, but centered at refcenter and
                %only tracks involved in CS
           CS(counter).CSvec=Tracks(i).vector(:,CSdata(j).Tracks,:);
                %vectors for the same tracks
           CS(counter).Deff=Tracks(i).Deff(:,CSdata(j).Tracks);
                %Deff in the same M and N space
           CS(counter).ChPts=Tracks(i).cp(:,CSdata(j).Tracks);
                %logical array for M & N space if position is a CP
           CS(counter).segIDs=Tracks(i).segID(:,CSdata(j).Tracks);
                %M & N array with segIDs for ChrisC results if position is
                %associated
           CS(counter).TessIndex=Tracks(i).LocIndex(:,CSdata(j).Tracks);
                %JBM tesselation loc is assigned to
           CS(counter).refDeff=Tracks(i).Deff(CSdata(j).refLocIDs);
                %Deff of locs in refboundary as a list
           CS(counter).neighborDeff=Tracks(i).Deff(CS(counter).neighborIDs);
                %Deff of locs outside refboundary as a list
           CS(counter).MitoFlag=CSdata(j).MitoFlag;
                %Mito associated?
                
                
           % Make a matrix the same size as the cropped M & N space that
           % defines 1 if a localization is "neighborhood" and 2 if a
           % localization is "ContactSite".
           DummyMatrix1=zeros(size(Tracks(i).Deff));
           DummyMatrix1(CS(counter).neighborIDs)=1;
           DummyMatrix1(CSdata(j).refLocIDs)=2;
           CS(counter).IDmatrixCSspec=DummyMatrix1(:,CSdata(j).Tracks);
        end
        
        save(fullfile(pwd,'CSdata2',strcat(filebase,'_CSdata2.mat')),'CSdata');
        
        
    end

    save('CS_final.mat','CS');

end