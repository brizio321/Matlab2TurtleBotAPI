classdef(Sealed) BatteryState
    %BatteryState Implements methods to extract useful info from a
    %sensor_msgs/BatteryState message.
    %   'getX' methods retrieve target information X from input parameter 
    %   'msg'. This is a sensor_msgs/BatteryState structure, returned
    %   for example by Turtlebot3B.getBatteryState method.

    properties(GetAccess=private, Constant)
        power_supply_status = ["unknown", "charging", "discharging", ...
            "not charging", "full"];
        power_health_status = ["unknown", "good", "overheat", "dead", ...
            "overvoltage", "unspec failure", "cold", ...
            "watchdog timer expire", "safety timer expire"];
    end

    methods(Access = private)
        function obj = BatteryState()
        end
    end

    methods(Static)

        function Percentage = getBatteryPercentage(msg)
            %getBatteryPercentage  Return battery percentage specified in
            %input parameter 'msg'.
            %   Charge percentage is represented as a floating point value
            %   in 0 to 1 range. In case of failure receiving
            %   /battery_state message or unmeasured charging percentage,
            %   the output Percentage will be NaN.
            if isstruct( msg )
                Percentage = msg.Percentage;
            else
                Percentage = NaN;
            end
        end

        function Voltage = getBatteryVoltage(msg)
            %getBatteryVoltage Return battery voltage, measured in Volts,
            %specified in input paramter 'msg'.
            %   In case of failure receiving /battery_state message or 
            %   unmeasured voltage, the output Voltage will be NaN.
            if isstruct( msg )
                Voltage = msg.Voltage;
            else
                Voltage = NaN;
            end
        end

        function Temperature = getBatteryTemperature(msg)
            %getBatteryTemperature Return battery temperature, measured in 
            %Celsius Degrees, specified in input paramter 'msg'.
            %   In case of failure receiving /battery_state message or 
            %   unmeasured temperature, the output Temperature will be NaN.
            if isstruct( msg )
                Temperature = msg.Temperature;
            else
                Temperature = NaN;
            end
        end

        function Current = getBatteryCurrent(msg)
            %getBatteryCurrent Return battery current, measured in Ampere,
            %specified in input paramter 'msg'.
            %   When discharging Current sign is negative. It can be used
            %   as efficiency parameter for robot movement.
            %   In case of failure receiving /battery_state message or 
            %   unmeasured current, the output Current will be NaN.
            if isstruct( msg )
                Current = msg.Current;
            else
                Current = NaN;
            end
        end

        function SupplyStatus = getSupplyStatus(msg)
            %getSupplyStatus Return the description of supply status
            %specified in input parameter 'msg'.
            %   Conversion is based on sensor_msgs/BatteryState.msg
            %   description. SupplyStatus is 'unknown' in case of failure
            %   receiving /battery_state message.
            if isstruct( msg )
                SupplyStatus = BatteryState.power_supply_status( ...
                    msg.PowerSupplyStatus+1 );
            else
                SupplyStatus = 'unknown';
            end
        end

         function HealthStatus = getHealthStatus(msg)
            %getHealthStatus Return the description of health status 
            %specified in input parameter 'msg'.
            %   Conversion is based on sensor_msgs/BatteryState.msg
            %   description. HealthStatus is 'unknown' in case of failure
            %   receiving /battery_state message.
            if isstruct( msg )
                HealthStatus = BatteryState.power_supply_status( ...
                    msg.PowerSupplyHealth+1 );
            else
                HealthStatus = 'unknown';
            end
         end

    end
end