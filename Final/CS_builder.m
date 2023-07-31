
function CS=CS_builder(Tracks)

    counter=0;
    CS=struct('file',[],'cellIndex',[],'csID',[],'tracks',[],'refCenter',[],...
        'boundaries',[],'refboundary',[],'refLocIDs',[],'neighborIDs',[],...
        'EllipseFit',[],'tracksCCids',[],'CSmatrix',[],'CSvec',[],'Deff',[],'segIDs',[],...
        'ChPts',[],'TessIndex',[],'refDeff',[],'neighborDeff',[],'MitoFlag',[],...
        'IDmatrixCSspec',[]);
    
    mkdir CSdata2    

    for i=1:size(Tracks,2)
        
        filename=(Tracks(i).file);
        filebase=filename(1:end-7);
        load(fullfile(pwd,'CSdata',strcat(filebase,'_CSdata.mat')),'CSdata');
        
        for j=1:size(CSdata,2)
            
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
           CS(counter).neighborIDs=setdiff(find(isfinite(Tracks(i).matrix(:,CSdata(j).Tracks,1))),CSdata(j).refLocIDs);
           CS(counter).TrackLocIDsMN=find(isfinite(Tracks(i).matrix(:,CSdata(j).Tracks,1)));
                %these are m and n space coordinates (linear index) for
                %all CS-associated tracks (i.e. refLocIDs +
                %neighboirIDs but in track m and n space rather than CS m
                %and n space)
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
           CS(counter).refDeff=CS(counter).Deff(CSdata(j).refLocIDs);
                %Deff of locs in refboundary as a list
           CS(counter).neighborDeff=CS(counter).Deff(CS(counter).neighborIDs);
                %Deff of locs outside refboundary as a list
           CS(counter).MitoFlag=CSdata(j).MitoFlag;
                %Mito associated?
                
                
           % Make a matrix the same size as the cropped M & N space that
           % defines 1 if a localization is "neighborhood" and 2 if a
           % localization is "ContactSite".
           DummyMatrix1=zeros(size(CS(counter).Deff));
           DummyMatrix1(CS(counter).neighborIDs)=1;
           DummyMatrix1(CSdata(j).refLocIDs)=2;
           CS(counter).IDmatrixCSspec=DummyMatrix1;
        end
        
        save(fullfile(pwd,'CSdata2',strcat(filebase,'_CSdata2.mat')),'CSdata');
        
        
    end

    save('CS_final.mat','CS');

end