function code = hbplFisherEncodeAction(descriptor, o)
%HBPLFISHERENCODEACTION  Fisher-encode one action, body-part by body-part.
%
%   code = HBPLFISHERENCODEACTION(descriptor, o)
%
%   Builds the hierarchical action representation u of Eq. (8) in the TCSVT
%   paper: the HRRV descriptor of one clip is split into `o.jointNum`
%   contiguous body-part blocks, each block is encoded as an improved Fisher
%   vector sum-pooled over the temporal pyramid, and the per-part codes are
%   concatenated.
%
%   INPUTS
%     descriptor   F x T   HRRV descriptor for one action; rows are stacked
%                          per body-part, columns are time
%     o            struct  encoder settings:
%                            .jointNum     number of body-parts
%                            .codeLength   Fisher code length per part
%                            .pcaFlag      apply .PcaM before encoding
%                            .PcaM         PCA basis
%                            .means .covariances .priors   GMM parameters
%                            .pyramid      segments per temporal level
%
%   OUTPUT
%     code   (codeLength*jointNum) x 1   concatenated representation
%
%   Body-part blocks are taken as floor(size(descriptor,1)/jointNum) rows
%   each; a remainder, if any, is ignored, exactly as in the original code.
%
%   See also FV_POOLING_TS, GENEFISHERCODEJOINTPYRAMID.

code        = zeros(o.codeLength * o.jointNum, 1);
frameLength = floor(size(descriptor, 1) / o.jointNum);

for m = 1:o.jointNum
    feats = descriptor((m-1)*frameLength + 1 : m*frameLength, :);
    if o.pcaFlag
        feats = feats * o.PcaM;
    end
    rows = (m-1)*o.codeLength + 1 : m*o.codeLength;
    code(rows) = fv_pooling_ts(feats', o.means, o.covariances, o.priors, ...
                               'Improved', o.pyramid);
end
