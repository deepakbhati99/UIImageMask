//
//  imageViewController.m
//  HKMaskImage
//
//  Created by Himanshu Khatri on 3/5/16.
//  Copyright © 2016 bdAppManiac. All rights reserved.
//

#import "imageViewController.h"

@interface imageViewController ()<UICollectionViewDelegate>{
    
    IBOutlet UIImageView *imageView;
    NSArray *array;
    IBOutlet UISwitch *switchImageMasking;
    NSIndexPath *savedIndexPath;
    UIImage *bgImage;
    IBOutlet UICollectionView *collectionView;
    NSMutableArray *arrayIPsWithBool; //array for maintaining the record of action
}

@end

@implementation imageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    array = @[@"image6",@"image21",@"image20",@"image7",@"image9",@"image10",@"image12",@"image13",@"image17",@"image18",@"image19"];
    
    savedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    NSDictionary *dic  = @{
                           @"indexPath":savedIndexPath,
                           @"boolValue":[NSNumber numberWithBool:YES]
                           };
    
    arrayIPsWithBool =[NSMutableArray new];
    [arrayIPsWithBool addObject:dic];
    
    bgImage = [UIImage imageNamed:@"bg2.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *)maskImageWithImage:(UIImage *)inputImage andMaskImage:(UIImage *)maskImage{
    
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

#pragma mark- IBActions
- (IBAction)switchChangedValue:(id)sender {
  
    [self collectionView:collectionView didSelectItemAtIndexPath:savedIndexPath];
    

    
    NSArray *ips = [collectionView indexPathsForVisibleItems];
    [collectionView reloadItemsAtIndexPaths:ips];
}
- (IBAction)undo:(id)sender {
    
    if (arrayIPsWithBool.count == 1) {
        return;
    }
    
    [arrayIPsWithBool removeLastObject];
    savedIndexPath = arrayIPsWithBool.lastObject[@"indexPath"];
    
    [switchImageMasking setOn:[arrayIPsWithBool.lastObject[@"boolValue"] boolValue] animated:YES];
    
    
    
    imageView.image = [self maskImageWithImage:bgImage andMaskImage:[UIImage imageNamed:array[savedIndexPath.row]]];
    
    NSArray *ips = [collectionView indexPathsForVisibleItems];
    [collectionView reloadItemsAtIndexPaths:ips];
}

- (IBAction)selectNewImage:(id)sender {
    
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"select your prefered method" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Camera", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                                   
                                   UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                   if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                   {
                                       imagePicker.delegate = (id)self;
                                       imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                       imagePicker.allowsEditing=NO;
                                       [self.navigationController presentViewController:imagePicker animated:YES completion:^{
                                           self.navigationController.navigationBarHidden=NO;
                                       }];
                                       
                                   }else{
                                   }
                               }];
    UIAlertAction *LibraryAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Library", @"OK action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        NSLog(@"OK action");
                                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                        imagePicker.delegate = (id)self;
                                        imagePicker.allowsEditing = NO;
                                        
                                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

                                        [self.navigationController presentViewController:imagePicker animated:YES completion:^{
                                            self.navigationController.navigationBarHidden=NO;
                                        }];
                                        
                                    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [alertController addAction:LibraryAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
#pragma mark -
#pragma mark UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   //dismissing the picker
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
    //set image
    imageView.image = bgImage = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    savedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    NSDictionary *dic  = @{
                           @"indexPath":savedIndexPath,
                           @"boolValue":[NSNumber numberWithBool:YES]
                           };
    
    arrayIPsWithBool =[NSMutableArray new];
    [arrayIPsWithBool addObject:dic];
    
    NSArray *ips = [collectionView indexPathsForVisibleItems];
    [collectionView reloadItemsAtIndexPaths:ips];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark- UICollectionView DataSource & Delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return array.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell =[collectionView1 dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *maskImgView = [cell.contentView viewWithTag:99];
    
    maskImgView.image = [self maskImageWithImage:bgImage andMaskImage:[UIImage imageNamed:array[indexPath.row]]];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    savedIndexPath =indexPath;
    imageView.image = [self maskImageWithImage:bgImage andMaskImage:[UIImage imageNamed:array[indexPath.row]]];
    
    NSDictionary *dic  = @{
                           @"indexPath":savedIndexPath,
                           @"boolValue":[NSNumber numberWithBool:switchImageMasking.on]
                           };
    
    [arrayIPsWithBool addObject:dic];
    
}


@end
