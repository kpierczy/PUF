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
        
        function B = BUSinit(boud, anum, dnum, neg, tnum)
            B=[];
            H=serial_interf.open((boud)); if isempty(H), return; end
            S=serial_interf.sync(H,neg,tnum); if ~S, return; end
            B.H  = H;
            B.bn = 8;
            B.bm = 2^B.bn;
            B.an = anum;
            B.dn = dnum;
        end
        
        function t = BUStest(B, t, s)
            t = bitxor(mod(t + (B.bm-1 - s), B.bm), s);
        end

        function R = BUSwrite(B, adr, dana)
            R = 0;
            t = 0;
            for i=1:B.an
                s = mod(adr,B.bm); adr = bitshift(adr,-B.bn);
                if (i == B.an), s = bitor(s, B.bm/2); end
                serial_interf.send(B.H,s);
                t = serial_interf.BUStest(B, t, s);
                s=serial_interf.receive(B.H, 1);
                if (isempty(s) || s~=t), return; end
            end
            for i=1:B.dn
                s = mod(dana,B.bm); dana = bitshift(dana,-B.bn);
                serial_interf.send(B.H,s);
                t = serial_interf.BUStest(B, t, s);
                s=serial_interf.receive(B.H, 1);
                if (isempty(s) || s~=t), return; end
            end
            serial_interf.send(B.H,t);
            t = serial_interf.BUStest(B, t, t);
            s=serial_interf.receive(B.H, 1);
            if (isempty(s) || s~=t), return; end
            R=1;
        end
        
        function dana = BUSread(B, adr)
            dana = [];
            d = 0;
            t = 0;
            for i=1:B.an
                s = mod(adr,B.bm); adr = bitshift(adr,-B.bn);
                if (i == B.an), s = mod(s, B.bm/2); end
                serial_interf.send(B.H,s);
                t = serial_interf.BUStest(B, t, s);
                s=serial_interf.receive(B.H, 1);
                if (isempty(s) || s~=t), return; end
            end
            for i=0:B.dn-1
                serial_interf.send(B.H,t);
                s=serial_interf.receive(B.H, 1);
                if isempty(s), return; end
                t = serial_interf.BUStest(B, t, s);
                d = d + bitshift(s,B.bn*i);
            end
            serial_interf.send(B.H,t);
            t = serial_interf.BUStest(B, t, t);
            s=serial_interf.receive(B.H, 1);
            if (isempty(s) || s~=t), return; end
            dana=d;
        end

        function R = BUSwriteTest(B, adr, dana)
            R=0;
            serial_interf.BUSwrite(B, adr, dana);
            d=serial_interf.BUSread(B, adr);
            if (d==dana), R=1; end
        end

        function test(boud)
            B = serial_interf.BUSinit(boud, 2, 4, true, 10); if isempty(B), return; end
            serial_interf.BUSwriteTest(B,   5, 123);
            serial_interf.BUSwriteTest(B,  23,  37);
            suma = serial_interf.BUSread(B, 124);
            serial_interf.close(B.H);
            fprintf('suma: %d\n',suma);
        end
    end
end


