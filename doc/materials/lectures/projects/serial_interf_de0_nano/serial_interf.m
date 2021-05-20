classdef serial_interf
    
    properties(Constant)
        COM_NAME         = 'COM6';
    end
    
    methods(Static=true,Access=public)
        function H=open(boud)
            try
                H=[];
                H=serial(serial_interf.COM_NAME, 'BaudRate', boud);
                if (H.Status~='closed'), fclose(H); end
                fopen(H);
            catch err
                disp(err);
                if ~isempty(H), fclose(H); end
                inst=instrfind('Port',serial_interf.COM_NAME);
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
                    pause(0.1);
                    if (toc(T)>1), return; end
                end
                [R, A]=fread(H,num);
                if (A~=num), R=[]; return; end
            catch err
                disp(err);
                R=[];
            end
        end
        function S=sync(H, neg, num)
            S=false;
            if (neg==false), data=0; else, data=255; end
            serial_interf.send(H,data);
            res=serial_interf.receive(H, 1);
            if (isempty(res) || res~=154), return; end
            for i=1:num
                data=data+13;
                if (data==0), data=i; end
                data=mod(data,256);
                serial_interf.send(H,data);
                res=serial_interf.receive(H, 1);
                if (isempty(res) || res~=(255-data)), return; end
            end
            serial_interf.send(H,0);
            res=serial_interf.receive(H, 1);
            if (isempty(res) || res~=0), return; end
            S=true;
        end
        function test(boud)
            out = '1234abc';
            H=serial_interf.open((boud)); if isempty(H), return; end
            S=serial_interf.sync(H,true,10);
            if (S==false), return; end
            for i=1:length(out)
                serial_interf.send(H,out(i));
                fprintf('%c',char(serial_interf.receive(H, 1)));
            end
            serial_interf.close(H);
            fprintf('\n');
        end
    end
end


