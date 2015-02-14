//
//  ViewController.m
//  SDMineSweeper
//
//  Created by sdong on 2/12/15.
//  Copyright (c) 2015 SD. All rights reserved.
//

#import "ViewController.h"

#define LEVEL_ONE_BOARD_SIZE 8
#define LEVEL_TWO_BOARD_SIZE 16
#define LEVEL_THREE_BOARD_SIZE 32
#define NUMBER_OF_COLUMNS_PER_SCREEN 8
#define NUMBER_OF_MINES_PER_LEVEL 10

#define NAVBAR_HEIGHT 60
#define LEAST_SPACE 60
#define NAVBAR_TITLE_VIEW_HEIGHT NAVBAR_HEIGHT-10
#define NAVBAR_TITLE_VIEW_BUTTON_HEIGHT NAVBAR_HEIGHT-20

#define LEVEL_ONE    1
#define LEVEL_TWO    2
#define LEVEL_THREE  3


#define ZERO_VALUE  0
#define ONE_VALUE   1
#define TWO_VALUE   2
#define THREE_VALUE 3
#define FOUR_VALUE  4
#define FIVE_VALUE  5
#define SIX_VALUE   6
#define SEVEN_VALUE 7
#define EIGHT_VALUE 8
#define MINE_VALUE  9

#define STATE_CLOSE     0
#define STATE_OPEN      1
#define STATE_FLAG      2
#define STATE_QUESTION  3
#define STATE_EMPTY     4
#define STATE_NUMBER    5
#define STATE_EXPLODE   6

#define TAG_START 100000


@interface ViewController()<UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray * board;
@property (nonatomic, strong)  UINavigationBar *navBar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong)  UIButton *resetButton;
@property (nonatomic, strong)  UIBarButtonItem *levelButton;
@property (nonatomic, strong) NSString * gameLevelLabel;
@property (nonatomic) CGFloat mineBoardToScreenBottomSpace;
@property (nonatomic) int mineSizePerRow;
@property (nonatomic) int gameLevel;
@property BOOL win;
@property BOOL gameOver;

@end

@implementation ViewController

-(UIScrollView *)scrollView{
  if(!_scrollView){
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
  }
  return _scrollView;
}

-(NSMutableArray *)board{
  if(!_board){
    _board = [[NSMutableArray alloc] initWithCapacity:self.mineSizePerRow];
    for(int i=0; i<self.mineSizePerRow; ++i){
      _board[i] = [[NSMutableArray alloc] initWithCapacity:self.mineSizePerRow];
    }
  }
  return _board;
}



-(int) getBoardValueAtRow:(int)row column:(int)col{
  if(row>=0 && row<self.mineSizePerRow && col>=0 && col<self.mineSizePerRow){
    NSMutableArray * arr = (NSMutableArray *)([self.board objectAtIndex:row]);
    return (int)[(NSNumber*)([arr objectAtIndex:col]) integerValue];
  }
  else return -1;
  
}


-(void)setValueAtRow:(int)x column:(int)y{
  int sum = 0;
  NSMutableArray * arr = (NSMutableArray *)([self.board objectAtIndex:x]);
  if([[arr objectAtIndex:y] integerValue] == MINE_VALUE)
    return;
  
  if ([self getBoardValueAtRow:x-1 column:y-1] == MINE_VALUE) sum+=1;
  if ([self getBoardValueAtRow:x-1 column:y] == MINE_VALUE) sum+=1;
  if ([self getBoardValueAtRow:x-1 column:y+1] == MINE_VALUE) sum+=1;
  if ([self getBoardValueAtRow:x column:y-1] == MINE_VALUE) sum+=1;
  if ([self getBoardValueAtRow:x column:y+1] == MINE_VALUE) sum+=1;
  if ([self getBoardValueAtRow:x+1 column:y-1] == MINE_VALUE) sum+=1;
  if ([self getBoardValueAtRow:x+1 column:y] == MINE_VALUE) sum+=1;
  if ([self getBoardValueAtRow:x+1 column:y+1] == MINE_VALUE) sum+=1;
  [arr replaceObjectAtIndex:y withObject:[NSNumber numberWithInt:sum]];
}

-(void)initBoard{
  for(int i=0; i<self.mineSizePerRow; ++i)
    for(int j=0; j<self.mineSizePerRow; ++j){
      [[self.board objectAtIndex:i] addObject:[NSNumber numberWithInt:ZERO_VALUE]];
    }
}


-(void) initBoardValue {
  int range = [[self.board objectAtIndex:0] count];
  int i = 0;
  while(i < NUMBER_OF_MINES_PER_LEVEL*self.gameLevel){
    int x = arc4random_uniform(range);
    int y = arc4random_uniform(range);
    NSMutableArray  *arr = (NSMutableArray*)([self.board objectAtIndex:x]);
    int val = [self getBoardValueAtRow:x column:y];
    if(val != MINE_VALUE){
      [arr replaceObjectAtIndex : y withObject:[NSNumber numberWithInt:MINE_VALUE]];
      ++i;
    }
  }
  
  for(int i=0; i<self.mineSizePerRow; ++i){
    for(int j=0; j<self.mineSizePerRow; ++j){
      [self setValueAtRow : i column:j];
    }
  }
}

- (void)viewDidLoad {
  self.gameLevel = LEVEL_ONE;
  self.gameLevelLabel = @"Easy";
  
  [super viewDidLoad];
  [self resetBoard];
}

-(void)setNavigation{
  CGRect screenRect = [self.view bounds];
  CGFloat screenWidth = screenRect.size.width;
  self.navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, NAVBAR_HEIGHT)];
  [self.view addSubview:self.navBar];
  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"Cheat"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(drawBoard)];
  UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
  item.rightBarButtonItem = backButton;
  item.hidesBackButton = YES;
  [self.navBar pushNavigationItem:item animated:NO];
  
  
  self.levelButton = [[UIBarButtonItem alloc]initWithTitle:self.gameLevelLabel
                                                     style:UIBarButtonItemStylePlain
                                                    target:self action:@selector(setLevel)];
  item.leftBarButtonItem = self.levelButton;
  item.hidesBackButton = YES;
  [self.navBar pushNavigationItem:item animated:NO];
  
  
  
  
  UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NAVBAR_TITLE_VIEW_HEIGHT, NAVBAR_TITLE_VIEW_HEIGHT)];
  buttonContainer.backgroundColor = [UIColor clearColor];
  self.resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.resetButton setFrame:CGRectMake(0, 0, 44, 44)];
  [self.resetButton setBackgroundImage:[UIImage imageNamed:@"smile.png"] forState:UIControlStateNormal];
  [self.resetButton addTarget:self action:@selector(doResetBoard:) forControlEvents:UIControlEventTouchUpInside];
  [self.resetButton setShowsTouchWhenHighlighted:YES];
  [buttonContainer addSubview:self.resetButton];
  
  item.titleView = buttonContainer;
  
}

-(void)setScrollViewCenter{
  CGFloat newContentOffsetX = (self.scrollView.contentSize.width - self.scrollView.frame.size.width) / 2;
  self.scrollView.contentOffset = CGPointMake(newContentOffsetX, 0);
}

-(void)holdDown{
  if(!self.gameOver){
    NSLog(@"hold   down---");
    [self.resetButton setBackgroundImage:[UIImage imageNamed:@"suprise.png"] forState:UIControlStateNormal];
  }
}
-(void)holdRelease{
  if(!self.gameOver){
    NSLog(@"hold   Release---");
    [self.resetButton setBackgroundImage:[UIImage imageNamed:@"smile.png"] forState:UIControlStateNormal];
  }
}
-(void)setScrollViewSize{
  
  CGRect screenRect = [[UIScreen mainScreen] bounds];;
  CGFloat boardWidth = screenRect.size.width;
  CGFloat boardHeight = screenRect.size.height;
  
  if(self.mineSizePerRow * [self getMineSquareWidth] > boardWidth){
    boardWidth = self.mineSizePerRow * [self getMineSquareWidth];
  }
  
  if(boardWidth + 2*LEAST_SPACE+NAVBAR_HEIGHT > boardHeight)
    boardHeight = boardWidth+2*LEAST_SPACE+NAVBAR_HEIGHT;
  self.mineBoardToScreenBottomSpace = (boardHeight-NAVBAR_HEIGHT-boardWidth)/2;
  self.scrollView.contentSize = CGSizeMake(boardWidth, boardHeight);
}

-(void)clearBoard{
  self.board = nil;
  [self.scrollView removeFromSuperview];
  [self.navBar removeFromSuperview];
  self.scrollView = nil;
}
-(void)doResetBoard:(id)sender{
  NSLog(@"press goback");
  [self resetBoard];
}

- (CGFloat) window_height {
  return [UIScreen mainScreen].applicationFrame.size.height;
}

- (CGFloat) window_width {
  return [UIScreen mainScreen].applicationFrame.size.width;
}


-(CGFloat)getMineSquareWidth{
  
  CGFloat screenWidth = [self window_width];
  NSLog(@"screenwidth:%lf square size : %lf", screenWidth, screenWidth/NUMBER_OF_COLUMNS_PER_SCREEN);
  return screenWidth/NUMBER_OF_COLUMNS_PER_SCREEN;
}

- (void)resetBoard{
  [self clearBoard];
  self.gameOver = NO;
  self.scrollView = nil;
  
  if(self.gameLevel == LEVEL_ONE){
    self.mineSizePerRow = LEVEL_ONE_BOARD_SIZE;
    self.gameLevelLabel = @"Easy";
  }
  else if(self.gameLevel == LEVEL_TWO){
    self.mineSizePerRow = LEVEL_TWO_BOARD_SIZE;
    self.gameLevelLabel = @"Medium";
  }
  else if(self.gameLevel == LEVEL_THREE){
    self.mineSizePerRow = LEVEL_THREE_BOARD_SIZE;
    self.gameLevelLabel = @"Hard";
  }
  
  [self initBoard];
  [self initBoardValue];
  
  self.scrollView.backgroundColor = [UIColor lightTextColor];
  self.scrollView.scrollEnabled = YES;
  self.scrollView.showsVerticalScrollIndicator = YES;
  self.scrollView.showsHorizontalScrollIndicator = YES;
  [self setScrollViewSize];
  
  
  [self.view addSubview:self.scrollView];
  
  [self setNavigation];
  
  self.win = NO;
  
  CGFloat mineWidth = [self getMineSquareWidth];
  for(int row=0; row< self.mineSizePerRow; ++row)
    for(int col=0; col< self.mineSizePerRow; ++col){
      UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      
      
      CGRect frame = CGRectMake(row * mineWidth,
                                col * mineWidth + NAVBAR_HEIGHT + self.mineBoardToScreenBottomSpace,
                                mineWidth,
                                mineWidth);
      button.tag = TAG_START + row * 100 + col;
      
      [button setFrame:frame];
      
      [button addTarget:self
                 action:@selector(mineSquarePressed:)
       forControlEvents:UIControlEventTouchUpInside];
      UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mineSquareLongPressed:)];
      
      [button addGestureRecognizer:longPress];
      NSLog(@"-------");
      button.status = [NSNumber numberWithInt:STATE_CLOSE];
      button.layer.borderWidth=1.0f;
      button.layer.borderColor=[[UIColor whiteColor] CGColor];
      
      UIImage *btnImage = [UIImage imageNamed:@"unopen.png"];
      [button setBackgroundImage:btnImage forState:UIControlStateNormal];
      button.contentMode = UIViewContentModeScaleAspectFit;
      
      [self.scrollView addSubview:button];
    }
}

- (void)mineSquareLongPressed:(UILongPressGestureRecognizer*)gesture {
  if(self.gameOver) return;
  
  UIButton *button = (UIButton*)(gesture.view);
  int x = (int)(button.tag-TAG_START)/100;
  int y = (int)(button.tag-TAG_START)%100;
  int val = [self getBoardValueAtRow:x column:y];
  if ( gesture.state == UIGestureRecognizerStateEnded ) {
    int buttonStatus = [(NSNumber*)button.status integerValue];
    if(buttonStatus == STATE_CLOSE){
      UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"flag.png", val]];
      [button setBackgroundImage:image forState:UIControlStateNormal];
      //button.status = STATE_NUMBER;
      button.status = [NSNumber numberWithInt:STATE_FLAG];
    }
    else if(buttonStatus == STATE_FLAG){
      UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"question.png", val]];
      [button setBackgroundImage:image forState:UIControlStateNormal];
      //button.status = STATE_NUMBER;
      button.status = [NSNumber numberWithInt:STATE_QUESTION];
    }
    else if(buttonStatus == STATE_QUESTION){
      UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"unopen.png", val]];
      [button setBackgroundImage:image forState:UIControlStateNormal];
      //button.status = STATE_NUMBER;
      button.status = [NSNumber numberWithInt:STATE_CLOSE];
    }
    
  }
  
  [self checkWin];
  
  if(self.gameOver){
    [self gameIsOver:YES];
  }
}

-(BOOL)checkWin{
  int flags = 0;
  int unOpenMines = 0;
  
  int mines = NUMBER_OF_MINES_PER_LEVEL * self.gameLevel;
  int flakeFlags =0;
  int questionFlags =0;
  
  for(int i=0; i<self.mineSizePerRow; ++i)
    for(int j=0; j<self.mineSizePerRow; ++j){
      UIButton *button = (UIButton *)[self.scrollView viewWithTag:TAG_START+100*i+j];
      int buttonStatus = [(NSNumber*)button.status integerValue];
      
      int val = [self getBoardValueAtRow:i column:j];
      if(buttonStatus ==STATE_FLAG){
        if(val==MINE_VALUE){
          flags+=1;
        }
        else{
          flags-=1;
          
          flakeFlags+=1;
        }
      }
      if(buttonStatus ==STATE_QUESTION){
        questionFlags+=1;
        
      }
      if(buttonStatus ==STATE_CLOSE){
        unOpenMines+=1;
      }
    }
  NSLog(@"Yes It here");
  if(questionFlags ==0
     && flakeFlags==0
     &&( (flags==mines )
        || (flags+unOpenMines==mines)
        ||(flags==0 && unOpenMines==mines)
        )
     ){
    self.win = YES;
    self.gameOver = YES;
    NSLog(@"Game: you should have won here");
    return YES;
  }
  return NO;
}

-(void)setLevel{
  if(self.gameLevel == LEVEL_ONE){
    self.gameLevel = LEVEL_TWO;
    [self.levelButton setTitle: @"Medium"];
    
    self.mineSizePerRow = LEVEL_TWO_BOARD_SIZE;
  }
  else if(self.gameLevel == LEVEL_TWO){
    self.gameLevel = LEVEL_THREE;
    [self.levelButton setTitle: @"Hard"];
    
    self.mineSizePerRow = LEVEL_THREE_BOARD_SIZE;
    
  }
  else if(self.gameLevel == LEVEL_THREE){
    self.gameLevel = LEVEL_ONE;
    [self.levelButton setTitle: @"Easy"];
    self.mineSizePerRow = LEVEL_ONE_BOARD_SIZE;
  }
  [self resetBoard];
}

-(void)drawBoard{
  
  for(int i=0; i<self.mineSizePerRow; ++i)
    for(int j=0; j<self.mineSizePerRow; ++j){
      int val = [self getBoardValueAtRow:i column:j];
      UIButton *button = (UIButton *)[self.scrollView viewWithTag:TAG_START+100*i+j];
      int buttonStatus = [(NSNumber*)button.status integerValue];
      if(buttonStatus == STATE_CLOSE || buttonStatus == STATE_QUESTION){
        if(val == MINE_VALUE){
          UIImage * image = [UIImage imageNamed:@"bomb.png"];
          [button setBackgroundImage:image forState:UIControlStateNormal];
        }
      }
      if(buttonStatus == STATE_FLAG){
        if(val!=MINE_VALUE){
          UIImage * image = [UIImage imageNamed:@"failed_flag.png"];
          [button setBackgroundImage:image forState:UIControlStateNormal];
        }
        if(val!=MINE_VALUE){
          UIImage * image = [UIImage imageNamed:@"bomb.png"];
          [button setBackgroundImage:image forState:UIControlStateNormal];
        }
      }
      
    }
}

-(void)mineSquarePressed:(id)sender{
  if(self.gameOver)
    return;
  
  UIButton *button = (UIButton*)sender;
  int x = (int)(button.tag-TAG_START)/100;
  int y = (int)(button.tag-TAG_START)%100;
  
  [self traversalAtRow:x column:y];
  
  [self checkWin];
  
  if(self.gameOver){
    [self gameIsOver:YES];
  }
  
  NSLog(@"pressed (%d, %d)", x, y);
}

-(void)gameIsOver:(BOOL)gameOver {
  [self drawBoard];
  NSString *msg = @"Let's try it again?" ;
  NSString *title = @"Sorry";
  if(self.win){
    msg = @"You Win!";
    title = @"Congratulations!";
    [self.resetButton setBackgroundImage:[UIImage imageNamed:@"win.png"] forState:UIControlStateNormal];
    
  }
  else{
    [self.resetButton setBackgroundImage:[UIImage imageNamed:@"cry.png"] forState:UIControlStateNormal];
  }
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:msg
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Retry", nil];
  [alert show];
}

-(void)traversalAtRow:(int)x  column:(int)y {
  if(x<0 || x>=self.mineSizePerRow || y<0 ||y>=self.mineSizePerRow)
    return;
  if(self.win == YES)
    return;
  UIButton * button = (UIButton*)[self.scrollView viewWithTag:TAG_START+100*x+y];
  int buttonStatus = [(NSNumber*)button.status integerValue];
  if(  buttonStatus == STATE_CLOSE){
    
    int x = (int)(button.tag-TAG_START)/100;
    int y = (int)(button.tag-TAG_START)%100;
    
    
    int val = [self getBoardValueAtRow:x column:y];
    
    NSLog(@"the value is %d", val);
    if(ZERO_VALUE<val && val<=EIGHT_VALUE){
      UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", val]];
      [button setBackgroundImage:image forState:UIControlStateNormal];
      //button.status = STATE_NUMBER;
      button.status = [NSNumber numberWithInt:STATE_NUMBER];
      return;
    }
    
    if(val == MINE_VALUE){
      UIImage * image = [UIImage imageNamed:@"explode.png"];
      [button setBackgroundImage:image forState:UIControlStateNormal];
      button.status = [NSNumber numberWithInt:STATE_EXPLODE];
      self.gameOver = YES;
      //[self gameIsOver:YES];
      return;
    }
    
    if(ZERO_VALUE == val){
      UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", val]];
      [button setBackgroundImage:image forState:UIControlStateNormal];
      button.status = [NSNumber numberWithInt:STATE_EMPTY];
    }
    
    NSLog(@"pressed (%d, %d)", x, y);
    
    
    [self traversalAtRow:x column:y-1];
    [self traversalAtRow:x column:y+1];
    [self traversalAtRow:x-1 column:y];
    [self traversalAtRow:x+1 column:y];
  }
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


#pragma mark - alertDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  if (buttonIndex == 0) {// 1st Other Button
    
  }
  else if (buttonIndex == 1) {// 2nd Other Button
    [self resetBoard];
  }
  
}

@end
