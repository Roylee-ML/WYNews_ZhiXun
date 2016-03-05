//
//  CommonDetailViewController.m
//  WYNews
//
//  Created by lanou3g on 15/5/29.
//  Copyright (c) 2015年 lanou3g. All rights reserved.
//

#import "CommonDetailViewController.h"
#import "UIImageView+WebCache.h"

#import "HttpTool.h"
#import "NewsModel.h"
#import "OnePlayer.h"

#import "MBProgressHUD.h"
#import "PersistManger.h"
#define  Url @"http://c.m.163.com/nc/article/AQMGM91E00031H2L/full.html"
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NC_HEIGHT self.navigationController.navigationBar.frame.size.height
#define SELF_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SELF_HEIGHT [[UIScreen mainScreen]bounds].size.height
//http://c.3g.163.com/nc/article/AQV4I7SA00011229/full.html

@interface CommonDetailViewController ()

@property(nonatomic,strong)MBProgressHUD *progressHUD;
@property(nonatomic,strong)UIActivityIndicatorView * progressIndic;

@end

@implementation CommonDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //title必须设置空，因为item由两部分组成。
    backItem.title = @"";
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    //自定义导航栏
    [[PersistManger defoutManger]setupNavigationViewToVC:self withTitleImg:[UIImage imageNamed:@""] andBGImg:[UIImage imageNamed:NC_IMG]];
    //返回按钮
        [self backToRootView];
    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, NC_HEIGHT+STATUS_HEIGHT, SELF_WIDTH, SELF_HEIGHT-NC_HEIGHT)];
    
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];
    
    [self setupWebView];
    
    //设置进度指示视图
    self.progressIndic = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
/*
    *style三种模式，下面的是大图模式，如有需要可以改变颜色。
    UIActivityIndicatorViewStyleWhiteLarge
    _progressIndic.color = [UIColor grayColor];
 
    *同时，UIActivityIndicatorView的frame属性是没有效果的。
*/
    
    _progressIndic.center = self.view.center;
    
    [self.view addSubview:_progressIndic];
    
    [_progressIndic startAnimating];
}

-(void)setupWebView
{
    NSString * pathString = [NSString stringWithFormat:@"http://c.m.163.com/nc/article/%@/full.html",self.docid];
    NSLog(@"%@",pathString);
    NSURL * requestUrl = [NSURL URLWithString:pathString];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:requestUrl];
    
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary * jsonSource = JSON;
        if (jsonSource) {
            NSDictionary * jsonDic = [NSDictionary dictionaryWithDictionary:jsonSource[self.docid]];
            //正文
            NSString * htmlStr = [jsonDic objectForKey:@"body"];
            //标题
            NSString * titleStr = jsonDic[@"title"];
            //来源
            NSString * sourecStr = jsonDic[@"source"];
            //时间
            NSString * ptimeStr = jsonDic[@"ptime"];
            NSString * ptime = [ptimeStr substringWithRange:NSMakeRange(5, 11)];
            NSLog(@"%@",ptime);
            //描述
            NSString * digestStr = jsonDic[@"digest"];
            
            NSArray * imageArray = jsonDic[@"img"];
            for (int i = 0; i<imageArray.count ;i++) {
                NSString * imgStr = [NSString stringWithFormat:@"<!--IMG#%d-->",i];
                NSString * imgUrl = [imageArray[i] valueForKey:@"src"];
                NSString * sizeStr = [imageArray[i] valueForKey:@"pixel"];
                NSString * altStr = [imageArray[i] valueForKey:@"alt"];
                
                
                float width = [[sizeStr componentsSeparatedByString:@"*"].firstObject floatValue];
                float height = [[sizeStr componentsSeparatedByString:@"*"].lastObject floatValue];
                float imgViewWidth =self.webView.frame.size.width-16;
                float imgViewHeight = imgViewWidth* height/width;
                
                
                NSString * replaceStr = [NSString stringWithFormat:@"<div><br><img src=\"%@\" alt = \"%@\" width=\"%@\" height=\"%@\"></br></div>",imgUrl,altStr,[NSString stringWithFormat:@"%f",imgViewWidth],[NSString stringWithFormat:@"%f",imgViewHeight]];
                NSString * altStr1 = [NSString stringWithFormat:@"<div style = \"font-size:15px;color:#707070;\">%@</div>",altStr];
                NSString * replaceStr1 = [replaceStr stringByAppendingString:altStr1];
                htmlStr = [htmlStr stringByReplacingOccurrencesOfString:imgStr  withString:replaceStr1];
            }
            
            [self.webView loadHTMLString:[NSString stringWithFormat:@"<div style = \"font-size:19px;color:#000000;font-weight:bold\">%@</div><div style = \"font-size:15px;color:#808080;\">%@\t\t\t%@</div></br><div style = \"font-size:15px;color:#808080;\">%@</div><div style = \"font-family:arial,sans-serif;margin: 0; font-weight:normal; word-wrap: break-word;-webkit-user-select: none;text-align:justify;letter-spacing:-0.2px;-webkit-hyphenate-limit-after:1;-webkit-hyphenate-limit-before:1;-webkit-hyphens: auto;\">%@</div><br></br>",titleStr,sourecStr,ptime,digestStr,htmlStr] baseURL:nil];
            self.webView.delegate = self;
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (error) {
            NSLog(@"详情数据下载失败：error ====== %@",error);
        }
    }];
    
    [operation start];
    
}

//返回按钮
-(void)backToRootView
{
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10,STATUS_HEIGHT+SELF_WIDTH/80 ,SELF_WIDTH*1.0/15 , SELF_WIDTH*1.0/15);
    backButton.clipsToBounds = YES;
    backButton.alpha = 0.8;
    backButton.layer.cornerRadius = SELF_WIDTH/30;
    [backButton setBackgroundImage:[[UIImage imageNamed:@"back"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"bobo_top_navigation_back_highlighted@2x.png"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
}
-(void)clickButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [self.progressIndic stopAnimating];
        
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_progressIndic stopAnimating];
    NSLog(@"%@",error);
}


-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushPlayingAudioVC:) name:BackAudioMark object:nil];
}

-(void)pushPlayingAudioVC:(NSNotification*)notification
{
    [[OnePlayer onePlayer]playAudioFromController:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BackAudioMark object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:BackAudioMark object:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 //去掉html中的特殊符号
 //-(NSString *)filterHTML:(NSString *)html
 //{
 //    NSScanner * scanner = [NSScanner scannerWithString:html];
 //    NSString * text = nil;
 //    while([scanner isAtEnd]==NO)
 //    {
 //        //找到标签的起始位置
 //        [scanner scanUpToString:@"<" intoString:nil];
 //        //找到标签的结束位置
 //        [scanner scanUpToString:@">" intoString:&text];
 //        //替换字符
 //        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
 //    }
 //        NSString * regEx = @"<([^>]*)>";
 //        html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
 //    return html;
 //}
 */
//    //h获取当前的 URL
//    NSString * currentUrl = [self.webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
//    NSLog(@"***********%@",currentUrl);
//    NSString * html = [self filterHTML:currentUrl];
//    NSLog(@"--------%@",html);
//    [self.webView stringByEvaluatingJavaScriptFromString:html];
////    [UIApplicationsharedApplication].networkActivityIndicatorVisible =NO;
//    NSString * title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.location.title"];
//    NSLog(@"%@",title);
//    //修改服务器页面的meta的值
//    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", webView.frame.size.width];
//    [self.webView stringByEvaluatingJavaScriptFromString:meta];
//    //给网页增加utf-8编码
//    [self.webView stringByEvaluatingJavaScriptFromString:
//     @"var tagHead =document.documentElement.firstChild;"
//     "var tagMeta = document.createElement(\"meta\");"
//     "tagMeta.setAttribute(\"http-equiv\", \"Content-Type\");"
//     "tagMeta.setAttribute(\"content\", \"text/html; charset=utf-8\");"
//     "var tagHeadAdd = tagHead.appendChild(tagMeta);"];
//    //给网页增加css样式
//    [self.webView stringByEvaluatingJavaScriptFromString:
//     @"var tagHead =document.documentElement.firstChild;"
//     "var tagStyle = document.createElement(\"style\");"
//     "tagStyle.setAttribute(\"type\", \"text/css\");"
//     "tagStyle.appendChild(document.createTextNode(\"BODY{padding: 20pt 15pt}\"));"
//     "var tagHeadAdd = tagHead.appendChild(tagStyle);"];
//    //拦截网页图片  并修改图片大小
//    [self.webView stringByEvaluatingJavaScriptFromString:
//     @"var script = document.createElement('script');"
//     "script.type = 'text/javascript';"
//     "script.text = \"function ResizeImages() { "
//     "var myimg,oldwidth;"
//     "var maxwidth=380;" //缩放系数
//     "for(i=0;i <document.images.length;i++){"
//     "myimg = document.images[i];"
//     "if(myimg.width > maxwidth){"
//     "oldwidth = myimg.width;"
//     "myimg.width = maxwidth;"
//     "myimg.height = myimg.height * (maxwidth/oldwidth);"
//     "}"
//     "}"
//     "}\";"
//     "document.getElementsByTagName('head')[0].appendChild(script);"];
//
//    [self.webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
//[self.activityIndicatorView stopAnimating];
//        NSString *js_fit_code = [NSString stringWithFormat:@"var meta = document.createElement('meta');"
//                                 "meta.name = 'viewport';"
//                                 "meta.content = 'width=device-width, initial-scale=1.0,minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes';"
//                                 "document.getElementsByTagName('head')[0].appendChild(meta);"
//                                 ];
//        [self.webView stringByEvaluatingJavaScriptFromString:js_fit_code];






//-(void)setData
//{
////    NSString *detailString = [self.requestUrl absoluteString];
////     NSLog(@"-------%@",detailString);
////    NSString *baseString = [detailString substringToIndex:17];
////     NSLog(@"%@",baseString);
////    NSString *pathString = [detailString substringFromIndex:17];
////    NSLog(@"%@",pathString);
//
//    NSString * pathString = [NSString stringWithFormat:@"/nc/article/%@/full.html",self.docid];
//    [HttpTool getWithUrl:@"http://c.m.163.com" Path:pathString params:nil success:^(id JSON) {
//
//        NSDictionary *dic = JSON[self.docid];
//        self.bodyTextView.text = [dic objectForKey:@"body"];
//        self.titleLabel.text = [dic objectForKey:@"title"];
//        self.sourceLabel.text = [dic objectForKey:@"source"];
//        NSString * text = [dic objectForKey:@"ptime"] ;
//        NSString * ptimeString = [text substringWithRange:NSMakeRange(5, 11) ];
//        self.ptimeLabel.text =ptimeString ;
//
////        NSLog(@"%@",_bodyLabel.text);
//    } failure:^(NSError *error) {
//        NSLog(@"********%@",error);
//    }];
//}
//请求数据
//    [self setData];
//    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    scrollView.backgroundColor = [UIColor whiteColor];
//    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame)*3);
//    [self.view addSubview:scrollView];
//    //标题
//    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, self.view.frame.size.width, 35)];
//    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
//    [scrollView addSubview:_titleLabel];
//    //来源
//    self.sourceLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(_titleLabel.frame), 120, 30)];
//    self.sourceLabel.backgroundColor = [UIColor whiteColor];
//    self.sourceLabel.font = [UIFont systemFontOfSize:14];
//    [scrollView addSubview:_sourceLabel];
//    //时间
//    self.ptimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_sourceLabel.frame)+5, CGRectGetMaxY(_titleLabel.frame), 150, 30)];
//    self.ptimeLabel.font = [UIFont systemFontOfSize:14];
//
//    self.ptimeLabel.backgroundColor = [UIColor whiteColor];
//    [scrollView addSubview:_ptimeLabel];
//    //正文
//    self.bodyTextView = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_sourceLabel.frame)+20, self.view.frame.size.width, CGRectGetHeight(scrollView.frame)*2)];
//    self.bodyTextView.numberOfLines = 0;
//    self.bodyTextView.backgroundColor = [UIColor whiteColor];
//    [scrollView addSubview:_bodyTextView];
//    NSData * htmlData = [[NSData alloc]initWithContentsOfURL:requestUrl];
//    TFHpple * pathParper = [[TFHpple alloc]initWithHTMLData:htmlData];
//    NSArray * array = [pathParper searchWithXPathQuery:@"//p"];
//    for (TFHppleElement * element in array) {
//        //        if ([[element objectForKey:@"class"]isEqualToString:@"c_b_p_desc"]) {
//        //            NSLog(@"%@",element.text);
//        //        }
//        NSLog(@"-----------------%@",element.text);
//    }

@end
