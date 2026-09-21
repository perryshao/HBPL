1. RRV_AngTrj
Interpolation and resampling the descriptors to a same dimension (with respect to arc-length s)
1) input: sixdof  
	sixdof(:,1:3)=PointTrj
        sixdof(:,4:6)=AngularTrj(derived from angular velocity)

   input:options
	options.SVD_mode, SVD_mode=1, remove rotational variation by a SVD-based method
        options.s_cnt, the length of the a resampled trajectory
        options.Rot_mode 0: velocity is projected to RotM, 1: velocity  is projected to RotM', 2: no projection
       	options.unit_length 0: The length of the point trajectory equal to 1,  1: The length of the point trajectory is the original length

   Output: descriptor [SRVF quat]


2) RRV_AngTrj_Original
The dimension of the descriptor equals to the dimensions of the original trajectory



3. Distance between two quaternions
1) l2-norm
2) D=acos(abs(quat1*quat2'));