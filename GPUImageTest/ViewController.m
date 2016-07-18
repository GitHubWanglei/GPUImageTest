//
//  ViewController.m
//  GPUImageTest
//
//  Created by lihongfeng on 16/7/18.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

@interface ViewController ()
@property (nonatomic, strong) UIImage *inputImg;
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImage *inputImage = [UIImage imageNamed:@"image.jpg"];
    self.inputImg = inputImage;
    
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 300)];
//    imgV.image = [self processBrightnessFilterImage:inputImage brightness:-0.5];
    imgV.image = [self applyGaussianBlur:inputImage radius:0];
    [self.view addSubview:imgV];
    self.imgView = imgV;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(imgV.frame)+30, 280, 30)];
    slider.maximumValue = 1;
    slider.minimumValue = 0;
    slider.value = 0;
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)valueChanged:(UISlider *)slider{
//    self.imgView.image = [self processBrightnessFilterImage:self.inputImg brightness:slider.value];
//    self.imgView.image = [self applyGaussianBlur:self.inputImg radius:slider.value];
    self.imgView.image = [self applyGaussianSelectiveBlur:self.inputImg radius:slider.value];
}

//亮度
- (UIImage *)processBrightnessFilterImage:(UIImage *)image brightness:(CGFloat)brightness{
    
    GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
    filter.brightness = brightness;
    [filter forceProcessingAtSize:image.size];
    [filter useNextFrameForImageCapture];
    GPUImagePicture *source  = [[GPUImagePicture alloc] initWithImage:image];
    [source addTarget:filter];
    [source processImage];
    UIImage *outputImage = [filter imageFromCurrentFramebuffer];
    return outputImage;
    
}

//模糊
- (UIImage *)applyGaussianBlur:(UIImage *)image radius:(CGFloat)radius{
    GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
    filter.blurRadiusInPixels = radius;
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}

//局部模糊
- (UIImage *)applyGaussianSelectiveBlur:(UIImage *)image radius:(CGFloat)radius{
    GPUImageGaussianSelectiveBlurFilter *filter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
    
    //    filter.texelSpacingMultiplier = 5.0;
    
    filter.excludeCircleRadius = radius;
    
    [filter forceProcessingAtSize:image.size];
    
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    
    [pic addTarget:filter];
    
    [pic processImage];
    
    [filter useNextFrameForImageCapture];
    
    return [filter imageFromCurrentFramebuffer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
