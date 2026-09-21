% Calculate sign for svd trajectories
% To solve symmetric

%% Input
% w: Re-rotate trajectory
%--Output
% SIGN: the signed for each axis
function SIGN=CalSIGN(w)
    w_prin=sum(w,1);w_prin=w_prin./norm(w_prin);
    [~,sort_idx]=sort(abs(w_prin),'descend');
    
    if sort_idx(3)==3
        SIGN(1,1)=sign(w_prin(1));
        SIGN(1,2)=sign(w_prin(2));
        if sort_idx(1)==1
            Z=cross([SIGN(1,1) 0 0],[0 SIGN(1,2) 0]);
            SIGN(1,3)=sign(Z(3));
        else
            Z=cross([0 SIGN(1,2) 0],[SIGN(1,1) 0 0]);
            SIGN(1,3)=sign(Z(3));
        end
    elseif sort_idx(3)==2
        SIGN(1,1)=sign(w_prin(1));
        SIGN(1,3)=sign(w_prin(3));
        if sort_idx(1)==1
            Z=cross([SIGN(1,1) 0 0],[0 0 SIGN(1,3)]);
            SIGN(1,2)=sign(Z(2));
        else
            Z=cross([0 0 SIGN(1,3)],[SIGN(1,1) 0 0]);
            SIGN(1,2)=sign(Z(2));
        end
    elseif sort_idx(3)==1
        SIGN(1,2)=sign(w_prin(2));
        SIGN(1,3)=sign(w_prin(3));
        if sort_idx(1)==2
            Z=cross([0 SIGN(1,2) 0],[0 0 SIGN(1,3)]);
            SIGN(1,1)=sign(Z(1));
        else
            Z=cross([0 0 SIGN(1,3)],[0 SIGN(1,2) 0]);
            SIGN(1,1)=sign(Z(1));
        end
    end

end