clc;
clear;
close all;


addpath('NetModel\')

kernel              = im2double(imread('kernel.png'));
I0                  = im2double(imread('test.png'));

randn('seed',0);
noise               = 1e-2;

Im                  = imfilter(I0,kernel,'circular','conv') + noise*randn(size(I0));
kdims               = size(kernel);
bndry               = (kdims-1)/2;
net_idx             = 7; % This paramter is related to the noise intensity.
eta                 = 1e-2;
lambda              = 1e-1;
theta               = 1e-2;
bound_kfomega.left  = max(ceil(min(Im(:))*100)/100,0);
bound_kfomega.right = min(floor(max(Im(:))*10)/10,1);

maxStage            = 5;

PSNR_input = psnr(Im, I0);
SSIM_input = ssim(Im, I0);
fprintf('psnr_input = %f\nssim_input = %f \n',PSNR_input,SSIM_input);

[w,h,c]             = size(Im);
V                   = psf2otf(kernel,[w,h]);
KtK                 = abs(V).^2;
KtY                 = real(ifft2(conj(V).*fft2(Im)));
blurpad             = Im;

x_deblur = dpe(KtY,KtK,blurpad,net_idx,eta,lambda,theta,bound_kfomega,maxStage);

PSNR_deblur = psnr(x_deblur, I0);
SSIM_deblur = ssim(x_deblur, I0);

fprintf('psnr_deblur = %f\nssim_deblur = %f \n',PSNR_deblur,SSIM_deblur);

subplot(1,2,1)
imshow(Im);title('Blurry Image')
subplot(1,2,2)
imshow(x_deblur);title('Deblurred Image')
