classdef(Sealed) MagneticField
    %MagneticField Implements methods to retrieve measurement of the 
    %Magnetic Field vector at a specific location.

    methods(Access = private)
        function obj = MagneticField()
        end
    end

    methods(Static)
        
        function [frame, field, covariance] = getMagneticField(msg)
            %getMagneticField Extract Turtlebot's measured magnetic field 
            %from a MagneticField message.
            %   Output value of the method are the measurement coordinate 
            %   frame for the field, the 3-by-1 field vector (x, y, z) 
            %   and a covariance matrix if available (else -1). 
            %   Field vector is measured in [Tesla].
            %   Covariance for the three components is a 3x3 matrix.
            %   If a vector-component is not reported, its value will be
            %   setted to NaN.
            
            %frame
            frame = msg.Header.FrameId;
            
            %field
            field = [   msg.MagneticField_.X;
                        msg.MagneticField_.Y;
                        msg.MagneticField_.Z     ];

            %covariance
            covArray = msg.MagneticFieldCovariance;
            covariance = reshape(covArray, [3, 3]).';
        end

    end
end