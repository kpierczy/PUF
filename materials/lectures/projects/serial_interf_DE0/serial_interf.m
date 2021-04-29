classdef serial_interf
    
    methods(Static=true,Access=public)
    
        function H=open(port, boud, parity)
            try
                H=[];
                H=serial(port);
                set(H,"baudrate", boud);
                set(H,"parity", parity);
                srl_flush(H);
             catch err
                disp(err);
                if isa(H,"octave_serial"), fclose(H); end
                H=[];
            end
        end
        
        function H=close(H)
            try
                srl_close(H);
                H=[];
            catch err
                disp(err);
                H=[];
            end
        end
        
        function N=send(H,bytes)
            try
                N=0;
                srl_write(H,uint8(bytes));
                N=length(bytes);
            catch err
                disp(err);
                N=0;
            end
        end
        
        function R=receive(H,num)
            try
                R=[];
                R=double(srl_read(H,num));
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
            if (isempty(res) || res~=hex2dec('A9')), return; end
            for i=1:num
                data=data+13;
                if (data==0), data=mod(i,256); if (data==0), data=13; end end
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
    end
end


