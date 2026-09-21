function [RRV_DB, RRV_SAMPLES] = GeneFeatsPerBody(bodyJoints, Normalize_Joints)
%GENEFEATSPERBODY  Build HRRV descriptors for every body-part of every clip.
%
%   [RRV_DB, RRV_SAMPLES] = GENEFEATSPERBODY(bodyJoints, Normalize_Joints)
%
%   Implements Section III-B of the TCSVT paper for MSR-Action3D. Each body-part
%   is treated as a rigid body spanned by a root joint and an end joint;
%   FUNC_RRVDESCRIPTOR turns that trajectory pair into the 7-D RRV descriptor
%   of Eq. (1): a unit quaternion (4-D) for rotation plus a square-root
%   relative velocity (3-D). Stacking the parts in part-wise and layer-wise
%   order yields the HRRV descriptor of Eq. (5).
%
%   Every skeleton is first put in a person-centric frame, which is what makes
%   the descriptor invariant to viewpoint and body size:
%     * origin  moved to the hip centre (STRN)
%     * axes    built from C7 and the two hip joints, so the body faces a
%               canonical direction
%     * scale   divided by |C7 - STRN|, the torso length
%
%   INPUTS
%     bodyJoints        P x 2 cell  {rootJointId, endJointId} per body-part,
%                                   ordered layer 1, then layer 2, then layer 3
%     Normalize_Joints  2 x 2 cell  {C7, STRN; RFWT, LFWT} joint ids used to
%                                   build the person-centric frame
%
%   OUTPUTS
%     RRV_DB       1 x N cell  HRRV descriptor per training clip
%     RRV_SAMPLES  1 x M cell  HRRV descriptor per test clip
%
%   READS   <jointId>.mat         variable TRAJDB       (training clips)
%           <jointId>samples.mat  variable TRAJSAMPLES  (test clips)
%   WRITES  RRV_DB.mat, RRV_SAMPLES.mat in the current folder
%
%   The original addressed the per-joint tables through eval-built variable
%   names (DB_1, DB_5, ...). An explicit lookup does the same job and can be
%   checked by the reader and by MATLAB. The original also built RRV_DB1 /
%   RRV_DB2, the quaternion and velocity halves of the descriptor, which were
%   read only by the legacy recognition_*_bat script; they are gone with it.
%   Should you want that split back, it is RRV_DB{i}(:,1:4) and (:,5:7).
%
%   See also FUNC_RRVDESCRIPTOR, GENEFISHERCODEJOINTPYRAMID.

RRV_DB = buildDescriptors(bodyJoints, Normalize_Joints, '', 'TRAJDB', 'training');
save RRV_DB RRV_DB;

RRV_SAMPLES = buildDescriptors(bodyJoints, Normalize_Joints, 'samples', 'TRAJSAMPLES', 'test');
save RRV_SAMPLES RRV_SAMPLES;
end


% --------------------------------------------------------------------------
function descriptors = buildDescriptors(bodyJoints, Normalize_Joints, fileSuffix, varName, label)
%BUILDDESCRIPTORS  Run the pipeline over one split (training or test).
%
%   The two halves of the original file were identical apart from the file
%   suffix and the variable name stored inside those files.

[tables, slotOf] = loadJointTables(bodyJoints, Normalize_Joints, fileSuffix, varName);

jointGroup = size(bodyJoints, 1);

% Resolve every joint id to a table slot once, outside the per-clip loop.
rootSlot = zeros(1, jointGroup);
endSlot  = zeros(1, jointGroup);
for n = 1:jointGroup
    rootSlot(n) = slotOf(bodyJoints{n,1});
    endSlot(n)  = slotOf(bodyJoints{n,end});
end
c7Slot   = slotOf(Normalize_Joints{1,1});
strnSlot = slotOf(Normalize_Joints{1,2});
rfwtSlot = slotOf(Normalize_Joints{2,1});
lfwtSlot = slotOf(Normalize_Joints{2,2});

nSamples    = size(tables{1}, 2);
descriptors = cell(1, nSamples);

for i = 1:nSamples
    fprintf('get the RRV descriptors for %s data %d/%d...\n', label, i, nSamples);

    % --- person-centric frame for this clip -------------------------------
    joint_C7   = tables{c7Slot}{2,i};
    joint_STRN = tables{strnSlot}{2,i};
    joint_RFWT = tables{rfwtSlot}{2,i};
    joint_LFWT = tables{lfwtSlot}{2,i};

    ScalLeng = norm(joint_C7(1,:) - joint_STRN(1,:));      % torso length

    v1 = joint_C7(1,:) - joint_RFWT(1,:);
    v2 = joint_C7(1,:) - joint_LFWT(1,:);
    Hy = v1 + v2;                  % up, bisecting the two hip directions
    Hz = cross(v1, v2);            % forward, normal to the shoulder-hip plane
    Hx = cross(Hy, Hz);            % lateral, completing a right-handed frame
    RotM = [Hx/norm(Hx); Hy/norm(Hy); Hz/norm(Hz)];

    % --- one RRV descriptor per body-part, stacked vertically -------------
    for n = 1:jointGroup
        rootTraj = tables{rootSlot(n)}{2,i};
        endTraj  = tables{endSlot(n)}{2,i};
        T        = size(rootTraj, 1);            % frames in this clip

        rootTraj = (rootTraj - joint_STRN) * RotM' / ScalLeng;
        endTraj  = (endTraj  - joint_STRN) * RotM' / ScalLeng;

        descriptors{1,i}((n-1)*T+1 : n*T, :) = Func_RRVdescriptor(rootTraj, endTraj);
    end
end
end


% --------------------------------------------------------------------------
function [tables, slotOf] = loadJointTables(bodyJoints, Normalize_Joints, fileSuffix, varName)
%LOADJOINTTABLES  Load each referenced joint's trajectory table exactly once.
%
%   tables{k}   cell array loaded from <id><fileSuffix>.mat
%   slotOf      containers.Map from joint id to its index in `tables`

ids = [bodyJoints(:,1); bodyJoints(:,2); bodyJoints(:,end); ...
       Normalize_Joints(:,1); Normalize_Joints(:,end)];
ids = unique(ids(:), 'stable');

tables = cell(1, numel(ids));
slotOf = containers.Map('KeyType', 'char', 'ValueType', 'double');

for k = 1:numel(ids)
    fileName = [ids{k} fileSuffix];
    S = load(fileName);
    if ~isfield(S, varName)
        error('GeneFeatsPerBody:badJointFile', ...
              'Expected %s.mat to contain a variable named "%s"; found: %s.', ...
              fileName, varName, strjoin(fieldnames(S)', ', '));
    end
    tables{k}      = S.(varName);
    slotOf(ids{k}) = k;
end
end
