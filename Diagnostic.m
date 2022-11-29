classdef(Sealed) Diagnostic
    %Diagnostic Summary of this class goes here

    properties(GetAccess = private, Constant)
        operation_levels = ["Ok", "Warn", "Error", "Stale"];
    end

    methods(Access = private)
        function obj = Diagnostic()
        end
    end

    methods(Static)
        
        function [status, n] = extractArrayStatus(msg)
            %extractArrayStatus Convert a ROS DiagnosticArray object in 
            %a easy-to-read form.
            %   Output 'n' is the array length.
            status = []; n = 0;
            
            n = numel(msg.Status);
            for i=1:n
                current = msg.Status(i);
                newStatus = {};
                newStatus.name = current.Name;
                newStatus.message = current.Message;
                newStatus.level = Diagnostic.operation_levels( ...
                    1 + current.Level );
                newStatus.hwId = current.HardwareId;

                status = [status, newStatus];
            end

        end

    end
end