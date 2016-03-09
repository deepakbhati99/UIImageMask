# UIImageMask
a image masking sample application which shows the how to mask a image on another

# SCREENSHOT
![Alt text](https://github.com/deepakbhati99/ios_video_filters/blob/master/SCREENSHOT_IMG_3301.PNG "Screeshot #1")

    -(UIImage *)maskImageWithImage:(UIImage *)inputImage andMaskImage:(UIImage *)maskImage
    {
    
        /*
     
         inputImage   - > imageToBeMasked
         maskImage    - > masking Image
     
        */
    
      CGImageRef maskRef;
    
        if (switchImageMasking.on) {
        
            maskRef = maskImage.CGImage;
        
         }else{
        
            // swapping images
        
           UIImage *temp = inputImage;
        
           inputImage = maskImage;
        
            maskRef = temp.CGImage;
        
        }
    
        //creating the mask image
    
       CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, true);
    
       //masking of both images
       
        CGImageRef masked = CGImageCreateWithMask([inputImage CGImage], mask);
        
        CGImageRelease(mask);
    
        //creating the masked/final image
        UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    
        CGImageRelease(masked);
    
        return maskedImage;
    }
