% Stochastic algorithms simulation example
% (C) Bartosz Zator (braton@gmail.com)
% $Date: 02-Nov-2006$
%--------------------------------------------------------------------------
% Number of filter taps
f_len=16;
% Input signals length
s_len=2^12;
% Number of independent averaging
avr_len=10;
% AWGN Variance [dB]
Var=-40;
% TRUE if input signals are complex
cpl=0;
% Smoothing window length
smth_len=4;
% Shaping filter
a=0.95;
sNum=sqrt(1-abs(a)^2);
sDen=[ 1,-a ];
%--------------------------------------------------------------------------
% Filter taps initialize (FIR)
fNum=rand(1,f_len)+sqrt(-1)*(cpl~=0)*rand(1,f_len);
% Average output signal
avry=zeros(1,s_len);
% Independent averaging...
for k=1:avr_len,
    disp( sprintf('Iteration %.0f \\ %.0f',k,avr_len) );
    u=normrnd(0,1,1,s_len)+sqrt(-1)*(cpl~=0)*normrnd(0,1,1,s_len);
    e=normrnd(0,10^(0.05*Var),1,s_len)+...
        sqrt(-1)*(cpl~=0)*normrnd(0,10^(0.05*Var),1,s_len);
    % Input signal
    u = filter(sNum,sDen,u);
    % Desired signal
    d=filter(fNum,1,u)+e;
    % Filtering...
    % ---------------------------------------------------
    % ######### Choose algorithm unmarking one #########
    %[w,y]=LMS( u,d,0.002,f_len );
    %[w,y]=seLMS( u,d,0.002,f_len );
    %[w,y]=srLMS( u,d,0.002,f_len );
    %[w,y]=ssLMS( u,d,0.002,f_len );
    %[w,y]=LeakyLMS( u,d,0.002,0.10,f_len );
    %[w,y]=LMF( u,d,0.002,f_len );
    %[w,y]=LMMN( u,d,0.002,0.50,f_len );
    %[w,y]=eNLMS( u,d,0.5,1e-3,f_len );
    %[w,y]=epNLMS( u,d,0.5,1e-3,0.9,f_len );
    %[w,y]=DFTLMS( u,d,0.02,0.9,f_len );
    %[w,y]=DCTLMS( u,d,0.02,0.9,f_len );
    %[w,y]=DHTLMS( u,d,0.02,0.9,f_len );
    [w,y]=eAPA( u,d,0.5,1e-3,1,f_len );
    %[w,y]=eAPA( u,d,0.5,1e-3,2,f_len );
    %[w,y]=eAPA( u,d,0.5,1e-3,4,f_len );
    %[w,y]=eAPA( u,d,0.5,1e-3,8,f_len );
    %[w,y]=eAPA( u,d,0.5,1e-3,16,f_len );    
    %[w,y]=ePRA( u,d,0.5,1e-3,4,f_len );
    %[w,y]=APAOCF( u,d,0.5,1e-3,4,f_len );
    % ---------------------------------------------------    
    avry=avry+abs(d-y).^2;
end;
disp('Done!');
avry=avry/avr_len;
disp('Smoothing...');
avry=conv(avry,ones(1,max(smth_len,1)));
figure;hold on;
plot( 1:s_len-smth_len,10*log10(avry(max(smth_len,1):...
    length(avry)-smth_len)/max(smth_len,1)),'LineWidth',1,...
    'Color',[0.90,0.0,0.0] );
plot( 1:s_len-smth_len,10*log10(10^(0.1*Var)*ones(1,s_len-smth_len)),...
    'k','LineWidth',2 );
set(gca,'Box','on','FontName','Sylfaen','FontSize',12);
legend('Learning curve','Minimum Mean Square Error');
v=axis;axis( [v(1),s_len,v(3),v(4)] );
title(sprintf(strcat('Adaptive algorithm learning curve\n',...
'(%d independent averaging, smoothing window - %d samples)'),...
avr_len,max(smth_len,1)));
xlabel('n [Ts]');
ylabel('E|e(n)|^2 [dB]');
grid;