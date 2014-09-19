# AWTabBarController v0.1

Is simple file.

UITabBarController + swipe + autolayout

![](https://raw.githubusercontent.com/saintevil/uibabbarcontroller-swipeview/master/readme_file/sc1.png)

![](https://raw.githubusercontent.com/saintevil/uibabbarcontroller-swipeview/master/readme_file/sc2.png)

# How To Using

Look up "FirstViewController.m"


```objective-c
    AWTabBarController * tbc = (AWTabBarController*)(self.tabBarController);

    NSMutableArray * array = [NSMutableArray array];
    for (long i = 0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [array addObject:button];

        [button setTitle:[NSString stringWithFormat:@"btn %ld", i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.8 alpha:1];// buttoncolors
    }
    tbc.view.backgroundColor = [UIColor whiteColor];

    tbc.selectedSegmentColor = [UIColor redColor];
    tbc.customSegmentButtons = array;

```

## License

"License.txt" 파일 참조 MIT Liscence.
