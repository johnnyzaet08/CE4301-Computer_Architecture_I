clc;
clear;
close all;

pkg load image;
pkg load video;

% Leer la imagen
A = imread('barbara.jpg');
A = imresize(A,[128,128]);
subplot(1,2,1);
imshow(A);

% Extraemos los parámetros
[m,n,r] = size(A);

% Período y amplitudes
Lx = 75;
Ly = 75;

% Primer frame
Y(:,:,:,1) = A;

for k = 5:5:200
  Ax = k;
  Ay = k;
  % Genera una imagen en blanco
  B = uint8(zeros(m,n,r));
  for x = 1:m
    for y = 1:n
      xnew = mod(round(x + Ax * sin(2 * pi * y / Lx)), m);
      xaux = round(x + Ax * sin(2 * pi * y / Lx));
      ynew = mod(round(y + Ay * sin(2 * pi * x / Ly)), n);
      yaux = round(y + Ay * sin(2 * pi * x / Ly));
      if and(xnew == xaux,ynew == yaux)
        B(xnew + 1, ynew +1,:) = A(x,y,:);
      endif
    endfor
  endfor
  subplot(1,2,2);
  imshow(B);
  pause(0.1);
  Y(:,:,:,k / 5 + 1) = B;
endfor

%Crea vídeo
%video = VideoWriter('yourvideo.avi');
%open(video);
%k = length(5:5:200) + 1;
%for i = 1:k
%  C = Y(:,:,:,i);
%  for j = 1:7
%    writeVideo(video,C);
%  endfor
%endfor
