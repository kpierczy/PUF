classdef serial_transm
    
    properties(Constant)
        COM_NAME         = 'COM6';
    end
    
    methods(Static=true,Access=public)
        function H=open(boud)
            try
                H=[];
                H=serial(serial_transm.COM_NAME, 'BaudRate', boud);
                if (H.Status~='closed'), fclose(H); end
                fopen(H);
            catch err
                disp(err);
                if ~isempty(H), fclose(H); end
                inst=instrfind('Port',serial_transm.COM_NAME);
                if ~isempty(inst), fclose(inst); end
                H=[];
            end
        end
        function H=close(H)
            try
                if ~isempty(H), fclose(H); end
                H=[];
            catch err
                disp(err);
                H=[];
            end
        end
        function N=send(H,bytes)
            try
                N=0;
                fwrite(H,bytes);
                N=length(bytes);
            catch err
                disp(err);
                N=0;
            end
        end
        function R=receive(H,num)
            try
                R=[];
                if isempty(H), return; end
                A=H.BytesAvailable;
                if (num==0), num=A; end
                if (num==0), return; end
                T=tic;
                while H.BytesAvailable<num
                    pause(0,1);
                    if (toc(T)>1), return; end
                end
                [R, A]=fread(H,num);
                if (A~=num), R=[]; return; end
            catch err
                disp(err);
                R=[];
            end
        end
        function test
            out = '12abc';
            H=serial_transm.open(9600); if isempty(H), return; end
            for i=1:length(out)
                serial_transm.send(H,out(i));
                pause(0.5);
                fprintf('%c',char(serial_transm.receive(H, 1)));
            end
            serial_transm.close(H);
            fprintf('\n');
        end
    end
end


