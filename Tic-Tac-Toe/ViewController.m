//
//  ViewController.m
//  Tic-Tac-Toe
//
//  Created by Rumin on 12/19/17.
//  Copyright © 2017 Rumin. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

bool activeGame;
NSInteger activePlayer;
const NSInteger board_dimension = 4;

typedef NS_ENUM(NSInteger, Square) {
    SquareEmpty,
    SquareX,
    SquareO
};

Square board[board_dimension][board_dimension];

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIView *imgview_shadow;
@property (strong, nonatomic) IBOutlet UIImageView *imgView_currentPlayer;
@property (strong, nonatomic) IBOutlet UIView *view_square;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imgview_shadow.layer.masksToBounds = NO;
    self.imgview_shadow.layer.shadowOffset = CGSizeMake(0, 4);
    self.imgview_shadow.layer.shadowRadius = 5;
    self.imgview_shadow.layer.shadowOpacity = 0.4;
    
    
    arr_gameStates = [NSMutableArray array];
    
    
    for (NSInteger i = 0; i < 16; i++)
    {
        [arr_gameStates addObject:[NSNumber numberWithInteger:0]]; // 0 - empty, 1 - filled
    }
    
    
    activePlayer = SquareX;
    activeGame = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Mark Square
- (IBAction)btnPressed:(UIButton*)sender {
    
    
    NSInteger activePosition = sender.tag - 1;
    
    // Check if slot is filled
    if ([arr_gameStates objectAtIndex:activePosition] == [NSNumber numberWithInteger:0] && activeGame)
    {
        
        [arr_gameStates replaceObjectAtIndex:activePosition withObject:[NSNumber numberWithInteger:1]]; // Mark the slot as filled
        
        
        // Change active players
        
        if (activePlayer == SquareX) {
            
            [sender setImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
            
            
        } else {
            
            [sender setImage:[UIImage imageNamed:@"nought.png"] forState:UIControlStateNormal];
            
        }
        
        [self makeMoveAt:activePosition]; //Mark the square on a board with the current player
        
        // Check Who wins
        if ([self checkWinner])
        {
            activeGame = NO;
            NSString *winnerString = [NSString stringWithFormat:@"Player %ld Wins!",(long)activePlayer];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game Over" message:winnerString preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self createNewGame];
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        
        // Check Draw
        else if ([self checkDraw])
        {
            activeGame = NO;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game Over" message:@"Draw!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self createNewGame];
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
}

#pragma mark - Mark User Move
-(void)makeMoveAt:(NSInteger)square {
   
    NSInteger row = square / board_dimension;
    NSInteger col = square % board_dimension;
    board[row][col] = activePlayer;
    
}

#pragma mark - Decide Winner

-(BOOL) checkWinner {
    Square square= activePlayer;
    
    //Check for a win condition
    BOOL winner = ([self checkLeftDiagonal:square] ||
                   [self checkRightDiagonal:square] ||
                   [self checkFourCorners:square] ||
                   [self checkHorizAndVert:square] ||
                   [self checkFourSquare:square]);
    
    if (winner) {
        
    } else {
        
        //Change active player
        if (activePlayer == SquareX)
        {
            activePlayer = SquareO;
            _imgView_currentPlayer.image = [UIImage imageNamed:@"nought.png"];
        }
        else
        {
            activePlayer = SquareX;
            _imgView_currentPlayer.image = [UIImage imageNamed:@"cross.png"];
        }
        
    }
    return winner;

}

#pragma mark- Check Draw
-(BOOL)checkDraw{
    for (int i = 0; i < board_dimension; i++) {
        for (int j = 0; j < board_dimension; j++) {
            if (board[i][j] == SquareEmpty)
                return NO;
        }
    }
    return YES;
    
}

#pragma mark - Check Left Diagonal
-(BOOL) checkLeftDiagonal:(Square) square {
    for (int i = 0; i < board_dimension; i++) {
        if (board[i][i] != square)
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Check Right Diagonal
-(BOOL) checkRightDiagonal:(Square) square  {
    for (int i = 0; i < board_dimension; i++) {
        if (board[i][board_dimension-i-1] != square) return NO;
    }
    return YES;
}

#pragma mark - Check Four Corners
-(BOOL) checkFourCorners:(Square) square  {
    
    return (board[0][0] == square
            && board[0][board_dimension-1] == square
            && board[board_dimension-1][0] == square
            && board[board_dimension-1][board_dimension-1] == square);
    
}

#pragma mark - Check Horizontally or Vertically
-(BOOL) checkHorizAndVert:(Square) square {
    for (int i = 0; i < board_dimension; i++) {
        if ([self checkThisRow:square atRow:i])
            return YES;
        if ([self checkThisColumn:square atCol:i])
            return YES;
    }
    return NO;
}

-(BOOL) checkThisRow:(Square) square atRow:(NSInteger)row {
    for (int col = 0; col < board_dimension; col++) {
        if (board[row][col] != square) return NO;
    }
    return YES;
}

-(BOOL) checkThisColumn:(Square) square atCol:(NSInteger)col {
    for (int row = 0; row < board_dimension; row++) {
        if (board[row][col] != square) return NO;
    }
    return YES;
}

#pragma mark - Check 2 x 2 Square
-(BOOL) checkFourSquare:(Square) square {
    for (int r = 0; r < board_dimension-1; r++) {
        for (int c = 0; c < board_dimension-1; c++) {
            if (board[r][c] == square && board[r][c+1] == square
                && board[r+1][c] == square && board[r+1][c+1] == square)
                return YES;
        }
        
    }
    return NO;
    
}

#pragma mark - New Game
- (IBAction)btn_newGamePressed:(UIButton *)sender {
    
    [self createNewGame];
}

- (void) createNewGame
{
    for (int i = 0; i < board_dimension; i++) {
        for (int j = 0; j < board_dimension; j++) {
            board[i][j] = SquareEmpty;
        }
    }
    for (int i = 0; i < 16; i++)
    {
        [arr_gameStates replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:0]]; //Mark all slots empty
        
        //Reset the Game
        
        for (UIView *view in [self.view_square subviews]) {
            if ([view isKindOfClass:[UIButton class]])
            {
                UIButton *button = (UIButton*)view;
                [button setImage:nil forState:UIControlStateNormal];
            }
        }
        
    }
    _imgView_currentPlayer.image = [UIImage imageNamed:@"cross.png"];
    activeGame = YES;
    activePlayer = SquareX;
}

@end
