
clear all;
close all;

citra=imread('Baboon.bmp');
pesan = input('Masukan Pesan Maksimal 20 Karakter= ','s');

pesan = uint8(pesan);
panj_pesan = length(pesan);

[baris kolom]=size(citra);


bit_pesan=[];
for i=1:panj_pesan
    biner = dec2bin(pesan(i), 8);
    bit_pesan = [bit_pesan biner];
end

panj_bit=length(bit_pesan);
ambil_bit=[];
n=0;

%DETEKSI TEPI=======================================
cany=edge(citra, 'canny');
stego=citra(:);
[eVal,eIdx]=sort(cany(:),'descend');
eIdx=eIdx(1:numel(bit_pesan));

%RANDOM NUMBER ELEMEN===============================
r=randperm(numel(eIdx));
for i=1:numel(r)
    rIdx(i)=eIdx(r(i));
end

%PENYISIPAN=========================================
for i=1:numel(bit_pesan)
    X=dec2bin(stego(rIdx(i)), 8);
    ambil_2msb=X(1:2);
    ambil_8lsb=X(3:8);
    if ambil_2msb == '00'
        Y=0; 
    end
    if ambil_2msb == '01'
        Y=64; 
    end
    if ambil_2msb == '10'
        Y=128; 
    end
    if ambil_2msb == '11'
        Y=192; 
    end
    
    Z=bin2dec(ambil_8lsb);
    R1=mod(Z, 6);
    R2=mod(Z, 11);
    
    if bit_pesan(i) == '1'
        if R1 < R2
            stego(rIdx(i))= Z+Y;
        else
            for j=1:63
                if Z-j>=0
                    Z1=Z-j;
                    R1=mod(Z1, 6);
                    R2=mod(Z1, 11);
                    if R1<R2 
                        stego(rIdx(i))=Z1+Y;
                        break 
                    end
                end
                if Z+j<64
                    Z1=Z+j;
                    R1=mod(Z1, 6);
                    R2=mod(Z1, 11);
                    if R1<R2 
                        stego(rIdx(i))=Z1+Y;
                        break 
                    end
                end
            end
        end
    end
    if bit_pesan(i)=='0'
         if R1>=R2
             stego(rIdx(i))=Z+Y;
         else
             for j=1:63
                 if Z-j>=0
                     Z1=Z-j;
                     R1=mod(Z1, 6);
                     R2=mod(Z1, 11);
                     if R1>=R2 
                         stego(rIdx(i))=Z1+Y;
                         break 
                     end
                 end
                 if Z+j<64
                     Z1=Z+j;
                     R1=mod(Z1, 6);
                     R2=mod(Z1, 11);
                     if R1>=R2 
                         stego(rIdx(i))=Z1+Y;
                         break
                     end
                 end
             end
         end
    end
     
    
end
 
stego=reshape(stego, size(citra));
figure, imshow(citra);


er=double(citra)-double(stego);
MSE=sum(sum(er.^2))/(baris*kolom);
PSNR = 10*log10(255^2/MSE);
PSNR = mean(PSNR)
[mssim,ssim_map]=ssim_index(citra,stego);
mssim

stego = uint8(stego);
imwrite(stego, 'StegoImage.bmp', 'bmp');

figure, imshow(stego);
      
%EKSTRASI===========================================
bit_pesan2=[];
for i=1:numel(bit_pesan)
    X = dec2bin(stego(rIdx(i)), 8);
    ambil_8lsb=X(3:8);
    Z=bin2dec(ambil_8lsb);
    R1=mod(Z, 6);
    R2=mod(Z, 11);
    
    if R1 >= R2
        ambil_bit='0';
    elseif R1 < R2
        ambil_bit='1';
    end 
    bit_pesan2=[bit_pesan2 ambil_bit];
end

pesan=[];
for i=1:8:numel(bit_pesan)
    desimal = bin2dec(bit_pesan2(i:i+7));
    pesan=[pesan char(desimal)];
end
disp(['Hasil Eksrasi Pesan= ', pesan]);    
    
    